function FOBJS = Remove2DSpurs(OBJS)
        
    FOBJS = OBJS;
    [nR,nC,nZ] = size(FOBJS);
    
    for r = 1:nR
        FOBJS(r,:,:) = bwmorph( squeeze(FOBJS(r,:,:)),'spur',Inf);
        FOBJS(r,:,:) = bwmorph( squeeze(FOBJS(r,:,:)),'clean');
        FOBJS(r,:,:) = bwmorph( squeeze(FOBJS(r,:,:)),'open');
%         subplot(2,1,1); imagesc(squeeze(FOBJS(r,:,:))'); shading flat
%         title(num2str(r))
%         subplot(2,1,2); imagesc(squeeze(OBJS(r,:,:))'); shading flat
%         pause(0.1)
    end
    
    for c = 1:nC
        FOBJS(:,c,:) = bwmorph( squeeze(FOBJS(:,c,:)),'spur',Inf);
        FOBJS(:,c,:) = bwmorph( squeeze(FOBJS(:,c,:)),'clean');
        FOBJS(:,c,:) = bwmorph( squeeze(FOBJS(:,c,:)),'open');
%         subplot(2,1,1); imagesc(squeeze(FOBJS(:,c,:))'); shading flat
%         title(num2str(c))
%         subplot(2,1,2); imagesc(squeeze(OBJS(:,c,:))'); shading flat 
%         pause(0.1)
    end
    
    for z = 1:nZ
        FOBJS(:,:,z) = bwmorph( squeeze(FOBJS(:,:,z)),'spur',Inf);
        FOBJS(:,:,z) = bwmorph( squeeze(FOBJS(:,:,z)),'clean');
        FOBJS(:,:,z) = bwmorph( squeeze(FOBJS(:,:,z)),'open');
%         subplot(2,1,1); imagesc(squeeze(FOBJS(:,:,z))); shading flat
%         title(num2str(z))
%         subplot(2,1,2); imagesc(squeeze(OBJS(:,:,z))); shading flat
%         pause(0.1)
    end