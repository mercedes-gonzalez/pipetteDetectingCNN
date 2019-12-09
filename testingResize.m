imageSize = [224 224];
[ysize,xsize] = size(I)
minDimension = min([xsize ysize])
xmin = floor(xsize/2-minDimension/2)
ymin = floor(ysize/2-minDimension/2)
width = minDimension
height = minDimension
newI = imresize(imcrop(I,[xmin ymin width height]),imageSize,'bilinear');
imshow(newI)
% figure
% imshow(I)