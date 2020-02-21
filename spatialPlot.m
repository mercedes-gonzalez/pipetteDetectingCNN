function spatialPlot(data)
    %% Convert Data to microns
    CF = 0.1/1.093; %  microns = CF*pixels 
    data.xCNN = data.xCNN*CF;
    data.yCNN = data.yCNN*CF;
    data.zCNN = data.zCNN*CF;

    %% Plot XY data
    figure
    subplot(2,1,1)
    dotsize = 20;
    scatter3(data.xCNN,data.yCNN,data.zCNN,dotsize,data.tictoc,'filled')

    %% Format Plot
    xlabel('X [\mu m]')
    ylabel('Y [\mu m]')
    title('Top View')

    minX = -1;
    maxX = 1;
    minY = -1;
    maxY = 1;
    xlim([minX maxX]*2)
    ylim([minY maxY]*2)
    c = colorbar
    colormap(jet)
    ylabel(c,'Time [seconds]')
    view(2)
    hold on
    grid on; 
    grid minor
    set(gca,'FontSize',16)
    % pbaspect([1 1 1])
    axis normal
    %% Draw tolerance circle
    x = 0; y = 0; % Center of circle
    r = 1; % Radius of circle
    ang=0:0.01:2*pi; 
    xp=r*cos(ang);
    yp=r*sin(ang);
    plot(x+xp,y+yp,'--','Color','k','lineWidth',2);
    
    %% Plot XZ data
    subplot(2,1,2)
    scatter3(data.xCNN,data.yCNN,data.zCNN,dotsize,data.tictoc,'filled')

    %% Format Plot
    xlabel('X [\mu m]')
    zlabel('Z [\mu m]')
    title('Side View')
    xlim([minX maxX])
    ylim([minY maxY])
    zlim([-3 2])
    c = colorbar
    colormap(jet)
    ylabel(c,'Time [seconds]')
    view(0,0)
    hold on
    grid on; 
    grid minor
    set(gca,'FontSize',16)
    axis normal
    %% Draw tolerance circle
    xline = linspace(-r,r,10);
    yline = linspace(-r,r,10);
    zline = ones(length(xline),1)*r;
    hold on
    plot3(xline,yline,zline,'--','Color','k','lineWidth',2);
    plot3(xline,yline,-zline,'--','Color','k','lineWidth',2);
end