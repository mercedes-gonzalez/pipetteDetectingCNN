% function finalImage = customPreProcess(cellImage,pipetteImage,imageSize)
% cellImage is raw image of cells only
% pipetteImage is raw image of cells and pipette
% finalImage is resized, formatted, and post processed final image of
% "only" the pipette

pipetteImage = im2double(imread('C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\20191125\3657564451.png'));
cellImage = im2double(imread('C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\20191125\3657564455.png'));

%% laplace??
% [glcm, SI] = graycomatrix(pipetteImage,'GrayLimits',[],'NumLevels',32);
% % 'GrayLimits' can be set to [] for min and max
% % 'NumLevels' is number of gray levels as integer
% % 'Offset' is the distance between the pixels and their neighbors [n n]
% % 'Symmetric' counts 1,2 and 2,1 t/f
% figure, imshow(pipetteImage)

%% image subtraction again.. 
% optimizer = registration.optimizer.RegularStepGradientDescent;
% metric = registration.metric.MeanSquares;
% n = 300;
% tform = imregtform(cellImage(1:n,1:n),pipetteImage(1:n,1:n),'similarity',optimizer,metric);
% movingRegistered = imwarp(cellImage,tform,'OutputView',imref2d(size(pipetteImage)));
% newI = pipetteImage - movingRegistered;
% negVals = newI < 0;
% newI(negVals) = 0; 
% figure, imshow(imadjust(newI))

%% gaussian filtering to remove background ? 
blurConst = 12;
sigma = 50;
gau = imgaussfilt(cellImage,sigma);
subt = pipetteImage - blurConst*gau.^2;
imshow(subt,[])
%%

% multi = cat(3,pipetteImage,inverseImage,hazedInverse,hazed);
% montage(multi);

% imshowpair(alignedImage,pipetteImage)

% %% Initialize image array
% [ysize,xsize,~] = size(cellImage);
% 
% %% Resize image for analysis
% minDimension = min([xsize ysize]);
% xmin = floor(xsize/2-minDimension/2);
% ymin = floor(ysize/2-minDimension/2);
% width = minDimension;
% height = minDimension;
% 
% n=2; % 2 std above or below mean are max and min
% Idouble = im2double(I);
% avg = mean2(Idouble);
% sigma = std2(Idouble);
% minval = avg-n*sigma; if minval < 0; minval = 0; end
% maxval = avg+n*sigma; if maxval > 1; maxval = 1; end
% In = imadjust(Idouble,[minval maxval],[]);
% 
% finalImage = imresize(imcrop(In,[xmin ymin width height]),imageSize,'bilinear');
% 
% for i = 2:3
%     finalImage(:,:,i,:) = finalImage(:,:,1,:);
% end
%     
    
% end

