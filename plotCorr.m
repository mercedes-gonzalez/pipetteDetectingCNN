function plotCorr(data) 
    set(0,'defaultAxesFontSize',14)

    %% Color Key for figures
    c1 = [0 0.4470 0.7410]; % blue
    c2 = [0.8500 0.3250 0.0980]; % orange
    c3 = [0.6350 0.0780 0.1840]; % red
    
    %% Conversion Factors and Constants
    CF = 0.1/1.093; %  microns = CF*pixels 
    
    %% Convert from pixels to microns
    data.xDesired = data.xDesired*CF;
    data.yDesired = data.yDesired*CF;
    data.zDesired = data.zDesired*CF;
    
    data.xCNN = data.xCNN*CF;
    data.yCNN = data.yCNN*CF;
    data.zCNN = data.zCNN*CF;

    data.xManip = data.xManip*CF;
    data.yManip = data.yManip*CF;
    data.zManip = data.zManip*CF;    
    
    data.xError = data.xError*CF;
    data.yError = data.yError*CF;
    data.zError = data.zError*CF;

    %% PLOT! 
    figure()
%     subplot(2,2,1)
%     hold on; grid on; 
%     plot(data.iter,data.xCNN,'-o','Color',c1,'MarkerFaceColor',c1,'MarkerEdgeColor',c1);
%     plot(data.iter,data.yCNN,'-o','Color',c2,'MarkerFaceColor',c2,'MarkerEdgeColor',c2);
%     plot(data.iter,data.zCNN,'-o','Color',c3,'MarkerFaceColor',c3,'MarkerEdgeColor',c3);
%     plot(data.iter,data.xDesired,'--','Color',c1)
%     plot(data.iter,data.yDesired,'--','Color',c2)
%     plot(data.iter,data.zDesired,'--','Color',c3)
% 
%     xlim([min(data.iter) max(data.iter)])
%     xlabel('Iteration')
%     ylabel('CNN Position [\mu m]')
%     legend('X','Y','Z','X_{des}','Y_{des}','Z_{des}')

%    subplot(2,2,2)
%     hold on; grid on; 
%     plot(data.iter,data.xManip,'-o','Color',c1,'MarkerFaceColor',c1,'MarkerEdgeColor',c1);
%     plot(data.iter,data.yManip,'-o','Color',c2,'MarkerFaceColor',c2,'MarkerEdgeColor',c2);
%     plot(data.iter,data.zManip,'-o','Color',c3,'MarkerFaceColor',c3,'MarkerEdgeColor',c3);
% 	plot(data.iter,data.xDesired,'--','Color',c1)
%     plot(data.iter,data.yDesired,'--','Color',c2)
%     plot(data.iter,data.zDesired,'--','Color',c3)
%     xlim([min(data.iter) max(data.iter)])
%     xlabel('Iteration')
%     ylabel('Manip Position [\mu m]')
    
%     subplot(2,2,3)
    hold on; grid on; 
    t = linspace(0,max(data.tictoc),10);
    tol = 1*ones(length(t),1);
    plot(data.tictoc,data.xError,'-o','Color',c1,'MarkerFaceColor',c1,'MarkerEdgeColor',c1);
    plot(data.tictoc,data.yError,'-o','Color',c2,'MarkerFaceColor',c2,'MarkerEdgeColor',c2);
    plot(data.tictoc,data.zError,'-o','Color',c3,'MarkerFaceColor',c3,'MarkerEdgeColor',c3);
    plot(t,tol,'--','Color','k')
    plot(t,-tol,'--','Color','k')

    xlim([0 max(data.tictoc)])
    xlabel('Time (seconds)')
    ylabel('Error [\mu m]')
    legend('X','Y','Z')
    
    set(gca,'PlotBoxAspectRatio',[1 1 1]);
    
%     subplot(2,2,4)
%     hold on; grid on;
%     plot3(data.xCNN,data.yCNN,data.zCNN);
%     plot3(data.xManip,data.yManip,data.zManip);
%     scatter3(data.xDesired,data.yDesired,data.zDesired,'k','filled')
%     legend('CNN','Manipulator','Desired')
%     view(-37,30)
end
