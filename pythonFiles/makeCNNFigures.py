import matplotlib.pyplot as plt
import numpy as np
import math
from matplotlib.colors import LinearSegmentedColormap
show2a = True
show2b = False
show3a = False
show3b = False

font = {'size'   : 16}

plt.rc('font', **font)
'''
    Figure 1 Workflow, purpose _____________________________________________________________________________________________
'''

'''
    Figure 2 Positioning _____________________________________________________________________________________________
'''
# columns in data numpy array
ITER = 4
TIME = 5
xERR = 12
yERR = 13
zERR = 14
xCNN = 6
yCNN = 7
zCNN = 8

CF = .1/1.093 # conversion factor to change pixels to microns

data = np.genfromtxt('C:/Users/mgonzalez91/Dropbox (GaTech)/Research/Pipette Detection/Pipette and cell finding/2019-2020 NET/CNN LabVIEW/multibot/20200707_cnn_data/20200707.csv',
                        skip_header = 1, delimiter = ',')


if show2a: # circular spatial plot
    vmin = 0
    vmax = 4
    colors = ['firebrick','royalblue']
    cmap1 = LinearSegmentedColormap.from_list("mycmap", colors)
    ms = 70

    iters12 = data[:,ITER] == 2
    x_CNN = CF*data[iters12,xCNN]
    y_CNN = CF*data[iters12,yCNN]
    z_CNN = CF*data[iters12,zCNN]

    fig2a, ax2a = plt.subplots(2)
    fig2a.set_size_inches(6,12)

    # circles
    radius = 1
    win = radius + 2
    circle = plt.Circle((0,0),radius,fill=False,linestyle='--',linewidth=2)
    circle2 = plt.Circle((0,0),radius+1,fill=False,linestyle='--',linewidth=2)
    ax2a[0].add_artist(circle)
    ax2a[0].add_artist(circle2)

    # lines
    z_tol = radius + 1
    x_range = np.linspace(-radius-1,radius+1,10)
    z_range = np.ones(x_range.shape)
    ax2a[1].plot(x_range*2,z_range*z_tol,linestyle='--',linewidth=2,color='k')
    ax2a[1].plot(x_range*2,-z_range*z_tol,linestyle='--',linewidth=2,color='k')
    
    # scalebar
    d = .0 # distance from scalebar to corner
    ax2a[1].plot(np.linspace(start=-win-d,stop=-win-d-1,num=2),(-win-1)*np.ones((2,1)),linewidth=3,color='k')
    # ax2a[1].text(-win+d+d,-win+d-d, s = '1$\mu$m',horizontalalignment='center',verticalalignment = 'center')

    # XY
    xy_plot = ax2a[0].scatter(x=x_CNN,y=y_CNN,c=data[iters12,TIME],cmap=cmap1,vmin=vmin,vmax=vmax,edgecolors='k',s=ms)
    ax2a[0].get_yaxis().set_visible(False)
    ax2a[0].get_xaxis().set_visible(False)
    ax2a[0].spines['right'].set_visible(False)
    ax2a[0].spines['left'].set_visible(False)
    ax2a[0].spines['top'].set_visible(False)
    ax2a[0].spines['bottom'].set_visible(False)
    ax2a[0].set_ylabel('Y [$\mu$m]')
    ax2a[0].set_xlabel('X [$\mu$m]')
    ax2a[0].set_ylim([-win,win])
    ax2a[0].set_xlim([-win,win])
    ax2a[0].set_aspect(aspect=1)

    # XZ
    z_plot = ax2a[1].scatter(x=x_CNN,y=z_CNN,c=data[iters12,TIME],cmap=cmap1,vmin=vmin,vmax=vmax,edgecolors='k',s=ms)
    ax2a[1].get_yaxis().set_visible(False)
    ax2a[1].get_xaxis().set_visible(False)
    ax2a[1].spines['right'].set_visible(False)
    ax2a[1].spines['left'].set_visible(False)
    ax2a[1].spines['top'].set_visible(False)
    ax2a[1].spines['bottom'].set_visible(False)
    ax2a[1].set_ylabel('Y [$\mu$m]')
    ax2a[1].set_xlabel('X [$\mu$m]')
    ax2a[1].set_xlim([-5,5])
    ax2a[1].set_ylim([-5,5])
    ax2a[1].set_aspect(aspect=1)
    cbar = plt.colorbar(xy_plot,orientation="horizontal",pad=0.1)
    cbar.ax.set_xlabel('time (s)')

    plt.tight_layout()
    plt.savefig('fig2c.tiff')

