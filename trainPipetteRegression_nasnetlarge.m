%% Train Image Classifier
% Script to create net and train for regression
% Updated Mercedes Gonzalez February 2020! 
% clear all; close all; clc

%% load imagage datastore
% load 'C:\Users\myip7\Dropbox (GaTech)\Shared folders\Pipette and cell finding\2019-2020 NET\february\pipetteXYZdata_11-Feb-2020.mat';
showTrainingDatadetails = true;
showCNNlayers = true;
doTrainingAndEval = true;
changeInputSize = false; % num channels propagates. :(

%% check data normalization
X = pipetteTrainingLog(:,3);
Y = pipetteTrainingLog(:,4);
Z = pipetteTrainingLog(:,5);
coordsTraining = [X Y Z];
coordsValidation = pipetteValidationLog(:,3:5);

if showTrainingDatadetails
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
net = nasnetlarge;

% extract the layer gram from the trained network and plot the layer graph
lgraph = layerGraph(net);
if showCNNlayers
    figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
    plot(lgraph)
end

% get the image input size
inputSize = net.Layers(1).InputSize;
%% change input size 
if changeInputSize == true
    newInputSize = [ 331 331 1 ] ; 
    lgraph = removeLayers(lgraph, {'input_2'});
    newInputLayer = imageInputLayer(newInputSize,...
        'Name','custom_input');
    lgraph = addLayers(lgraph,newInputLayer);
    lgraph = connectLayers(lgraph,'custom_input','stem_conv1');
end

%% replace final three layers
% To retrain GoogLeNet to classify new images, replace the last three 
% layers of the network. These three layers, 'loss3-classifier', 'prob',
% and 'output', contain information on how to combine the features that the
% network extracts into class probabilities and labels. Add three new 
% layers to the layer graph: a fully connected layer, a softmax layer, and
% a classification output layer (if doing classification). Set the final 
% fully connected layer to have the same size as the number of classes in
% the new data set (5, in this example). To learn faster in the new layers 
% than in the transferred layers, increase the learning rate factors of the
% fully connected layer.
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
options = trainingOptions('sgdm',...
    'MiniBatchSize',8, ... %subset of training data used for each epoch
    'MaxEpochs',60, ... % total times to go through all training data
    'InitialLearnRate',1e-4, ...% changed from 1e-4
    'ValidationData',{pipetteValidationImg,coordsValidation}, ...
    'ValidationFrequency',50, ... % changed from 30
    'ValidationPatience',20, ... % stop training if asymptotic at 20 times
    'Verbose',true ,...% supress output to command window
    'Plots','training-progress',... % show plot during training
    'ExecutionEnvironment','multi-gpu',...
    'Shuffle','every-epoch'); % don't throw away same data each time
fprintf('\nOptions are set.\n')
%% train network
if doTrainingAndEval
    fprintf('Beginning Training...\n')
    tic
    net = trainNetwork(pipetteTrainingImg,coordsTraining,lgraph,options);
    timeToTrain = toc;
    fprintf('Time to train = %1.2f hours',timeToTrain/60/60);
    tic
    save(strcat('regressionNET-',string(date),'.mat'),'net','-v7.3')
    timeToSave = toc;
    fprintf('Time to save = %1.2f mins',timeToSave/60);
    
end