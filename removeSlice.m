%% Remove slice?
actualPath = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019 NET\CNN Testing Images\20191125\3657564009.png';
Actual = imread(actualPath);

se = strel('disk',200);
background = imopen(Actual,se);

mod = Actual - background;
adj = imadjust(mod);

multi = cat(3,Actual,background,mod,adj);
montage(multi)
