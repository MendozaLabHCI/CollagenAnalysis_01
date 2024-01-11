function [Diameters, BW3, SK] = MeasureCollagenRadiiAlongMidlines(SubStack,dz,FH5)

    % Saturate image volume then normalize pixel values
    SubStack = single(SubStack);
    SubStack = single( SubStack )./max(SubStack(:)); 
    SubStackSm = imgaussfilt3(SubStack,3);
    
    BW = false(size(SubStackSm));
    for z = 1:size(SubStackSm,3) 
        L = adapthisteq(SubStackSm(:,:,z),'NumTiles',[8 8],'ClipLimit',0.01);
        level = graythresh(L);
        BW(:,:,z) = imbinarize(L,level);
    end

%    BW(SubStackSm > 0.05) = true;

    BW3 = imclose( BW, strel("sphere",5) ); 
    BW3 = imopen(  BW3,strel("sphere",5) );  
    SK = false(size(BW3));
    DT = zeros(size(BW3));

    %--------------------------------------------------------
    for z = 1:size(SubStack,3) 
        SK(:,:,z) = bwskel( BW3(:,:,z));
        DT(:,:,z) = bwdist(~BW3(:,:,z));
        %disp(z)
    end
    %--------------------------------------------------------

set(groot,'CurrentFigure',FH5)


z = round(size(SubStack,3)/2);
TL = tiledlayout(1,3,"TileSpacing","tight",'Padding','compact');

    AX1 = nexttile(TL,1);
        imshow(SubStackSm(:,:,z)); axis equal tight
        colormap(AX1,gray)
        title('Middle z-slice of image data')

    AX2 = nexttile(TL,2);
        imagesc(BW3(:,:,z)); axis equal tight
        colormap(AX2,parula)
        title('Middle z-slice of 3D collagen mask')

    AX3 = nexttile(TL,3);
        imagesc(single(~SK(:,:,z)).*DT(:,:,z)); axis equal tight
        colormap(AX3,jet)
        title('Middle z-slice of DT(mask) x skeleton(mask)')

    Diameters = 2*dz*DT(SK);
    
        
% Test plot of subsection ---------------------------------------
    figure(6); clf
    set(gcf,'Color',[1,1,1])  
    if size(BW3,1) > 400
        s1 = isosurface( BW3(1:400,1:400,:),0.01);
    else
        s1 = isosurface( BW3,0.01);
    end
        p1 = patch(s1);
        p1.FaceColor = [0,0,1];
        p1.FaceAlpha = 0.1;
        p1.EdgeColor = 'none';
        axis equal
        grid on
        camproj('perspective')
        hold(gca,'on')  
   
    if size(SK,1) > 400
        s2 = isosurface(SK(1:400,1:400,:) ,0.5);
    else
        s2 = isosurface(SK ,0.5);
    end
        p2 = patch(s2);
        p2.FaceColor = [1,0,0];
        p2.FaceAlpha = 1;
        p2.EdgeColor = 'none';
         
        camlight(0,15)
        camlight(180,-15)
        xlabel('X')
        ylabel('Y')
        zlabel('Z')

        axis([0,400,0,400,0,100])
        view(45,75)
        drawnow


% %     % Plot test images of processed volume ------------------------------------
% % %     FH = figure(7);
% % %     set(FH,'Color','w','Units','normalized','Position',[0.0135    0.3306    0.8245    0.5417])
% % % 
% % %     TL = tiledlayout(1,2,"TileSpacing","tight","Padding","compact");
% % %         nexttile(TL,1)
% % %             %imagesc( SubStackSm(:,:,50) ); axis square
% % %             %imagesc(DT); axis square
% % %         nexttile(TL,2)
% % %             [Gx,Gy,Gz] = gradient(DT); axis square
% % %                 Wx = false(size(Gx));
% % %                 Wx(Gx>0) = true;
% % %                 Bx = bwperim(Wx);
% % % 
% % %                 Wy = false(size(Gy));
% % %                 Wy(Gy>0) = true;
% % %                 By = bwperim(Wy);
% % % 
% % %                 Wz = false(size(Gz));
% % %                 Wz(Gz>0) = true;
% % %                 Bz = bwperim(Wz);
% % % 
% % %                 B = logical(Bx+By+Bz);
% % %                 R = ~logical(BW4.*B);
% % %             imagesc(DT.*single(R)); axis square
% %             %imagesc(BW3(:,:,50) ); axis square
% % %         nexttile(TL,3)
% % %             WSy = single(logical(watershed(Gy)));
% % %             imagesc(Gy); axis square
% %     %--------------------------------------------------------------------------            
