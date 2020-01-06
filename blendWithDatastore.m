%% Specify where the slice images are located
slicePath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\SliceOnly';

%% Specify where the pipette datastore is. will access one image at a time!
pipetteDSPath = 'C:\Users\mgonzalez91\Downloads\pipetteXYZdata_11-Nov-2019.mat';
pipetteDS = matfile(pipetteDSPath,'Writable',true); % access pipette data store without loading to workspace!
nTraining = length(pipetteDS.pipetteTrainingImg(1,1,1,:)); % total number of training pipette images
nValidation = length(pipetteDS.pipetteValidationImg(1,1,1,:)); % total number of validation pipette images
%% Create mini image data store for slice images and their modifications
sliceDS = imageDatastore(slicePath,'IncludeSubfolders',true,...
    'FileExtensions',{'.png','.jpg','.tif'});
nSlices = length(sliceDS.Files); % total number of slice images

%% Initialize variables for image processing
imageSize = size(imread(sliceDS.Files{1})); % size of images in slice folder
n = 2; % number of std above or below mean for imadjust
desiredSize = [224 224]; % desired resize size (for net)

xsize = imageSize(1); % x dimension of images in slice folder
ysize = imageSize(2); % y dimension of images in slice folder
minDimension = min([xsize ysize]); % min dimension to create a square
xmin = floor(xsize/2-minDimension/2);
ymin = floor(ysize/2-minDimension/2);
width = minDimension;
height = minDimension;

%% Randomly modify the slice image and imfuse it with each image in training data
% Order of operations: Raw, Cropped, Modified, Adjusted, Fused
for i = 1:nTraining
    Iraw = imread(sliceDS.Files{randperm(nSlices,1)}); % Read raw image from slice datastore
    Icropped =  im2double(imresize(imcrop(Iraw,[xmin ymin width height]),desiredSize,'bilinear')); % Crop, resize, and set data type to double
    modify = randperm(3,1); % randomly choose modification for switch case
    switch modify
        case 1
            Imod = flipud(Icropped);
        case 2
            Imod = fliplr(Icropped);
        case 3
            Imod = fliplr(flipud(Icropped));
    end

    % Post process (with imadjust) modified image of slice
    avg = mean2(Imod);
    sigma = std2(Imod);
    Iadjusted = im2double(imadjust(Imod,[avg-n*sigma avg+n*sigma],[]));
    Ifused = im2double(imfuse(Iadjusted,pipetteDS.pipetteTrainingImg(:,:,:,i),'method','blend'));

    % Post process (with imadjust) imfused image once more to resemble actual images
    avgFused = mean2(Ifused);
    sigmaFused = std2(Ifused);
    pipetteDS.pipetteTrainingImg(:,:,:,i) = imadjust(Ifused,[avgFused-n*sigmaFused avgFused+n*sigmaFused],[]);
    if (mod(i/nTraining,10) == 0) 
            fprintf('imfused %f%%\n',i/nTraining);
    end
end
%% Do the same as above for validation images
fprintf('\n\n *** \n\nBeginning Validation Images \n\n *** \n\n');
for i = 1:nValidation
    Iraw = imread(sliceDS.Files{randperm(nSlices,1)}); % Read raw image from slice datastore
    Icropped =  im2double(imresize(imcrop(Iraw,[xmin ymin width height]),desiredSize,'bilinear')); % Crop, resize, and set data type to double
    modify = randperm(3,1); % randomly choose modification for switch case
    switch modify
        case 1
            Imod = flipud(Icropped);
        case 2
            Imod = fliplr(Icropped);
        case 3
            Imod = fliplr(flipud(Icropped));
    end

    % Post process (with imadjust) modified image of slice
    avg = mean2(Imod);
    sigma = std2(Imod);
    Iadjusted = im2double(imadjust(Imod,[avg-n*sigma avg+n*sigma],[]));
    Ifused = im2double(imfuse(Iadjusted,pipetteDS.pipetteValidationImg(:,:,:,i),'method','blend'));

    % Post process (with imadjust) imfused image once more to resemble actual images
    avgFused = mean2(Ifused);
    sigmaFused = std2(Ifused);
    pipetteDS.pipetteValidationImg(:,:,:,i) = imadjust(Ifused,[avgFused-n*sigmaFused avgFused+n*sigmaFused],[]);
    if (mod(i/nValidation,10) == 0) 
        fprintf('imfused %f%%\n',i/nValidation);
    end 
    
end