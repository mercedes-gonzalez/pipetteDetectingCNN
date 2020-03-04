%% Create a directory of preprocessed images for neural net training
%{ 
This script will read from folderPath and its subfolders, preprocess
based on settings input by user, and save the processed images in a 
separate folder so that training can use a table and reduce required RAM
for training. It will also save the resulting table of shuffled images
for training and validation as a mat file to be easily loaded later on.

Mercedes Gonzalez. March 2020
Version control: https://github.gatech.edu/mgonzalez91/pipetteDetectingCNN

%}
%% Settings for preprocessing
folderPath =  'C:\Users\myip7\Dropbox (GaTech)\Shared folders\Pipette and cell finding\2019-2020 NET\CNN LabVIEW\multibot'; 
append_to_existing = false;   % add data to existing mat file
normalizeImages = true;     % average of each image = 0, standard deviation = 1;
makeTrainingSet = true;     % split data into training and validation data
mirrorLR = true;           % mirror images across the vertical axis
mirrorUD = true;           % mirror images across the horizontal axis
imageSize = [331 331];      % standard image size for nasnetlarge() is [331 331 3]
% dChannels = 1;  % desired number of channels in the image ex. [xx xx dChannels];
pTrainingData = 0.98;    % number between 0 and 1

MATfilename = strcat('NASNET-pipetteXYZdata_',string(date),'.mat')

