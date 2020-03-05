%% Train Image Classifier
% Script train for regression
% Adapted from Colby Lewallen 2017
% Mercedes Gonzalez March 2020
% clear all; close all; 
clc

%% load imagage datastore
fprintf('Loading datastores..\n')

% lab rig
% load('C:\Users\myip7\Dropbox (GaTech)\Shared folders\Pipette and cell finding\2019-2020 NET\Training and Validation Data\04-Mar-2020-data\pipetteXYZ-table-04-Mar-2020.mat')


showTrainingDatadetails = false;
showCNNlayers = false;
doTrainingAndEval = true;

%% check data normalization
X = train_data.xyz(:,1);
Y = train_data.xyz(:,2);
Z = train_data.xyz(:,3);
coordsTraining = [X Y Z];
coordsValidation = [ val_data.xyz(:,1); val_data.xyz(:,2); val_data.xyz(:,3) ] ;

if showTrainingDatadetails
    fprintf('Checking data normalization...\n')

    figure
    subplot(3,1,1)
    histogram(X)
    axis tight
    ylabel('X bin')
    xlabel('pixels')
    title('data normalization histogram')
    
    subplot(3,1,2)
    histogram(Y)
    axis tight
    ylabel('Y bin')
    xlabel('pixels')
    
    subplot(3,1,3)
    histogram(Z)
    axis tight
    ylabel('Z bin')
    xlabel('pixels')
end

%% load pretrained network
fprintf('Loading CNN...\n')
net = nasnetlarge;

% extract the layer gram from the trained network and plot the layer graph
lgraph = layerGraph(net);
if showCNNlayers
    figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
    plot(lgraph)
end

% get the image input size
inputSize = net.Layers(1).InputSize;

%% replace final three layers
fprintf('Replacing layers...\n')
lgraph = removeLayers(lgraph, {'predictions','predictions_softmax','ClassificationLayer_predictions'});

[~,numClasses] = size(coordsTraining);
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    regressionLayer('Name','Image regression')];
lgraph = addLayers(lgraph,newLayers);

% connect the last transferred layer remaining in the network to the new
% layers. To check that the new layers are connected correctly, plot the
% new layer graph and zoom in on the last layers of the network.
lgraph = connectLayers(lgraph,'global_average_pooling2d_2','fc');

if showCNNlayers
    figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
    plot(lgraph)
    ylim([0,10])
end
%% set training options
fprintf('Setting options...\n')
gpuDevice(1)
options = trainingOptions('sgdm',...
    'MiniBatchSize',8, ... %subset of training data used for each epoch
    'MaxEpochs',60, ... % total times to go through all training data
    'InitialLearnRate',1e-4, ...% changed from 1e-4
    'ValidationData',val_imds, ... % image datastore with validation data
    'ValidationFrequency',50, ... % changed from 30
    'ValidationPatience',20, ... % stop training if asymptotic at 20 times
    'ExecutionEnvironment','gpu',... % set as gpuDevice(1) should have 32 GB mem
    'Verbose',false,...% supress output to command window
    'Plots','training-progress',... % show plot during training
    'Shuffle','every-epoch'); % don't throw away same data each time

%% train network
if doTrainingAndEval
    fprintf('Beginning Training...\n')
    
    tic
    net = trainNetwork(train_imds,lgraph,options);
    timeToTrain = toc;
    
    fprintf('Time to train = %1.2f hours',timeToTrain/60/60);
    
    fprintf('Saving...\n')
    tic
    save(strcat('regressionNET-',string(date),'.mat'),'net','-v7.3')
    timeToSave = toc;
    
    fprintf('Time to save = %1.2f mins',timeToSave/60);
    
end