%% Visualizing features from neural net
load('C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019-2020 NET\february\regressionNET-12-Feb-2020.mat')
layer = 337; 
name = net.Layers(layer).Name
channels = 1:56;
I = deepDreamImage(net,name,channels,'PyramidLevels',1);

figure
I_tile = imtile(I,'ThumbnailSize',[64 64]);
imshow(I_tile)
title(['Layer ', name, ' Features'])