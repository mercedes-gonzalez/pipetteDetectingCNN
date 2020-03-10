infotable = struct2table(info);
clc
xx = infotable.xyz(:,1);
yy = infotable.xyz(:,2);
zz = infotable.xyz(:,3);

%%
% diary badfiles
originalSize = [1024 1280];
ysize = originalSize(1);
xsize = originalSize(2);
minDimension = min(originalSize);
newsize = 224; 
fig = figure(1);
info_logical = zeros(length(infotable.xyz),1);
% i = 1; 
while(i<=length(infotable.xyz))
    I = customPreprocess(imread(infotable.filepath(i)),[newsize newsize]);
    
    pos = infotable.xyz(i,1:2); 
    transformedpoint(1) = newsize*((pos(1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
    transformedpoint(2) = newsize*((pos(2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;

    Imarker = insertMarker(I,transformedpoint(1:2),'Color','r','Size',10);
    imshow(Imarker,'InitialMagnification',400)
    fprintf('%s\n%i\n\n',infotable.filepath(i),i);
    w = waitforbuttonpress;
    if w == 1
        i = i + 1; 
    else 
        i = i - 1; 
    end

end
% diary off