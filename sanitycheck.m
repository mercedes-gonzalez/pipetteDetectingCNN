%% Sanity check to see if net works on other images (not in validation set)
RAW_ROOT_PATH = 'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019-2020 NET\CNN LabVIEW\20200220 testing';
clc
S = dir(RAW_ROOT_PATH);
file_info = S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon','trainingImages','*.txt'}));
n_images = length(file_info);

for i =2:n_images
    temp = strcat(string(file_info(i).folder),'\',string(file_info(i).name));
    I = imread(temp);
    tic
    guess = findCoordsExternal(I,net); 
    t(i) = toc
end
