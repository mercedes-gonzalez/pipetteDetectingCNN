%% Use pipette XYZ data mat file
guessPos = predict(net,pipetteValidationImg);
actualPos = pipetteValidationLog(:,3:5);

% actualPos(:,1) = command20180912.x;
% actualPos(:,2) = command20180912.y;
% actualPos(:,3) = command20180912.z;

% guessPos(:,1:3) = guessData(:,2:4);

guessPos = guessPos*0.1/1.093;
actualPos = actualPos*0.1/1.093;
%% Plot actual vs CNN guess
set(0, 'DefaultLineLineWidth', 1);
figure()
hold on
grid on
scatter(actualPos(:,1),guessPos(:,1))
scatter(actualPos(:,2),guessPos(:,2))
% scatter(actualPos(:,3),guessPos(:,3))
legend('X','Y');
xlabel('Actual Position [\mu m]')
ylabel('Net Position [\mu m]')

%% Create linear fit
figure()
subplot(3,1,1)
hold on
[createPoly,S] = polyfit(actualPos(:,1),guessPos(:,1),1);
[fit,delta] = polyval(createPoly,actualPos(:,1),S);
plot(actualPos(:,1),guessPos(:,1),'o')
plot(actualPos(:,1),fit,'r-')
plot(actualPos(:,1),fit+3*delta,'m--',actualPos(:,1),fit-3*delta,'m--')
legend('Data','Fit','+/- 3 \sigma')
grid on
xlabel('Actual Position [\mu m]')
ylabel('Net Position [\mu m]')
title(['X_{net} = ' num2str(createPoly(1)) 'x_{actual} + ' num2str(createPoly(2))])
% xlim([-30 30])

subplot(3,1,2)
hold on
[createPoly,S] = polyfit(actualPos(:,2),guessPos(:,2),1);
[fit,delta] = polyval(createPoly,actualPos(:,2),S);
plot(actualPos(:,2),guessPos(:,2),'o')
plot(actualPos(:,2),fit,'r-')
plot(actualPos(:,2),fit+3*delta,'m--',actualPos(:,2),fit-3*delta,'m--')
legend('Data','Fit','+/- 3 \sigma')
grid on
xlabel('Actual Position [\mu m]')
ylabel('Net Position [\mu m]')
title(['Y_{net} = ' num2str(createPoly(1)) 'Y_{actual} + ' num2str(createPoly(2))]);
% xlim([-30 30])

subplot(3,1,3)
hold on
[createPoly,S] = polyfit(actualPos(:,3),guessPos(:,3),1);
[fit,delta] = polyval(createPoly,actualPos(:,3),S);
plot(actualPos(:,3),guessPos(:,3),'o')
plot(actualPos(:,3),fit,'r-')
plot(actualPos(:,3),fit+3*delta,'m--',actualPos(:,3),fit-3*delta,'m--')
legend('Data','Fit','+/- 3 \sigma')
grid on
xlabel('Actual Position [\mu m]')
ylabel('Net Position [\mu m]')
title(['Z_{net} = ' num2str(createPoly(1)) 'Z_{actual} + ' num2str(createPoly(2))]);
% xlim([-12 12])

%% Show histograms to validate normal distribution
% calculate the <dx,dy,dz> for each image
dx = actualPos(:,1)-guessPos(:,1);
dy = actualPos(:,2)-guessPos(:,2);
dz = actualPos(:,3)-guessPos(:,3);

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

figure()
subplot(3,1,1)
histogram(dx_um)
axis tight
ylabel('dx bin')
xlabel('\mu m')
title('XYZ error histogram')
    
subplot(3,1,2)
histogram(dy_um)
axis tight
ylabel('dy bin')
xlabel('\mu m')
    
subplot(3,1,3)
histogram(dz_um)
axis tight
ylabel('dz bin')
xlabel('\mu m')
