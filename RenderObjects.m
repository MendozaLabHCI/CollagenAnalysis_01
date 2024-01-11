function [P,L,nObj,X,Y,Z,FH] = RenderObjects(OBJS,dp,dz,IM,WriteDir,FileName)

   MinZDepth = round(10/dz); % Set minimum length to 10 microns

   %OBJS2 = bwmorph3( OBJS, 'majority' );
    [ L, nObj ]   = bwlabeln(OBJS);
    [ nR, nC, nZ] = size(OBJS);
    L = uint16(L);
    % Filter out objects less the MinZDepth z's in height --------
    for n = 1:nObj
        idx = find(L == n);
        [~,~,z] = ind2sub( [nR,nC,nZ], idx );
        delZ = max(z) - min(z);
        disp(delZ)
        if delZ < MinZDepth
            OBJS(idx) = false;
        end
    end
    %-------------------------------------------------------
     [L,nObj] = bwlabeln(OBJS);       
     L = uint16(L);
        xvec = (0:nC-1)*dp;
        yvec = (0:nR-1)*dp;
        zvec = (0:nZ-1)*dz;    
        [X,Y,Z] = meshgrid(xvec, yvec, zvec);
        X = single(X);
        Y = single(Y);
        Z = single(Z);
        
    FH = figure(15); clf
    AH = axes(FH);
    set(AH,'YDir','reverse')
    set(AH,'CameraViewAngleMode','manual','CameraViewAngle',7)
    TH = title(AH,FileName);
    TH.Interpreter = 'none';
    camproj(AH,'perspective')
    view(AH,75,30)
    Colors = jet(nObj);
    s = randi(nObj,nObj,1);
    Colors = Colors(s,:);
    
    %P = cell(nObj,1);
    
    for n = 1:nObj
        B = zeros(size(OBJS),'uint8');
        idx = find(L == n);
        B(idx) = 1;
        %------------------------------------------------------------------------------------
        % Create a padded subregion of just the object to speed up processing speeds
            pad = 5;   % Use pad to make add space to exterior (for dilation, and for distance transform)
            [I,J,K] = ind2sub([nR,nC,nZ],idx);
                In = max([min(I)-pad  1]); % Imin
                Ix = min([max(I)+pad nR]); % Imax
                Jn = max([min(J)-pad  1]); % Jmin
                Jx = min([max(J)+pad nC]); % Jmax
                Kn = max([min(K)-pad  1]); % Kmin
                Kx = min([max(K)+pad nZ]); % Kmax
            xSub = X(In:Ix,Jn:Jx,Kn:Kx);  
            ySub = Y(In:Ix,Jn:Jx,Kn:Kx);  
            zSub = Z(In:Ix,Jn:Jx,Kn:Kx);  
            ObjectSubRegion = B(In:Ix,Jn:Jx,Kn:Kx);
        %------------------------------------------------------------------------------------
        ObjectSubRegion = imboxfilt3(ObjectSubRegion,[3,3,3]);
        hold(AH,'on')
        try
%             [P(n,1).Faces, P(n,1).Vertices] = reducepatch(isosurface(xSub,ySub,zSub,ObjectSubRegion,0.5), 0.1);
%             P(n,1).Vertices = lpflow_trismooth(P(n,1).Vertices,P(n,1).Faces);
            P(n,1) = patch(AH, reducepatch(isosurface(xSub,ySub,zSub,ObjectSubRegion,0.5), 0.1) );
            p = patch(AH,'Faces',P(n,1).Faces,'Vertices',P(n,1).Vertices);
            p.FaceColor = Colors(n,:);
            p.EdgeColor =  Colors(n,:);
            if isequal(n,1) 
                camlight;
                axis equal 
                axis([0 nC*dp 0 nR*dp 0 nZ*dz]) 
            end
            drawnow
        catch
            disp('Rendering error in RenderObjects')
            P(n,1).Faces = NaN;
            P(n,1).Vertices = NaN;
        end
    end
    hold(AH,'off')
    camproj('perspective')
    grid(AH,'on')
    
    if ~isempty(WriteDir)
        savefig(FH,fullfile(WriteDir, [FileName,'.fig'] ) )
    end
%    close(FH)
        %      hold(AH,'on'); 
%      S1 = surf(X(:,:,52),Y(:,:,52),Z(:,:,52),IM(:,:,52)./ max(IM(:))); %shading flat; 
%      S1.EdgeColor = 'none';
%      hold(AH,'off')
     