%% labview version
% Purpose: To determine the coordinates of the pipette tip based on
% the loaded neural net for one image

%% NOTE
% LabVIEW does not support im2double or imadjust
% testing = tic;

w = warning ('off','all');
%% Initialize variables and filepaths
normalizeImg = true; % post-processing using 2 std
imageSize = [224 224]; 
dChannels = 3; % RGB channels

%% Initialize image array
[~,~,totalChannels] = size(I);
arraySize = [imageSize totalChannels 1];
pipetteImg = zeros(arraySize);

%% Resize image for analysis
[ysize,xsize] = size(I(:,:,1));
minDimension = min([xsize ysize]);
xmin = round(xsize/2-minDimension/2,0);
ymin = round(ysize/2-minDimension/2,0);
width = minDimension;
height = minDimension;
if normalizeImg
    n=1; % 2 std above or below mean are max and min

    Idouble = double(I)./255; % same as im2double(I)
    avg = mean2(Idouble)
    sigma = std2(Idouble)
%     minval = avg-n*sigma; if minval < 0; minval = 0; end
%     maxval = avg+n*sigma; if maxval > 1; maxval = 1; end
% 
%     % pseudo imadjust
%     lowOut = min(min(Idouble));
%     highOut = max(max(Idouble));
%     Idouble(:) =  max(minval(1,:), min(maxval(1,:),Idouble));
%     out = ( (Idouble - minval(1,:)) ./ (maxval(1,:) - minval(1,:)) );
%     out(:) = out .* (highOut(1,:) - lowOut(1,:)) + lowOut(1,:);
    out = imadjust(Idouble,[avg-n*sigma avg+n*sigma],[]);

    pipetteImg(:,:,:,1) = imresize(imcrop(out,[xmin ymin width height]),imageSize,'bilinear');
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
guess = double(predict(net,pipetteImg));
fprintf('\nCNN GUESS: %f %f %f \n',guess(1),guess(2),guess(3));
plotGuess(1) = guess(1) + xsize/2;
plotGuess(2) = guess(2) + ysize/2;

cnnMarker = insertMarker(out,plotGuess,'color','green','size',15);
imshow(cnnMarker)
xGuess = guess(1,1);
yGuess = guess(1,2);
zGuess = guess(1,3);
% t = toc(startExp);
