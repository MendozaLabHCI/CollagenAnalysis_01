function [xPath, yPath, zPath, dPath, DiamPath1, PoreVolume, nSkelNodes, Faces, Vertices] = CalculateCenterlineAndDiameter(PatchObject,OBJ,xSub,ySub,zSub,dp,dz)

%--------------------------------------   
% Use Skeleton algorithm to find start and end points to travel to and fro
    OBJe = imerode(OBJ,strel('sphere',1)); % Erode the object slightly to remove any loops that might occur in skeleton
    J1 = bwskel(OBJe);
    EndPts = bwmorph3(J1,'endpoints'); % Get all endpoints of the skeleton
    SkelIdx = find(J1);
    idx1 = find(EndPts);
    PoreVolume = numel(find(OBJ)).*dp.*dp.*dz;
    nSkelNodes = numel(idx1);
    
if ~isempty(SkelIdx) && ~isequal(length(SkelIdx),1)
    try 
        % The firt and last end point seem to usually be the farthest ones apart. Which is ideal
        sPt = [xSub(idx1(1)), ySub(idx1(1)), zSub(idx1(1))]; % Start Point
        ePt = [xSub(idx1(end)), ySub(idx1(end)), zSub(idx1(end))]; % End Point
        %--------------------------------------
        DT = dp*bwdist(~OBJ);
        %PR = 0.3; % patch reduction
        %P1 = patch(reducepatch( isosurface(xSub,ySub,zSub,OBJ,0.5), PR),'Visible','off' );
        
        %------------------------------------------------------------------
        % Record Surface parameters so that it can be used in other
        % calculations with our having to do all the image processing over
        % again
            Faces = PatchObject.Faces;       %P1.Faces;
            Vertices = PatchObject.Vertices; %P1.Vertices;
        %------------------------------------------------------------------
        
        [V,~] = voronoin(Vertices);
        % Use Skeleton to remove vertices near by central region
        [~,DSkel] = knnsearch([xSub(SkelIdx), ySub(SkelIdx), zSub(SkelIdx)], V);
        V(DSkel > 1.5,:) = [];        

           P = [2 1 3];
           X = permute(xSub, P);
           Y = permute(ySub, P);
           Z = permute(zSub, P);
           DT2 = permute(DT, P);
     
        DTi = griddedInterpolant(X,Y,Z,DT2,'linear');
        DisTrans = DTi(V(:,1),V(:,2),V(:,3));
        
        % Find closest node to skeleton endpoints 
        sIdx = knnsearch(V,sPt);
        eIdx = knnsearch(V,ePt);
        %--------------------------------------------------------------------------------
        Pairs = nchoosek(1:size(V,1),2);
        I = Pairs(:,1);
        J = Pairs(:,2);

        D = sqrt(sum((V(I,:)-V(J,:)).^2, 2));

        I(D>3,:) = [];
        J(D>3,:) = [];
        D(D>3,:) = [];

        DTW = double( mean([DisTrans(I,1), DisTrans(J,1)], 2 ));  % Calculate weight average between points
        DTD = double(   abs(DisTrans(I,1)-DisTrans(J,1)) );    % Calculate weight difference
        
        alpha = max(D);
        beta  = max(DTW).^2;
        gamma = 1/max(DTD);
        C = alpha*D.^2 + beta*(1./(DTW + 1E-10)).^2 + gamma*DTD.^2; % Path weights (variation on eq.2 in: https://openaccess.thecvf.com/content/CVPR2022/papers/Liao_Progressive_Minimal_Path_Method_With_Embedded_CNN_CVPR_2022_paper.pdf)
        G = graph(I,J,C);
        path = shortestpath(G,sIdx,eIdx);
        %---------------------------------------------------------------------------------
        %[costs,path] = dijkstra(V,E3,sIdx,eIdx);

        xPath = V(path,1);
        yPath = V(path,2);
        zPath = V(path,3);

        DiamPath1 = 2*DTi(xPath,yPath,zPath);
        dPath = [0; cumsum(sqrt(diff(xPath).^2 + diff(yPath).^2 + diff(zPath).^2))];
        PathDiffs = sqrt(diff(xPath).^2 + diff(yPath).^2 + diff(zPath).^2);
        DistAlongPath = linspace( 0, max(dPath), 2*length(dPath));
        DiamPath2 = interp1(dPath,DiamPath1,DistAlongPath);
       
    catch
        xPath = [];
        yPath = []; 
        zPath = [];
        dPath = [];
        DiamPath1 = []; 
        PoreVolume = [];
        nSkelNodes = [];
        Faces = [];
        Vertices = [];
    end
else
    xPath = [];
    yPath = []; 
    zPath = [];
    dPath = [];
    DiamPath1 = [];
    PoreVolume = [];
    nSkelNodes = [];
    Faces = [];
    Vertices = [];
end
    