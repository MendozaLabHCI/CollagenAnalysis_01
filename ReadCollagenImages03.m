function [ImStack] = ReadCollagenImages03(ImageStackName, nChan, Ch)

    info = imfinfo(ImageStackName);
    nIm = length(info);
    nZ  = nIm/nChan;
    width  = info(1,1).Width;
    height = info(1,1).Height;
    %-----------------------------------------------------------------------------------
    ImStack = zeros(width, height, nZ, 'uint8'); % Preallocate image stack space
    ImBin   = false(width, height, nZ);           % Preallocate image stack space
    
    h1 = waitbar(0,'0'); % initialize waitbar
    h1.Position = [50,70,h1.Position(3:4)]; % move waitbar to corner of screen
    %------------------------------------------------------------------------------------
    switch nChan
        case 1
            zIdx = 1:1:nIm; 
        case 2
            switch Ch
                case 1;  zIdx = 1:2:(nIm-1); % image stack indices for channel 1
                case 2;  zIdx = 2:2:nIm;     % image stack indices for channel 2
            end
        case 3
            switch Ch
                case 1;  zIdx = 1:3:(nIm-2); % image stack indices for channel 1
                case 2;  zIdx = 2:3:(nIm-1);     % image stack indices for channel 2
                case 3;  zIdx = 2:3:(nIm);     % image stack indices for channel 2
            end    
    end
    %------------------------------------------------------------------------------------
    idx = 0;
    for z = zIdx
        idx = idx + 1;
        zSlice01 =  imread(ImageStackName, z); % If image is RBG, grab max pixel 
        waitbar(z/nIm, h1, ['Reading in images.   ' num2str(round(100*z/nIm)) '%']) % Update waitbar
        ImStack(:,:,idx) = zSlice01; 
    end  
    waitbar(z/nIm, h1, 'Applying 3D gaussian smoothing.') ; drawnow
    %------------------------------------------------------------------------------------
    try close(h1); end
   

