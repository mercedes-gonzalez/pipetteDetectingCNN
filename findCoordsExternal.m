% function guess = findCoordsExternal(net)
    normalizeImg = true; % post-processing using 2 std
    newsize = 224;
    imageSize = [newsize newsize]; 
    dChannels = 3; % RGB channels
    [file,path] = uigetfile('*.png');
    imagePath = [path file];
    I = imread(imagePath);

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
        Isingle = im2single(I);
        avg = mean2(Isingle)
        sigma = std2(Isingle)
        minval = avg-n*sigma; if minval < 0; minval = 0; end
        maxval = avg+n*sigma; if maxval > 1; maxval = 1; end
        In = imadjust(Isingle,[minval maxval],[]);
        imshow(pipetteImg)
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
    imshow(pipetteImg)
    %% Predict x,y,z coords (in pixels) of pipette tip using neural net
    guess = predict(net,pipetteImg)
    
    transformedpoint = guess(1:2);
    transformedpoint(1) = newsize*((guess(1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
    transformedpoint(2) = newsize*((guess(2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
    
    guess_um = guess*.1/1.093;
    
    %% Plot
    figure
    hold on
    tip = insertMarker(pipetteImg,transformedpoint,'Color','blue','Size',20);
    imshow(tip)
% end