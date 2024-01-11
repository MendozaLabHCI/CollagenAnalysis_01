function [Emajor,Eminor] = FourierBased2DFiberAnisotropy(ImageStack)

        % ImageStack = SubStack;
        % ImageStack = double(SampleActinImage(20:20+451,:,1));
        
        [nR,nC,nZ] = size(ImageStack);
        x = linspace(-nC/2,nC/2,nC);
        y = linspace(-nR/2,nR/2,nR);
        [X,Y] = meshgrid(x,y);
        R = sqrt( X.^2 + Y.^2 );
        Theta = atan2d(-Y,-X) + 180;
        % imagesc(x,y,Theta); axis equal tight; set(gca,'YDir','normal')
        
        Emajor = NaN(nZ,1);
        Eminor = NaN(nZ,1);

        for z = 1:nZ
            disp(['z ',num2str(z),' of ',num2str(nZ)])
            Win = hamming(nR)*hamming(min(nR))';
            IMraw = double(ImageStack(:,:,z));
            IMwin = IMraw.*Win;
            
            FFT2 = fftshift( fft2(IMwin) );
            P = abs(FFT2).^2;
            P( R>min([nR/2,nR/2])) = 0; % Make there are only angular values within constant frequency radius
            P( R<51.2 | R>170) = 0; % Use angular frequency band relavent to fiber size that we want to measure orientation for
            % imagesc(x,y,P.^0.1); axis equal tight; set(gca,'YDir','normal')
            AngBins = 0:1:360;
            AngCent = AngBins(1:end-1) + diff(AngBins(1:2))/2;
            nCent = length(AngCent);
            Psum = NaN(size(AngCent));
            for T = 1:nCent
                idx = find( Theta >= AngBins(T) & Theta < AngBins(T+1) );
                Psum(T) = sum(P(idx));
            end
        
            Psum = Psum./max(Psum);
        
            PsumFilt = filloutliers(Psum,'linear','mean');
            PsumFilt = filloutliers(PsumFilt,'linear','mean');
            PsumFiltPadded = [fliplr(PsumFilt(2:end)), PsumFilt, fliplr(PsumFilt(1:end-1))];
            PsumFilt = smooth(PsumFiltPadded,11,'moving')';
            PsumFilt = PsumFilt(nCent:2*nCent-1);
            PsumFiltNorm = PsumFilt/max(PsumFilt);
                
            % Convert Angle values and PsumFiltNorm to cartesion coordinates and calculate best fit ellipsoid
            [xp,yp] = pol2cart(AngCent*(pi/180)+pi/2 ,PsumFiltNorm);   
            ellipse_t = fit_ellipse(xp,yp);
            Emajor(z,1) = ellipse_t.long_axis;
            Eminor(z,1) = ellipse_t.short_axis;
        
            if z == round(nZ/2)
                F = figure(21); clf
                F.Color = [1,1,1];
                TL = tiledlayout(2,2,"TileSpacing","compact","Padding","compact");
                nexttile(TL,1)
                    polarplot([AngCent,AngCent(1)]*(pi/180)+pi/2,[PsumFiltNorm,PsumFiltNorm(1)],'-','LineWidth',2);   
                nexttile(TL,2)
                    imagesc(x,y,IMwin); axis equal tight; set(gca,'YDir','normal')
                nexttile(TL,3)
                    plot(AngCent,Psum,'-r','LineWidth',0.5); hold on
                    plot(AngCent,PsumFilt,'-b','LineWidth',2); axis square; xlim([0,360]); hold off
                    set(gca,'YScale','log')
                nexttile(TL,4)
                    plot([xp,xp(1)],[yp,yp(1)],'-b'); axis equal, axis([-1.2,1.2,-1.2,1.2])
                    ellipse_t = fit_ellipse( xp,yp,gca);
                    title(['Emajor/Eminor = ',num2str(ellipse_t.long_axis/ellipse_t.short_axis)])    
                %pause(0.1)
                drawnow
            end
        end


end



