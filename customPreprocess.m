function dataOut = customPreprocess(dataIn)
    I = dataIn;
    [ysize,xsize] = size(I(:,:,1));
    minDimension = min([xsize ysize]);

    xmin = floor(xsize/2-minDimension/2);
    ymin = floor(ysize/2-minDimension/2);
    width = minDimension;
    height = minDimension;
    
    n=3; % 2 std above or below mean are max and min
    Idouble = im2double(I);
    avg = mean2(Idouble);
    sigma = std2(Idouble);
    minval = avg-n*sigma; if minval < 0; minval = 0; end
    maxval = avg+n*sigma; if maxval > 1; maxval = 1; end
    Iadjusted = imadjust(Idouble,[minval maxval],[]);
    dataOut = imresize(imcrop(Iadjusted,[xmin ymin width height]),[244 244],'bilinear');
end
