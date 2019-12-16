function sliceDS = blendWithDatastore(slicePath)
%     %% Load images from specified path
%     images = dir(fullfile(slicePath, '*.tif'));    % get images from folderPath

    %% Create mini image data store for slice images and their modifications
    sliceDS = imageDatastore(slicePath,'IncludeSubfolders',true,...
        'FileExtensions',{'.png','.jpg','.tif'});
    pipetteDSPath = 'C:\Users\mgonzalez91\Downloads\pipetteXYZdata_11-Nov-2019.mat';
    n = 2; 
    nSlices = length(sliceDS.Files);
    pipetteDS = matfile(pipetteDSPath);
    nPipettes = length(pipetteDS.pipetteTrainingImg(1,1,1,:));
    imgSize = size(imread(sliceDS.Files{1}));
    sliceImg = zeros(imgSize);
    randIdx = randperm(nSlices);
    randMod = randperm(3);
    %% Show post processing
%     for i = 1:length(sliceDS.Files)
%         Idouble = im2double(imread(sliceDS.Files{i}));
%         avg = mean2(Idouble);
%         sigma = std2(Idouble);
%         I = imadjust(Idouble,[avg-n*sigma avg+n*sigma],[]);
%         multi = cat(2,Idouble,I);
%         montage(multi);
%     end

    %% modify images!
    for i = 1:nPipettes
        fprintf(strcat(num2str(i),'\n'))
        I = imread(sliceDS.Files{int8(mod(i,randIdx)+1)});
        modify = mod(i,randMod);
        switch modify
            case 0 
                Imod = flipud(I);
                Ifused = imfuse(Imod,pipetteDS.pipetteTrainingImg(:,:,:,i));
                imshow(Ifused)
                pause
            case 1
                Imod = fliplr(I);
                Ifused = imfuse(Imod,pipetteDS.pipetteTrainingImg(:,:,:,i));
                imshow(Ifused)
                pause
            case 2
                Imod = fliplr(flipud(I));
                Ifused = imfuse(Imod,pipetteDS.pipetteTrainingImg(:,:,:,i));
                imshow(Ifused)
                pause
        end
    end
end
