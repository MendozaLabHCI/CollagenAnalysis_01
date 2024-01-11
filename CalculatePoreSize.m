function [STATS, L] = CalculatePoreSize(PatchObjects,L,nObj,X,Y,Z,WriteDir,FileName,dp,dz)

   [nR,nC,nZ] = size(L);
    
    FH = figure(3);
    FH.Position = [104,84,1767,864];
    STATS = cell(0,1);
    for obj = 1:nObj
        clf(FH)
        A = false(size(L));
        idx = find(L == obj);
        A(idx) = true;    % Grab current cell object to Sub-Binary Volume A.
        
        % Create Sub-subregion with just Object to improve processing speeds -----------------
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
            ObjectSubRegion = A(In:Ix,Jn:Jx,Kn:Kx);
            ObjectSubRegion = imdilate(ObjectSubRegion,strel('sphere',2));
       
        % Plot 3D pore -----------------------------------------------------------------------
            AH1 = subplot(1,3,1);
                p1 = patch(AH1,'Faces',PatchObjects(obj,1).Faces,'Vertices',PatchObjects(obj,1).Vertices);
                %P1 = patch(AH1, reducepatch( isosurface(xSub,ySub,zSub,ObjectSubRegion,0.5), 0.1));
                set(p1,'FaceColor',[0,0,1.0],'FaceAlpha',0.1,'EdgeColor',[0.2,0.4,0.2],'EdgeAlpha',0.1)
                camlight;    camproj('perspective')
                grid on; axis equal; axis tight;
                view([100 7])
                xlabel('X (\mum)'); ylabel('Y (\mum)'); zlabel('Z (\mum)');
                title(['Object ' num2str(obj) ' of ' num2str(nObj)])
                AX = axis;
           AH2 = subplot(1,3,2); 
                p2 = patch(AH2,'Faces',PatchObjects(obj,1).Faces,'Vertices',PatchObjects(obj,1).Vertices);
                %P2 = patch(AH2, reducepatch( isosurface(xSub,ySub,zSub,ObjectSubRegion,0.5), 0.1));
                set(p2,'FaceColor',[0,0,1.0],'FaceAlpha',0.1,'EdgeColor',[0.2,0.4,0.2],'EdgeAlpha',0.1)
                camlight;    camproj('perspective')
                grid on; axis equal; axis tight;
                view([10 7])
                xlabel('X (\mum)'); ylabel('Y (\mum)'); zlabel('Z (\mum)');  
         %------------------------------------------------------------------------------------      
                
           [xPath, yPath, zPath, DistAlongPath, DiamPath, PoreVolume, nSkelNodes, Faces, Vertices] = ...
                                      CalculateCenterlineAndDiameter(PatchObjects(obj,1),ObjectSubRegion, xSub, ySub, zSub, dp, dz);
           STATS{obj,1}.DistAlongPath =  single(DistAlongPath); % microns
           STATS{obj,1}.MaxSphereDiam =  DiamPath; % microns
           STATS{obj,1}.PoreVolume = PoreVolume; % microns^3
           STATS{obj,1}.nSkelNodes = nSkelNodes; 
           STATS{obj,1}.Faces = Faces;
           STATS{obj,1}.Vertices = Vertices;
         %------------------------------------------------------------------------------------   
         
           if ~isempty(DiamPath)
               for a = 1:2
                   switch a
                       case 1; Axis = AH1;
                       case 2; Axis = AH2; title(AH2,['Volume = ', num2str(PoreVolume,'%0.0f'),'(\mum)^3'])
                   end
                       
                   hold on
                        multiColorLine(Axis, xPath, yPath, zPath, DiamPath, jet(100))
                        CH = colorbar(Axis,'southoutside');
                        CH.Label.String = 'Maximum Sphere Diameter Along Centerline (\mum)';
                        CH.FontSize = 11;
                        colormap(Axis,jet(100))
                        caxis(Axis,[min(round(DiamPath)), max([max(round(DiamPath));(min(round(DiamPath))+1)])])
                   hold off        
               end
               
                AH4 = subplot(1,3,3);                 
                plot(AH4, DistAlongPath, DiamPath, '-b', DistAlongPath, DiamPath,'.r','MarkerSize',4)
                xlabel('Distance Along Centerline (\mum)')
                ylabel('Maximum Sphere Diameter Along Centerline (\mum)')
                grid on;  TH = title(AH4,FileName);  TH.Interpreter = 'none';
            
                F = getframe(FH); 
                if isequal(obj,1)
                    imwrite(F.cdata, fullfile(WriteDir,[FileName,'.tif']),'tif','WriteMode','overwrite','Compression','none')
                else
                    imwrite(F.cdata, fullfile(WriteDir,[FileName,'.tif']),'tif','WriteMode','append',   'Compression','none')
                end
               drawnow
           end
    end
    
   % try; close(FH); end
    
    
    
