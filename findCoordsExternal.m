% function guess = findCoordsExternal(net)
    normalizeImg = true; % post-processing using 2 std
    newsize = 224;
    imageSize = [newsize newsize]; 
    dChannels = 3; % RGB channels
    [file,path] = uigetfile('*.png');
    imagePath = [path file];
    I = imread(imagePath);
    
    temp_folder = 'C:\Users\myip7\Dropbox (GaTech)\Shared folders\Pipette and cell finding\2019-2020 NET\Training and Validation Data\trash\';
    
    %% Initialize image array
    [ysize,xsize,totalChannels] = size(I);
    arraySize = [imageSize totalChannels 1];

    %% Resize image for analysis
    pipetteImg = customPreprocess(I,imageSize);
    temp_path = fullfile(temp_folder,'trash.png');
    imwrite(pipetteImg, temp_path);
    imds = temp_folder;
    auimds = augmentedImageDatastore([newsize newsize],pipetteImg,...
        'OutputSizeMode','centercrop',...
        'ColorPreprocessing','gray2rgb');
    
    %% Predict x,y,z coords (in pixels) of pipette tip using neural net
    guess = predict(net,auimds);
    
    transformedpoint = guess(1:2);
    transformedpoint(1) = newsize*((guess(1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
    transformedpoint(2) = newsize*((guess(2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
    
    guess_um = guess*.1/1.093
    
    %% Plot
    figure
    hold on
    tip = insertMarker(pipetteImg,transformedpoint,'Color','blue','Size',20);
    imshow(tip)
% end