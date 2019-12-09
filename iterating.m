set(groot,'defaultLineLineWidth',2)
set(0,'defaultAxesFontSize',15)

x = linspace(1,length(data),length(data));
x2 = linspace(1,length(data2),length(data2));
x3 = linspace(1,length(data3(:,1)),length(data3(:,1)));
x4 = x3;

subplot(3,1,1)

hold on; grid on;
plot(x(2:end),data(2:end,4),'-o')
plot(x2(2:end),data2(2:end,4),'-o')
plot(x3(2:end),data3(2:end,4),'-o')
plot(x4(2:end),data4(2:end,4),'-o')

xlabel('CNN Iteration Number');
ylabel('Distance from Zero [px]');
xticks(linspace(2,10,9));

subplot(3,1,2)

hold on; grid on;
plot(x(2:end),data(2:end,5),'-o')
plot(x2(2:end),data2(2:end,5),'-o')
plot(x3(2:end),data3(2:end,5),'-o')
plot(x4(2:end),data4(2:end,5),'-o')

xlabel('CNN Iteration Number');
ylabel('Distance from Zero [px]');
xticks(linspace(2,10,9));

subplot(3,1,3)

hold on; grid on;
plot(x(2:end),data(2:end,6),'-o')
plot(x2(2:end),data2(2:end,6),'-o')
plot(x3(2:end),data3(2:end,6),'-o')
plot(x4(2:end),data4(2:end,6),'-o')
xlabel('CNN Iteration Number');
ylabel('Distance from Zero [px]');
xticks(linspace(2,10,9));
legend('Trial 1','Trial 2','Trial 3','Trial 4');

% set(groot,'defaultLineLineWidth',2)
% set(0,'defaultAxesFontSize',15)
% 
% x = linspace(1,length(data),length(data));
% hold on; grid on;
% plot(x(2:end),data(2:end,4),'-o')
% plot(x(2:end),data(2:end,5),'-o')
% plot(x(2:end),data(2:end,6),'-o')
% legend('x','y','z');
% xlabel('CNN Iteration Number');
% ylabel('Distance from Zero [px]');
% xticks(linspace(2,10,9));
% 
% figure
% hold on; grid on;
% x2 = linspace(1,length(data2),length(data2));
% plot(x2(2:end),data2(2:end,4),'-o')
% plot(x2(2:end),data2(2:end,5),'-o')
% plot(x2(2:end),data2(2:end,6),'-o')
% legend('x','y','z');
% xlabel('CNN Iteration Number');
% ylabel('Distance from Zero [px]');
% xticks(linspace(2,6,5));
% 
% figure
% hold on; grid on;
% x3 = linspace(1,length(data3(:,1)),length(data3(:,1)));
% plot(x3(2:end),data3(2:end,4),'-o')
% plot(x3(2:end),data3(2:end,5),'-o')
% plot(x3(2:end),data3(2:end,6),'-o')
% legend('x','y','z');
% xlabel('CNN Iteration Number');
% ylabel('Distance from Zero [px]');
% xticks(linspace(2,5,4));
% 
% figure
% hold on; grid on;
% x4 = x3;
% plot(x4(2:end),data4(2:end,4),'-o')
% plot(x4(2:end),data4(2:end,5),'-o')
% plot(x4(2:end),data4(2:end,6),'-o')
% legend('x','y','z');
% xlabel('CNN Iteration Number');
% ylabel('Distance from Zero [px]');
% xticks(linspace(2,5,4));
