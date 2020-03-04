%% Create a directory of preprocessed images for neural net training
%{ 
This script will read from folderPath and its subfolders, preprocess
based on settings input by user, and save the processed images in a 
separate folder so that training can use a table and reduce required RAM
for training. It will also save the resulting table of shuffled images
for training and validation as a mat file to be easily loaded later on.

Mercedes Gonzalez. March 2020
Version control: https://github.gatech.edu/mgonzalez91/pipetteDetectingCNN

%}
clear all; clc;
%% Settings for preprocessing
RAW_ROOT_PATH =  'C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019-2020 NET\CNN LabVIEW\multibot';
NORMALIZE = true;     % average of each image = 0, standard deviation = 1;
MIRROR_LR = true;           % mirror images across the vertical axis
MIRROR_UD = true;           % mirror images across the horizontal axis
IMG_SIZE = [331 331];      % standard image size for nasnetlarge() is [331 331 3]
PERC_TRAIN = 0.5;    % number between 0 and 1


% Create folder for the day and subfolders for validation and training
NEW_ROOT = "C:\Users\mgonzalez91\Dropbox (GaTech)\Research\Pipette Detection\Pipette and cell finding\2019-2020 NET\Training and Validation Data\";
today_folder = strcat(string(date),'-data');
today_path = strcat(NEW_ROOT,today_folder);

mkdir(NEW_ROOT,today_folder)

% Name mat file name to save table later on
MATfilename = strcat('pipetteXYZ-table-',string(date),'.mat')

fprintf('Settings set successfully. Folders created. \n')
%% Count subfolders in folder_path
% get all folders inside folderPath then count the folders. In addition,
% determine the name of all subfolders to be used later.
S = dir(RAW_ROOT_PATH);
n_folders = sum([S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon','trainingImages'})).isdir]);
subfolder_info = S(~ismember({S.name},...
    {'.','..','.dropbox','desktop.ini','.DS_Store','Icon','trainingImages'}));
start_idx = 0;
%% Set up environment to read images
% add the folder and its sub folders to the search path
addpath(genpath(RAW_ROOT_PATH)) 

% define the accepted file extensions to search for.
file_ext = {'.png','.jpg','.tif'};

% create an image datastore for raw images
raw_imds = imageDatastore(RAW_ROOT_PATH,...
    'FileExtensions',file_ext,...
    'Includesubfolders',true);

% Collect channel info from images
[~,~,totalChannels] = size(imread(raw_imds.Files{1}));

% create image labels
% read the name of the folder. use this to find the name of the log file.
for subfolder_idx = 1:n_folders-1
    logname = subfolder_info(subfolder_idx).name;
    pathname = subfolder_info(subfolder_idx).folder;
    temp_logname = [logname '.txt'];
    fprintf('reading from %s \n',temp_logname)
    log = tdfread(temp_logname);

    %% Normalize Images
    nImg = 1;
    for img_idx = 1:length(log.img)
        % get the image filename from the log
        filename = num2str(log.img(img_idx));
        abs_filepath = [pathname '\' logname '\' filename '.png'];

        % now we append the image and data if the file should be appended
        if exist(abs_filepath, 'file')==2
            fprintf('Adding: %s (Complete: %1.2f)',filename,img_idx/length(log.img)/3)

            I = im2double(imread(raw_imds.Files{start_idx+nImg}));
            if NORMALIZE
                fprintf(' <- normalized')
                I = customPreprocess(I,IMG_SIZE); % normalize and crop for net
                % Save image as .png
                img_name = strcat(filename,'.png');
                temp_path = fullfile(today_path,img_name);
                imwrite(I, temp_path);
                info(start_idx+nImg).filepath = temp_path; 
                info(start_idx+nImg).xyz = [log.x(img_idx) log.y(img_idx) log.z(img_idx)];
            end     
            nImg = nImg + 1;
            fprintf('...\n')
        end
    end
    [~,start_idx] = size(info);

    %% Mirror LR
    if MIRROR_LR
        nImg = 1;
        for img_idx = 1:length(log.img)
            % get the image filename from the log
            filename = num2str(log.img(img_idx));
            abs_filepath = [pathname '\' logname '\' filename '.png'];

            % now we append the image and data if the file should be appended
            if exist(abs_filepath, 'file')==2
                fprintf('Adding: %s (Complete: %1.2f)',filename,img_idx/length(log.img)/3)
                I = im2double(imread(raw_imds.Files{start_idx+nImg}));
                fprintf('...flipping left-to-right\n')
                I_lr = fliplr(customPreprocess(I,IMG_SIZE));  % flip the image
                lr_filename = strcat(filename,'-LR.png');
                temp_path = fullfile(today_path,lr_filename);
                imwrite(I_lr, temp_path);
                info(start_idx+nImg).filepath = temp_path; 
                info(start_idx+nImg).xyz = [-log.x(img_idx) log.y(img_idx) log.z(img_idx)];
                nImg = nImg + 1;
            end
        end
    [~,start_idx] = size(info);
    end

    %% Mirror UD
    if MIRROR_UD
        nImg = 1;
        for img_idx = 1:length(log.img)
            % get the image filename from the log
            filename = num2str(log.img(img_idx));
            abs_filepath = [pathname '\' logname '\' filename '.png'];

            % now we append the image and data if the file should be appended
            if exist(abs_filepath, 'file')==2
                fprintf('Adding: %s (Complete: %1.2f)',filename,img_idx/length(log.img)/3)
                I = im2double(imread(raw_imds.Files{start_idx+nImg}));
                fprintf('...flipping up-down\n')
                I_ud = flipud(customPreprocess(I,IMG_SIZE));  % flip the image
                ud_filename = strcat(filename,'-UD.png');
                temp_path = fullfile(today_path,ud_filename);
                imwrite(I_ud, temp_path);
                info(start_idx+nImg).filepath = temp_path; 
                info(start_idx+nImg).xyz = [log.x(img_idx) -log.y(img_idx) log.z(img_idx)];
                nImg = nImg + 1;
            end
        end
    [~,start_idx] = size(info);
    end
end
%% Make training and validation tables
% Randomly assign some of the images to be validation.
n_images = length(info);
n_valid = round(PERC_TRAIN*n_images);
n_train = n_images - n_valid;
ordered = linspace(1,n_images,n_images);
random = ordered(randperm(n_images));
val_only = random(1:n_valid)';
train_only = random(n_valid+1:end)';

for i = 1:n_valid
    val(i).file = info(val_only(i)).filepath;
    val(i).xyz = info(val_only(i)).xyz;
end

for i = 1:n_train
    train(i).file = info(train_only(i)).filepath;
    train(i).xyz = info(train_only(i)).xyz;
end

val_data = struct2table(val);
train_data = struct2table(train);

%% report and save
fprintf('\nPROCESSING COMPLETE\n')
fullmatfilename = fullfile(today_path,MATfilename)
save(fullmatfilename,'val_data','train_data')