if show2b: # iteration boxplot
    corr1 = data[:,ITER] == 2
    corr2 = data[:,ITER] == 3
    corr3 = data[:,ITER] == 4
    corr4 = data[:,ITER] == 5
    corr5 = data[:,ITER] == 6
    errorMag = np.power(np.power(data[:,xERR],2) + np.power(data[:,yERR],2) + np.power(data[:,zERR],2),0.5)
    # converge_data = [ CF*errorMag[corr1], CF*errorMag[corr2], CF*errorMag[corr3], CF*errorMag[corr4], CF*errorMag[corr5] ]
    xy_error = [ CF*data[corr1,xERR:yERR], CF*data[corr2,xERR:yERR], CF*data[corr3,xERR:yERR], CF*data[corr4,xERR:yERR], CF*data[corr5,xERR:yERR] ]
    z_error = [ CF*data[corr1,zERR], CF*data[corr2,zERR], CF*data[corr3,zERR], CF*data[corr4,zERR], CF*data[corr5,zERR] ]

    fig2b, ax2b = plt.subplots(2)
    fig2b.set_size_inches(6,12)

    xy_plot = ax2b[0].boxplot(xy_error, patch_artist=True)
    ax2b[0].spines['right'].set_visible(False)
    ax2b[0].spines['top'].set_visible(False)
    ax2b[0].set_ylabel('XY Error [$\mu$m]')
    ax2b[0].set_xlabel('Correction Number')
    ax2b[0].set_ylim([-10,10])

    z_plot = ax2b[1].boxplot(z_error, patch_artist=True)
    ax2b[1].spines['right'].set_visible(False)
    ax2b[1].spines['top'].set_visible(False)
    ax2b[1].set_ylabel('Z Error [$\mu$m]')
    ax2b[1].set_xlabel('Correction Number')
    ax2b[1].set_ylim([-10,10])

    def formatBoxplot(myPlot):

        # format box plot
        lw = 1.5
        for box in myPlot['boxes']:
            box.set(color='black',linewidth=lw)
            box.set(facecolor='firebrick')

        for whisker in myPlot['whiskers']: 
            whisker.set(color ='black', 
                        linewidth = lw) 

        for flier in myPlot['fliers']: 
            flier.set(marker ='o', 
                    markerfacecolor='black',
                    markersize=4,
                    color ='red', 
                    alpha = .75) 

        for cap in myPlot['caps']:
            cap.set(color='black', linewidth=lw)

        for median in myPlot['medians']:
            median.set(color='white', linewidth=lw/2)
        return

    formatBoxplot(xy_plot)
    formatBoxplot(z_plot)

    plt.tight_layout()
    plt.savefig('fig2b.tiff')

'''
    Figure 3: autopatching throughput _____________________________________________________________________________________________
'''
if show3a:
    iclamp = np.genfromtxt('C:/Users/mgonzalez91/Dropbox (GaTech)/Research/Pipette CNN Paper/iClamp.csv',delimiter=',')
    membtest = np.genfromtxt('C:/Users/mgonzalez91/Dropbox (GaTech)/Research/Pipette CNN Paper/membranetest.csv',delimiter=',')

    fig3a, axes3a = plt.subplots(1)
    fig3a.set_size_inches(8,6)

    axes3a.plot(iclamp[:,0],iclamp[:,6],color='firebrick',linewidth=3)
    
    # scalebar
    axes3a.plot(np.linspace(start=0,stop=.1,num=2),-60*np.ones((2,1)),linewidth=3,color='k') # 0.1 seconds 
    axes3a.plot(np.zeros((2,1)),np.linspace(start=-60,stop=-60+10,num=2),linewidth=3,color='k') # 10 mV

    axes3a.spines['right'].set_visible(False)
    axes3a.spines['top'].set_visible(False)
    axes3a.spines['left'].set_visible(False)
    axes3a.spines['bottom'].set_visible(False)
    axes3a.get_yaxis().set_visible(False)
    axes3a.get_xaxis().set_visible(False)

    plt.tight_layout()
    plt.savefig('fig3a.tiff')

if show3b:
    fig, axes = plt.subplots(2)
    x_ticks = [ 0, .025 ]
    fig.set_size_inches(4,6)
    vision = ['Cross \nCorrelation', 'CNN']
    detect = [0.5938,0.9167]
    whole = [0.375,0.6389]

    w = .02
    axes[0].bar(x_ticks,detect, tick_label = vision, color = 'royalblue', edgecolor = 'black',linewidth = 2,width = w)
    axes[0].set_ylabel('cell detection\nsuccess rate')
    axes[0].set_ylim([0,1])
    axes[0].spines['right'].set_visible(False)
    axes[0].spines['top'].set_visible(False)

    axes[1].bar(x_ticks,whole, tick_label = vision, color = 'firebrick', edgecolor = 'black', linewidth = 2, width = w)
    axes[1].set_ylabel('whole cell\nsuccess rate')
    axes[1].set_ylim([0,1])
    axes[1].spines['right'].set_visible(False)
    axes[1].spines['top'].set_visible(False)

    plt.tight_layout()
    plt.savefig('fig3b.tiff')

plt.tight_layout()
plt.show()



