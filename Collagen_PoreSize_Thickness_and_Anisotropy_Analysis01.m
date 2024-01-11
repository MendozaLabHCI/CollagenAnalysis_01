%===========================================================================================================
% Collagen thickness, pore size and anisotropy measurements
% Code location: X:\Mendoza Lab\MATLAB\Collagen Analysis - Keith\Collagen_PoreSize_Thickness_and_Anisotropy_Analysis01.m
%===========================================================================================================

% WriteDir = 'X:\Mendoza Lab\MATLAB\Collagen Analysis - Keith\New Data 12142022\Results_11-02-2023';
WriteDir = 'X:\Mendoza Lab\MATLAB\Collagen Analysis - Keith\New Data 12142022\Results_01-10-2024'; % For updated pixel sizes
DataFiles = ListOfDataFilesToAnalyze04;
N = length(DataFiles);
STATS = cell(N,1);
FH5 = figure(5);
set(FH5,'Units','normalized','Position',[ 0.0031, 0.30, 0.87, 0.46],'Color','w')

tic
for n = 1:N
    disp(n)
    % Reset variables ----------------------------------------------------------------------------
        ImStack = []; SubStack = []; BW = []; IM = []; nZ = []; OBJS = []; OBJS2 = []; S = [];
        PatchObjects = [];  L = [];  X = [];  Y = [];  Z = [];  stats = []; nObj = [];
    %---------------------------------------------------------------------------------------------
        ImageStackDirectory = fullfile( DataFiles{n,1}.dir, DataFiles{n,1}.filename );     
             
        if DataFiles{n,1}.group == 1 || DataFiles{n,1}.group == 2
            nChan = 3; % 2; % Number of channels
            Ch = 1;    % Channel number you want to read
            dp = DataFiles{n,1}.VoxelSize;     
            dz = DataFiles{n,1}.VoxelSize;
        else
            nChan = 2; % 2; % Number of channels
            Ch = 1;    % Channel number you want to read
            dp = DataFiles{n,1}.VoxelSize;     
            dz = DataFiles{n,1}.VoxelSize;
        end

        ImStack = ReadCollagenImages03(ImageStackDirectory, nChan, Ch);
    %---------------------------------------------------------------------------------------------------------         
        Sz = DataFiles{n,1}.sZ;
        Ez = DataFiles{n,1}.eZ;
    %---------------------------------------------------------------------------------------------------------  
        %SubStack =ImStack(257:768, 257:768, Sz:Ez); % Grab central 512x512 region
        SubStack = ImStack(:,:,Sz:Ez); % 
        for z = 1:size(SubStack,3) % Apply 1% saturation to images
            SubStack(:,:,z) = imadjust(SubStack(:,:,z));
        end
        SubStack = single(SubStack);
    % Calculate Collegen thickness in terms of max sphere diameter -------------------------------------------       
        [Diameters, BWfiber, BWskel] = MeasureCollagenRadiiAlongMidlines(SubStack,dp,FH5);
        savefig(5,fullfile(WriteDir,['Figure_SampleCollageThichnessImage_n',num2str(n),'.fig']))
        savefig(6,fullfile(WriteDir,['Figure_SampleCollageThichnessRendering_n',num2str(n),'.fig']))
    % Calculate Fiber Anisotropy -----------------------------------------------------------------------------
        [Emajor,Eminor] = FourierBased2DFiberAnisotropy(SubStack);
            AnisotropyData.Emajor = Emajor;
            AnisotropyData.Eminor = Eminor;
            savefig(21,fullfile(WriteDir,['Figure_SampleCollagenAnisotropyOfMiddleZ_n',num2str(n),'.fig']))
    % Image Processing and Pore edge detection ---------------------------------------------------------------   
        PST = ceil(sqrt(100)/dp)^2; % Set max pore cross-section threshold to 100 um^2
        BlankRegions = imdilate(BWfiber,strel('square',3)); % Multiply by this 3D mask to remove faint data outside collagen area
        [BW, IM, S] = ImageProcessing01(SubStack.*single(BlankRegions),PST);
    % Calculate pore/tube structures -------------------------------------------------------------------------  
        nZ = size(SubStack,3);
        OBJS1 = BuildTubeStructuresFromMidLayer(BW,dp,dz,round(1*nZ/4));
        OBJS2 = BuildTubeStructuresFromMidLayer(BW,dp,dz,round(2*nZ/4));
        OBJS3 = BuildTubeStructuresFromMidLayer(BW,dp,dz,round(3*nZ/4));
        OBJS = logical(OBJS1 + OBJS2 + OBJS3);
    %---------------------------------------------------------------------------------------------------------
        OBJS = imerode(OBJS, strel('sphere',2)); % erode slightly to disconnect objects the Dilate each object individually in "CalculatePoreSize". 
        OBJS = Remove2DSpurs(OBJS); 
    % Render Objects -----------------------------------------------------------------------------------------
        [PatchObjects,L,nObj,X,Y,Z,FH] = RenderObjects(OBJS,dp,dz,IM,WriteDir,['Figure_PoreRenderings_n',num2str(n)]);
    % Calculate pore size etc. -------------------------------------------------------------------------------  
        if ~isempty(PatchObjects)
            [stats,~] = CalculatePoreSize(PatchObjects,L,nObj,X,Y,Z,WriteDir,['TiffStack_IndividualPoreRenderings_n',num2str(n)],dp,dz);
        else
            stats = [];
        end
    % Record file and stats info -----------------------------------------------------------------------------
        STATS{n,1}.GroupNumber = DataFiles{n,1}.group;
        STATS{n,1}.ImageData = SubStack;
        STATS{n,1}.FiberMask = BWfiber;
        STATS{n,1}.FiberMaskSkeleton = BWskel;
        STATS{n,1}.AnisotropyData = AnisotropyData;
        STATS{n,1}.stats = stats; % Pore MaxSphereDiam is in stats
        STATS{n,1}.fileinfo = DataFiles{n,1};
        STATS{n,1}.CollagenThicknessDiameters = Diameters;
    %-------------------------------------------------------------------------------------
        save(fullfile(WriteDir,'AllStatsData.mat'),'STATS')
    %-------------------------------------------------------------------------------------
end
toc

% use X:\Mendoza Lab\MATLAB\Collagen Analysis - Keith\New Data 12142022\Analyze_STATS_08.m to compile data
