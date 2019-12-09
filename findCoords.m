function guess = findCoords(net)
    normalizeImg = true; % post-processing using 2 std
    imageSize = [224 224]; 
    dChannels = 3; % RGB channels
    [file,path] = uigetfile('*.png');
    imagePath = [path file];
    I = imread(imagePath);
%     load(netPath)% Load net based on filepath

    %% Initialize image array
    [ysize,xsize,totalChannels] = size(I);
    arraySize = [imageSize totalChannels 1];
    pipetteImg = zeros(arraySize);

    %% Resize image for analysis
    minDimension = min([xsize ysize]);
    xmin = floor(xsize/2-minDimension/2);
    ymin = floor(ysize/2-minDimension/2);
    width = minDimension;
    height = minDimension;
    if normalizeImg
        n=2; % 2 std above or below mean are max and min
        Idouble = im2double(I);
        avg = mean2(Idouble)
        sigma = std2(Idouble) 
        minval = avg-n*sigma; if minval < 0; minval = 0; end
        maxval = avg+n*sigma; if maxval > 1; maxval = 1; end
        In = imadjust(Idouble,[minval maxval],[]);
%         In = (I-mean2(I))./std2(I);
        pipetteImg(:,:,:,1) = imresize(imcrop(In,[xmin ymin width height]),imageSize,'bilinear');
    else
        pipetteImg(:,:,:,1) = imresize(imcrop(I,[xmin ymin width height]),imageSize,'bilinear');
    end

    %% convert to 3 channel if needed
    [~,~,nChannels,~] = size(pipetteImg(:,:,:,1));
    if nChannels<dChannels
        for i = 1:dChannels
            pipetteImg(:,:,i,:) = pipetteImg(:,:,1,:);
        end
    end

    %% Predict x,y,z coords (in pixels) of pipette tip using neural net
    guess = predict(net,pipetteImg)
    guess_um = guess*.1/1.093
    xGuess = guess(1,1);
    yGuess = guess(1,2);
    zGuess = guess(1,3);
    posGuess = [xGuess + xsize/2, yGuess + ysize/2];
    posActual = [0 + xsize/2 0 + ysize/2];
    
    %% Plot
    figure
    hold on
    tip = insertMarker(I,posGuess,'Color','blue','Size',15);
    tip2 = insertMarker(tip,posActual,'Color','red','Size',15);
    imshow(tip2)
    title('Final')


end