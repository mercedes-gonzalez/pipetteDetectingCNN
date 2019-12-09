%% Initial conditions
clc; clear all;
blockSize(1) = 8;
blockSize(2) = 16;
blockSize(3) = 32;
blockSize(4) = 1024/2/2/2/2;
blockSize(5) = 1024/2/2/2;

imagePath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\20191125\3657564462.png';
pipettePath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\error in 5 pix\3656670053.png';
actualPath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\20191125\3657564009.png';
Cells = imread(imagePath);
Pipette = imread(pipettePath);
Actual = imread(actualPath);
style = 'blend';
%% Shuffle background
for i = 1:5
    [I(:,:,i), ~, ~] = randblock(Cells,blockSize(i));
    P(:,:,i) = imfuse(Pipette,I(:,:,i),'method',style);
end
P(:,:,6) = imfuse(Pipette,Cells,'method',style);
I(:,:,6) = Cells;
%% plot it
multi = cat(1,I(:,:,:));
multiP = cat(1,P(:,:,:));
compare = cat(2,Actual,P(:,:,6));

figure
montage(multi);

figure
montage(multiP);

figure 
montage(compare);