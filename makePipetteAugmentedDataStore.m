%% Create augmented data store for training cnn for pipette over slice
% Mercedes Gonzalez February 2020

%% Initialization of settings and variable paths
appendToExisting = false;   % add data to existing mat file
imagesConstantSize = true;  % set to true if you know that every image is the same size
cnnInputSize = [224 224];      % standard image size for resnet101() is [224 224 3]
pTrainingData = 0.97;        % number between 0 and 1

MATfilename = strcat('pipetteAugDatastore-',string(date),'.mat');
folderPath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN LabVIEW\multibot';

%% Count subfolders in folderPath
% get all folders inside folderPath then count the folders. In addition,
% determine the name of all subfolders to be used later.
S = dir(folderPath);
nFolders = sum([S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store',folderPath})).isdir]);
subFolderInfo = S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon .txt',folderPath}));

%% create image datastore
loadedPreviousData = false;
startingIDX = 0;

% add the folder and its sub folders to the search path
addpath(genpath(folderPath)) 

% define the accepted file extensions to search for.
fileExt = {'.png','.jpg','.tif'};

% create an image datastore
imds = imageDatastore(folderPath,'FileExtensions',fileExt,'Includesubfolders',true);

%% init the pipetteImg and pipetteLog arrays
totalChannels = 3; 
% arraySize = [imageSize totalChannels 1];
% pipetteImg = zeros(arraySize);
pipetteLog = zeros(1,5);

%% create image labels
% read the name of the folder. use this to find the name of the log file.
absMinDimension = 4096;    % init the minimum dimension array
for ii = 1:nFolders
    logname = subFolderInfo(ii).name;
    pathname = subFolderInfo(ii).folder;
    tmpLogName = [logname '.txt'];
    fprintf('reading from %s ',tmpLogName)
    log = tdfread(tmpLogName);

    % create the xyz labels for every image that is still in the
    % subfolder using the log file inside the fullRoot folder
    nImg = 1;
    for i = 1:length(log.img)
        % get the image filename from the log
        fileName = num2str(log.img(i));
        absFilePath = [pathname '\' logname '\' fileName '.png'];
    
        % now we append the image and data if the file should be appended
        if exist(absFilePath, 'file')==2
            fprintf('folder: %i/%i,  percent: %1.2f)',ii,nFolders, 100*i/length(log.img))
            % add the current image to a 4D array
            if ~imagesConstantSize || startingIDX+nImg < 2
                I = im2double(imread(imds.Files{startingIDX+nImg}));
                [ysize,xsize] = size(I(:,:,1));
                minDimension = min([xsize ysize]);
                if minDimension < absMinDimension
                    absMinDimension = minDimension;
                end
            end
            xmin = floor(xsize/2-minDimension/2);
            ymin = floor(ysize/2-minDimension/2);
            width = minDimension;
            height = minDimension;
            n=2;
            
            avg = mean2(I);
            sigma = std2(I);
            lownum = avg-n*sigma;
            if lownum < 0 
                lownum = 0; 
            end
            highnum = avg+n*sigma; 
            if highnum > 1
                highnum = 1;
            end

            I = imadjust(I,[lownum highnum],[]);
                
            pipetteImg(:,:,1,startingIDX+nImg) = imresize(imcrop(I,[xmin ymin width height]),cnnInputSize,'bilinear');
            pipetteImg(:,:,2,startingIDX+nImg) = pipetteImg(:,:,1,startingIDX+nImg);
            pipetteImg(:,:,3,startingIDX+nImg) = pipetteImg(:,:,1,startingIDX+nImg);
                       
            pipetteLog(startingIDX+nImg,:) = [str2double(logname) log.img(i) log.x(i) log.y(i) log.z(i)];
            nImg = nImg + 1;
            fprintf('...\n')
        end
    end
    % update the current length of the array
    startingIDX = length(pipetteLog); 
end

%% Create validation and training logs
[d1,d2,d3,d4] = size(pipetteImg);
tbl = table(reshape(pipetteImg,d4,d1,d2,d3),pipetteLog(:,3:5),'VariableNames',{'img','XYZ'});
idx = randperm(d4);
cutoff = round(pTrainingData*d4);
trainingTable = tbl(idx(1:cutoff),:);
validationTable = tbl(idx(cutoff+1:end),:);


pipetteTrainingImg = pipetteImg(:,:,:,idx(1:cutoff)); 
pipetteValidationImg = pipetteImg(:,:,:,idx(cutoff+1:end));
pipetteTrainingLog = pipetteLog(idx(1:cutoff),:); 
pipetteValidationLog = pipetteLog(idx(cutoff+1:end),:);

%%
for i = 1:length(pipetteTrainingImg)
    imshow(pipetteTrainingImg(:,:,1,i))
end

%% Try a new way suggested by matlab...
% imds.Labels(:,1:3) = pipetteLog(:,3:5); 
% [imdsTrain, imdsVal] = splitEachLabel(imds, pTrainingData);
% dsTrain = transform(imdsTrain, @customPreprocess);
% dsVal = transform(imdsVal, @customPreprocess); 


'done'
%% Make augmented imds for training and validation

%% report and save
% fprintf('\nPROCESSING COMPLETE\n\n')
% save(MATfilename,'tbl','pipetteTraining','pipetteValidation',...
%     'auimdsTraining','auimdsValidation')