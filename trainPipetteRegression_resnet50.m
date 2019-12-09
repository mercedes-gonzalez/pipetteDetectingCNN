%% Train Image Classifier
% This script is used to train an image classifier for in vitro
% electrophysiology. this CNN uses resnet50.
%
% Colby Lewallen. August 2018.
% Updated Mercedes Gonzalez October 2019
clear all; close all; clc

%% load imagage datastore
load 'pipetteXYZdata_11-Nov-2019.mat';
showTrainingDatadetails = true;
showCNNlayers = true;
doTrainingAndEval = true;

%% check data normalization
% When training neural networks, it often helps to make sure that your data
% is normalized in all stages of the network. Normalization helps stabilize
% and speed up network training using gradient descent. If your data is 
% poorly scaled, then the loss can become NaN and the network parameters 
% can diverge during training. Common ways of normalizing data include 
% rescaling the data so that its range becomes [0,1] or so that it has a
% mean of zero and standard deviation of one. You can normalize the 
% following data:
% 
% Input data. Normalize the predictors before you input them to the
% network. so that the values fall in the range of [0,1]
%
% Layer outputs. You can normalize the outputs of each convolutional and 
% fully connected layer by using a batch normalization layer.
%
% Responses. If you use batch normalization layers to normalize the layer
% outputs in the end of the network, then the predictions of the network 
% are normalized when training starts. If the response has a very different
% scale from these predictions, then network training can fail to converge.
% If your response is poorly scaled, then try normalizing it and see if 
% network training improves. If you normalize the response before training,
% then you must transform the predictions of the trained network to obtain
% the predictions of the original response.
% 
% Plot the distribution of the response. The response (the displacement in
% microns) should be approximately uniformly distributed, which works well
% without needing normalization. In classification problems, the outputs 
% are class probabilities, which are always normalized.
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
net = resnet50; % changed to resnet101 

% extract the layer gram from the trained network and plot the layer graph
lgraph = layerGraph(net);
if showCNNlayers
    figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
    plot(lgraph)
end

% get the image input size
inputSize = net.Layers(1).InputSize;

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
lgraph = removeLayers(lgraph, {'fc1000','fc1000_softmax','ClassificationLayer_fc1000'});

[~,numClasses] = size(coordsTraining);
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',10,'BiasLearnRateFactor',10)
    regressionLayer('Name','Image regression')];
lgraph = addLayers(lgraph,newLayers);

% connect the last transferred layer remaining in the network to the new
% layers. To check that the new layers are connected correctly, plot the
% new layer graph and zoom in on the last layers of the network.
lgraph = connectLayers(lgraph,'avg_pool','fc');

if showCNNlayers
    figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
    plot(lgraph)
    ylim([0,10])
end

%% freeze initial layers
% The network is now ready to be retrained on the new set of images. 
% Optionally, you can "freeze" the weights of earlier layers in the network
% by setting the learning rates in those layers to zero. During training, 
% trainNetwork does not update the parameters of the frozen layers. Because
% the gradients of the frozen layers do not need to be computed, freezing
% the weights of many initial layers can significantly speed up network 
% training. If the new data set is small, then freezing earlier network 
% layers can also prevent those layers from overfitting to the new data 
% set.
% 
% Extract the layers and connections of the layer graph and select which
% layers to freeze. In GoogLeNet, the first 110 layers are all the layers 
% up to and including the inception_5a module. Use the supporting function
% freezeWeights to set the learning rates to zero for the first 110 layers.
% Use the supporting function createLgraphUsingConnections to reconnect all
% the layers in the original order. The new layer graph contains the same
% layers, but with the learning rates of the earlier layers set to zero.
% layers = lgraph.Layers;
% connections = lgraph.Connections;
% 
% layers(1:110) = freezeWeights(layers(1:110));
% lgraph = createLgraphUsingConnections(layers,connections);

%% set training options
% Specify the training options. For transfer learning, keep the features
% from the early layers of the pretrained network (the transferred layer 
% weights). To slow down learning in the transferred layers, set the 
% initial learning rate to a small value. In the previous step, you 
% increased the learning rate factors for the fully connected layer to 
% speed up learning in the new final layers. This combination of learning
% rate settings results in fast learning only in the new layers and slower
% learning in the other layers. When performing transfer learning, you do 
% not need to train for as many epochs. An epoch is a full training cycle
% on the entire training data set. Specify the mini-batch size and 
% validation data. The software validates the network every 
% ValidationFrequency iterations during trainig
options = trainingOptions('sgdm', ...
    'MiniBatchSize',16, ...
    'MaxEpochs',60, ...
    'InitialLearnRate',1e-4, ...% changed from 1e-4
    'ValidationData',{pipetteValidationImg,coordsValidation}, ...
    'ValidationFrequency',50, ... % changed from 30
    'ValidationPatience',Inf, ...
    'Verbose',false ,...
    'Plots','training-progress',...
    'Shuffle','every-epoch'); % don't throw away same data each time

%% train network
if doTrainingAndEval
    tic
    net = trainNetwork(pipetteTrainingImg,coordsTraining,lgraph,options);
    save(strcat('regressionNET-',string(date),'.mat'),'net','-v7.3')
    timeToTrain = toc
end