function [BW, IM, S] = ImageProcessing01(ImStack, PST)

% S are the cross-sectionareas of the pores at the midlayer (units = pixes^2)


% Apply filtering and morphological processing ---------------------------------------------------------
    % Apply 3D gaussian smoothing
    ImFilt01 = imgaussfilt3(ImStack,[2,2,2],'Padding','symmetric'); 
    % Use coherence filter to enhannce/strengthen filamentary structures
    [nR,nC,nZ] = size(ImStack);
    BW = false(nR,nC,nZ);
    IM = zeros(nR,nC,nZ,'single');
    H  = waitbar(0);
    FH = figure;
    AH = axes;
    se = strel('disk',3);
    MidZ = round(nZ/2);
    S = [];
    
    for z = 1:nZ
        waitbar(z/nZ,H,[num2str(z) ' of ' num2str(nZ)])
        IM00  = ImFilt01(:,:,z);
        IM01  = single( CoherenceFilter(IM00,struct('T',10,'dt',1,'Scheme','O')) ); 
        IM03  = imgaussfilt( IM01, [2,2] );        % smooth a little 
        IM03a = single(adapthisteq(uint8(IM03))); % Contrast-limited adaptive histogram equalization
        IMEM1 = imextendedmin( IM03a, 10); % find all wells (extendedmins) in the image for depth = 10
        IMEM2 = imextendedmin( IM03a,  5); % find all wells (extendedmins) in the image for depth = 5
        IMEM3 = imextendedmin( IM03a,  2); % find all wells (extendedmins) in the image for depth = 2
        IMEM4 = imextendedmin( IM03a,  15); % find all wells (extendedmins) in the image for depth = 2
        IMEM  = logical(IMEM1 + IMEM2 + IMEM3 + IMEM4);    % combine binary regions
        IM03b = IM03a;
        IM03b(IMEM) = -Inf; % set extendedmin regions to -Inf. Then use watershed to find edges of all pores (big and small)
        IM(:,:,z) = IM03a;
        BW1 = ~logical(watershed(IM03b));       % Use watershed to find ridgelines (you'll notice there are way too many)
        % Create mask for large pores ---------------------------------------------------------------------
        BW2 = false(nR,nC);                      % Create blank image for large object binary image
        BW2(IM03b < 15) = true;                  % Set pixels less than 10 in IM03b = true
        BW2 = imclose(BW2, se);
        BW2 = imfill( BW2, 'holes' );            % fill in holes
        BW2 = bwareafilt(BW2, [PST,Inf]);        % Filter by size (keep only large objects)
        % BW2 contains only the large pore regions, The PST size threshold
        % was set by trial and error 
        %--------------------------------------------------------------------------------------------------
        BW3 = ~BW2.*BW1;                        % Multiply BW1 by the "not" of BW2 to remove ridgelines/spurs in uninterested areas 
        BW3 = bwmorph(BW3,'spur',Inf);          % Remove spurs (ridgelines that don't do not enclose a region)
        BW4 = ~imclearborder(~BW3);             % make sure border is clear
        
        if isequal(z,MidZ)
            BW3n = ~BW4; % Create binary image of all objects
            stats = regionprops(BW3n,'Area');
            N = length(stats);
            S = zeros(N,1);
            for n = 1:N 
                S(n,1) = stats(n,1).Area; 
            end
        end
        
        % Calculate size stats, of all objects ------------------------------------------------------------
%             stats = regionprops(~BW4,'area');
%             S = cell2mat(struct2cell(stats)');      
%             figure(1); histogram(S)
        %--------------------------------------------------------------------------------------------------
        
        BW5 = bwareafilt(~BW4,[10,PST]);        % Filter out large (and tiny) objects
        % BW5 is the binary image of the pores we're interested in.
        BW(:,:,z) = BW5; % record it for use later
        
        % BW6 is created as an overlay for the raw data to be viewed by the
        % user while image processing is taking place. (just as a check
        % that things are working)
        BW6 = bwmorph(bwperim(~BW5),'dilate',1);
        % imshowpair(uint8(255.*BW6), imsaturate(uint8(IM03a),1),'Parent', AH)
        Combined = imfuse( uint8(255.*BW6), imsaturate(uint8(IM03a),0.1));
        IM04 = imsaturate(uint8(IM03a),0.1);
        GrayImage = cat(3,IM04,IM04,IM04);
        RGB = cat(2,Combined,uint8(255*ones(size(IM04,1),3,3)),GrayImage);
        imshow(RGB,'InitialMagnification',80,'Parent',AH)
        text(10,15,['Z = ' num2str(z)],'Color',[1 1 1],'FontSize',12,'FontWeight','bold','HorizontalAlignment','left');
        warning off 
        %imwrite(RGB,'X:\Mendoza Lab\MATLAB\Collagen Analysis - Keith\SampleProcessedStack01.tif','WriteMode','append','Compression','none')
    end 
    
    try; close(FH); end
    try; close(H);  end
    
    
end


function IMS = imsaturate(Im,p)
    %
    %     Image Saturation (AutoContrast)
    %           IMS = imsaturate(Im,p)
    %
    %           Im = 8bit grayscale image
    %           p = percent saturation on each end of histogram (0-49)
    %
    % KRC 06/26/2009
    %
     
     
    IMS = imadjust(Im,stretchlim(Im,[p/100 (100-p)./100]));
end