%% count subfolders
% get all folders inside folderPath then count the folders. In addition,
% determine the name of all subfolders to be used later.
S = dir(folderPath);
nFolders = sum([S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon','trainingImages'})).isdir]);
subFolderInfo = S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon','trainingImages'}));

%% create image datastore
% load any old training data and add the folder to the search directory 
if exist(MATfilename)>0 && append_to_existing == true
    fprintf('loading old data...\n')
    load(MATfilename)
    % get the length of the current log for use later
    startingIDX = length(pipetteLog);
    loadedPreviousData = true;
else
    loadedPreviousData = false;
    startingIDX = 0;
end
% add the folder and its sub folders to the search path
addpath(genpath(folderPath)) 

% define the accepted file extensions to search for.
fileExt = {'.png','.jpg','.tif'};

% create an image datastore
imds = imageDatastore(folderPath,...
    'FileExtensions',fileExt,...
    'Includesubfolders',true);

% init the pipetteImg and pipetteLog arrays
[~,~,totalChannels] = size(imread(imds.Files{1}));
arraySize = [imageSize totalChannels 1];
pipetteImg = zeros(arraySize);
pipetteLog = zeros(1,5);

% create image labels
% read the name of the folder. use this to find the name of the log file.
for ii = 1:nFolders-1
%     [~,logname,~] = fileparts(folderPath);
    logname = subFolderInfo(ii).name;
    pathname = subFolderInfo(ii).folder;
    tmpLogName = [logname '.txt'];
    fprintf('reading from %s ',tmpLogName)
    if usingPC
        fprintf('using PC file structre...\n')
    else
        fprintf('using mac file structure...\n')
    end
    log = tdfread(tmpLogName);

    % now we need to create the xyz labels for every image that is still in the
    % subfolder using the log file inside the fullRoot folder
    nImg = 1;
    for i = 1:length(log.img)
        % get the image filename from the log
        fileName = num2str(log.img(i));
        if usingPC
            absFilePath = [pathname '\' logname '\' fileName '.png'];
        else
            absFilePath = [pathname '/' logname '/' fileName '.png'];
        end

        % now we need to check if the file has already been stored in the array
        % database.
        if loadedPreviousData
            % if the pipetteLog variable exists, look to see if the file and 
            % folder name already exist whithin the pipetteLog variable
            fileChecker = 0;
            for k = 1:length(pipetteLog)
                if pipetteLog(k,1) == str2double(logname) && pipetteLog(k,2) == log.img(i)
                    fileChecker = fileChecker + 1;
                end
            end
            % if the file already exists, don't add it to the current log
            if fileChecker > 0
                fprintf('* skipping img %s, it has already been saved!\n',num2str(log.img(i)))
                appendNewFile = false;
            else
                appendNewFile = true;
            end
        else
            % if pipetteLog doesn't exist, skip this step and return true for
            % add new variable and image
            appendNewFile = true;
        end

        % now we append the image and data if the file should be appended
        if appendNewFile && exist(absFilePath, 'file')==2
            fprintf('adding img: %s to the database (idx: %1.1f)',fileName,i)
            % add the current image to a 4D array
            I = im2double(imread(imds.Files{startingIDX+nImg}));
            if normalizeImages
                fprintf(' <- normalized')
%                 I = (I-mean2(I))./std2(I);
                n=2;
                Idouble = im2double(I); 
                avg = mean2(Idouble);
                sigma = std2(Idouble);
                lownum = avg-n*sigma;
                if lownum < 0 
                    lownum = 0; 
                end
                highnum = avg+n*sigma; 
                if highnum > 1
                    highnum = 1;
                end

                I = imadjust(Idouble,[lownum highnum],[]);
            end
            [ysize,xsize] = size(I(:,:,1));
            minDimension = min([xsize ysize]);
            xmin = floor(xsize/2-minDimension/2);
            ymin = floor(ysize/2-minDimension/2);
            width = minDimension;
            height = minDimension;
            pipetteImg(:,:,:,startingIDX+nImg) = imresize(imcrop(I,[xmin ymin width height]),imageSize,'bilinear');
            pipetteLog(startingIDX+nImg,:) = [str2double(logname) log.img(i) log.x(i)...
                            log.y(i) log.z(i)];
            nImg = nImg + 1;
            fprintf('...\n')
        end
    end
    % update the current length of the array
    startingIDX = length(pipetteLog); 
end

%     % convert to 3 channel if needed
%     [~,~,nChannels,~] = size(pipetteImg(:,:,:,1));
%     if nChannels<dChannels
%         for i = 1:dChannels
%             pipetteImg(:,:,i,:) = pipetteImg(:,:,1,:);
%         end
%     end

% augment the images here
% optionally mirror the image from left to right (axis of flip is vertical)
if mirrorLR
    fprintf('flipping left-to-right...\n')
    xcol = 3;
    pipetteImgLR = fliplr(pipetteImg);  % flip the image
    pipetteLogLR = pipetteLog;          % double the log
    pipetteLogLR(:,xcol) = -pipetteLogLR(:,xcol);   % invert the x axis

    % now append these images to the end of the current array and log
    pipetteImg = cat(4,pipetteImg,pipetteImgLR);
    pipetteLog = cat(1,pipetteLog,pipetteLogLR);
end

% optionally mirror the image from top to bottom
if mirrorUD
    fprintf('flipping up-to-down...\n')
    ycol = 4;
    pipetteImgUD = flipud(pipetteImg);  % flip the image
    pipetteLogUD = pipetteLog;          % double the log
    pipetteLogUD(:,ycol) = -pipetteLogUD(:,ycol);   % invert the y axis

    % now append these images to the end of the current array and log
    pipetteImg = cat(4,pipetteImg,pipetteImgUD);
    pipetteLog = cat(1,pipetteLog,pipetteLogUD);
end

% if the user wants to make a training and validation set
if makeTrainingSet
    % create an array of random integers that will be used to select files
    % from the log and image arrays to be placed in the 

    % count the number of images in the total log
    nImgs = length(pipetteLog);

    % determine how many files should be in the validation array
    nValidationData = ceil((1-pTrainingData)*nImgs);
    fprintf('making training (n = %1.0f) and validation (n = %1.0f) images',...
        nImgs-nValidationData,nValidationData)
    % generate a random permutation of idx values that will be used for
    % pipette validation
    validationIDX = randperm(nImgs,nValidationData);
    trainingIDX = 1:1:nImgs;
    trainingIDX(validationIDX) = [];
    % shuffle the trainingIDX array too
    trainingIDX = trainingIDX(randperm(length(trainingIDX)));

    % store all validation images to a validation file and delete the
    % values from the training set.
    pipetteValidationImg = pipetteImg(:,:,:,validationIDX);
    pipetteTrainingImg = pipetteImg(:,:,:,trainingIDX);

    % repeat the same process for the log
    pipetteValidationLog = pipetteLog(validationIDX,:);
    pipetteTrainingLog = pipetteLog(trainingIDX,:);
else
    % if the user does not want to make a validation set, return empty
    % arrays for the validation data
    pipetteTrainingImg = pipetteImg;
    pipetteTrainingLog = pipetteLog;
    pipetteValidationImg = [];
    pipetteValidationLog = [];
end

% report and save
fprintf('\nPROCESSING COMPLETE\n')
save(MATfilename,'pipetteValidationImg','pipetteValidationLog',...
    'pipetteTrainingImg','pipetteTrainingLog',...
    '-v7.3');
[height,width,num_images] = size(pipetteImg);

if saveExternally == true
    for img_idx = 1:num_images
        
    end
end
    

