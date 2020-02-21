function testRegression(net,pipetteValidationImg,pipetteValidationLog)
tic
% this file is used to test the pipette regression analysis data
% 
% Colby Lewallen. August 2018
% Updated Mercedes Gonzalez January 2020

n = 9; % size of marker
c1 = 'cyan'; % Real position
c2 = 'red'; % Guess

% use the CNN to guess the position <x,y,z> of the pipette
guess = predict(net,pipetteValidationImg);

% calculate the <dx,dy,dz> for each image
dx = (pipetteValidationLog(:,3))-guess(:,1);
dy = (pipetteValidationLog(:,4))-guess(:,2);
dz = (pipetteValidationLog(:,5))-guess(:,3);

% Convert from pixels to steps to um
dx_um = dx*0.1/1.093;
dy_um = dy*0.1/1.093;
dz_um = dz*0.1/1.093;

% average the distance from the expected value
xerror = mean(abs(dx_um));
yerror = mean(abs(dy_um));
zerror = mean(abs(dz_um));
xstd = std(abs(dx_um));
ystd = std(abs(dy_um));
zstd = std(abs(dz_um));
fprintf('Average\ndx: %1.2f microns\ndy: %1.2f microns\ndz: %1.2f microns\n',xerror,yerror,zerror)
fprintf('Standard Deviation\ndx: %1.2f microns\ndy: %1.2f microns\ndz: %1.2f microns\n',xstd,ystd,zstd)

%% show worst X errors
figure()
[dxMax,dxIdx] = sort(abs(dx));
originalSize = [1024 1280];
ysize = originalSize(1);
xsize = originalSize(2);
minDimension = min(originalSize);
newsize = 224; 

subplot(2,2,1)
I = pipetteValidationImg(:,:,:,dxIdx(end));
posReal = pipetteValidationLog(dxIdx(end),3:4);
posGuess = guess(dxIdx(end),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension;
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['X error: ' num2str(dxMax(end)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,2)
I = pipetteValidationImg(:,:,:,dxIdx(end-1));
posReal = pipetteValidationLog(dxIdx(end-1),3:4);
posGuess = guess(dxIdx(end-1),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['X error: ' num2str(dxMax(end-1)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,3)
I = pipetteValidationImg(:,:,:,dxIdx(end-2));
posReal = pipetteValidationLog(dxIdx(end-2),3:4);
posGuess = guess(dxIdx(end-2),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['X error: ' num2str(dxMax(end-2)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,4)
I = pipetteValidationImg(:,:,:,dxIdx(end-3));
posReal = pipetteValidationLog(dxIdx(end-3),3:4);
posGuess = guess(dxIdx(end-3),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['X error: ' num2str(dxMax(end-3)*0.1/1.093) 'microns '];
title(worstX)

%% show worst Y errors
figure()
[dxMax,dxIdx] = sort(abs(dy));

subplot(2,2,1)
I = pipetteValidationImg(:,:,:,dxIdx(end));
posReal = pipetteValidationLog(dxIdx(end),3:4);
posGuess = guess(dxIdx(end),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['Y error: ' num2str(dxMax(end)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,2)
I = pipetteValidationImg(:,:,:,dxIdx(end-1));
posReal = pipetteValidationLog(dxIdx(end-1),3:4);
posGuess = guess(dxIdx(end-1),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['Y error: ' num2str(dxMax(end-1)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,3)
I = pipetteValidationImg(:,:,:,dxIdx(end-2));
posReal = pipetteValidationLog(dxIdx(end-2),3:4);
posGuess = guess(dxIdx(end-2),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['Y error: ' num2str(dxMax(end-2)*0.1/1.093) 'microns '];
title(worstX)

subplot(2,2,4)
I = pipetteValidationImg(:,:,:,dxIdx(end-3));
posReal = pipetteValidationLog(dxIdx(end-3),3:4);
posGuess = guess(dxIdx(end-3),1:2);
pos = [posReal; posGuess];
transformedpoint = pos; 
transformedpoint(:,1) = newsize*((pos(:,1)+(xsize/2))-(xsize-minDimension)/2)/minDimension; 
transformedpoint(:,2) = newsize*((pos(:,2)+(ysize/2))-(ysize-minDimension)/2)/minDimension;
Imarker = insertMarker(I,transformedpoint(1,:),'Color',c1,'Size',n);
hold on
Imarker2 = insertMarker(Imarker,transformedpoint(2,:),'Color',c2,'Size',n);
imshow(Imarker2)
worstX = ['Y error: ' num2str(dxMax(end-3)*0.1/1.093) 'microns '];
title(worstX)

%% error histogram
figure()
subplot(3,1,1)
histogram(dx_um)
xlim([-7 3.5])
% axis tight
ylabel('dx bin')
xlabel('microns')
title('XYZ error histogram')
    
subplot(3,1,2)
histogram(dy_um)
xlim([-1.75 2.5])

% axis tight
ylabel('dy bin')
xlabel('microns')
    
subplot(3,1,3)
histogram(dz_um)
% axis tight
xlim([-2.5 2.5])

ylabel('dz bin')
xlabel('microns')
timeToTest = toc
end
