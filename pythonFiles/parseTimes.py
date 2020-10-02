import os
from os.path import join, isfile,isdir
from os import listdir
import dippykit as dip
import numpy as np
import scipy as sci
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
import matplotlib
import cv2
from PIL import Image
import re
import numpy as np
import glob

show3c = False
show3d = True

font = {'size'   : 16}

plt.rc('font', **font)


cnn_root = 'C:/Users/mgonzalez91/Dropbox (GaTech)/Research/Pipette Detection/Pipette and cell finding/2019-2020 NET/CNN Patching Data/CNN/'
cc_root = 'C:/Users/mgonzalez91/Dropbox (GaTech)/Research/Pipette Detection/Pipette and cell finding/2019-2020 NET/CNN Patching Data/CrossCorr/'

def extractTimes(desired_state,ROOT_PATH):
    """
    Returns all state times for desired_state in date folder as numpy array.

    date = name of folder in ROOT_PATH
    desired_state = state name as string
    ROOT_PATH = has all the date folders
    """
    dict_list = [] 
    attempt_list = [f for f in listdir(ROOT_PATH) if isdir(join(ROOT_PATH,f))]

    # For each attempt on a specified date
    for a,attempt in enumerate(attempt_list):
        # Parse state_times.lvm file
        if isfile(join(ROOT_PATH,attempt,'state_times.lvm')):
            f = open(join(ROOT_PATH,attempt,'state_times.lvm'),'r')
            times = f.readlines()
            times = times[22:-1]
            for i,t in enumerate(times):
                times[i] = re.sub("\t","", t)
                times[i] = re.sub("\n","", times[i])
                
        # Parse state_list.txt
        if isfile(join(ROOT_PATH,attempt,'state_list.txt')):
            f = open(join(ROOT_PATH,attempt,'state_list.txt'),'r')
            states = f.readlines()
            for i,s in enumerate(states):
                states[i] = re.sub("\n","", s)

        # Build dictionary
        attempt_dict = {}
        for t,time in enumerate(times):
            attempt_dict[states[t]] = times[t]
            if float(time) > 15 and states[t] == 'Pipette repositioning...':
                print(time)
                print(attempt)

        dict_list.append(attempt_dict)

    pip_times = []

    for d in dict_list:
        pip_times.append(float(d[desired_state]))
        
    all_times = np.array(pip_times)

    return all_times

def extractMemtest(desired_param,ROOT_PATH):
    """
    Returns all of a desired_param in date folder as numpy array.
    Can choose from: 
    Ihold, Rm, Ra, Cm, tau,Rt

    date = name of folder in ROOT_PATH
    ROOT_PATH = has all the date folders
    """
    all_params = []
    count = 0
    attempt_list = [f for f in listdir(ROOT_PATH) if isdir(join(ROOT_PATH,f))]
    # Set linenum to grab based on desired parameter
    if desired_param == 'Ihold':
        param_line = 8
    elif desired_param == 'Rm':
        param_line = 12
    elif desired_param == 'Ra':
        param_line = 16
    elif desired_param == 'Cm':
        param_line = 20
    elif desired_param == 'tau':
        param_line = 24
    elif desired_param == 'Rt':
        param_line = 28
    
    # For each attempt on a specified date
    for a,attempt in enumerate(attempt_list):
        # Parse state_times.lvm file
        files = glob.glob(join(ROOT_PATH,attempt,'t1','memtest_Vclamp_cellparams*.txt'))
        # print(len(files))
        # for memtest in files:
        if len(files) > 0:
            memtest = files[0]
            f = open(memtest)
            data = f.readlines()
            param = data[param_line]
            all_params.append(re.sub("<Val>","", param))
            all_params[count] = re.sub("</Val>","", all_params[count])
            all_params[count] = float(all_params[count])
            count += 1
    return all_params

def adjacent_values(vals, q1, q3):
    upper_adjacent_value = q3 + (q3 - q1) * 1.5
    upper_adjacent_value = np.clip(upper_adjacent_value, q3, vals[-1])

    lower_adjacent_value = q1 - (q3 - q1) * 1.5
    lower_adjacent_value = np.clip(lower_adjacent_value, vals[0], q1)
    return lower_adjacent_value, upper_adjacent_value

def set_axis_style(ax, labels):
    ax.get_xaxis().set_tick_params(direction='out')
    ax.xaxis.set_ticks_position('bottom')
    ax.set_xticks(np.arange(1, len(labels) + 1))
    ax.set_xticklabels(labels)
    ax.set_xlim(0.25, len(labels) + 0.75)

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
                markersize=8,
                color ='red', 
                alpha = .75) 

    for cap in myPlot['caps']:
        cap.set(color='black', linewidth=lw)

    for median in myPlot['medians']:
        median.set(color='white', linewidth=lw/2)
    return
        
'''
    Figure 3c time comparison
'''
if show3c:
    # Get data
    fig1, ax1 = plt.subplots()
    fig1.set_size_inches(4,8)
    ax1.set_ylabel('Time (s)')

    print('CNN.... \n\n')
    cnn_times = extractTimes(desired_state='Pipette repositioning...',ROOT_PATH=cnn_root)
    print('cc.... \n\n')
    cc_times = extractTimes(desired_state='Pipette repositioning...',ROOT_PATH=cc_root)
    print('cnn',len(cnn_times))
    print('cc',len(cc_times))
    all_times = [cc_times,cnn_times]

    timesbox = ax1.boxplot(all_times,patch_artist = True,positions=[1,2], manage_ticks=True)
            
    formatBoxplot(timesbox)

    # set style for the axes
    labels = ['Cross\nCorrelation','CNN']
    set_axis_style(ax1, labels)
    ax1.spines['right'].set_visible(False)
    ax1.spines['top'].set_visible(False)

    # plt.subplots_adjust(bottom=0.15, wspace=0.05)
    plt.tight_layout()
    plt.savefig('fig3c.tiff')
    plt.show()

''' 
    Fig 3c Violin Plot version
'''

    # vio = ax1.violinplot(all_times,showmeans=False,showmedians=False,showextrema=False)
    # for pc in vio['bodies']:
    #     pc.set_facecolor('#D43F3A')
    #     pc.set_edgecolor('black')
    #     pc.set_alpha(1)

    # cnnq1, cnnmed, cnnq3 = np.percentile(cnn_times, [25, 50, 75], axis=0)
    # ccq1, ccmed, ccq3 = np.percentile(cc_times, [25, 50, 75], axis=0)
    # quartile1 = [cnnq1,ccq1]
    # medians = [cnnmed,ccmed]
    # quartile3 = [cnnq3,ccq3]
    # print(medians)
    # whiskers = np.array([adjacent_values(sorted_array, q1, q3)
    #     for sorted_array, q1, q3 in zip(all_times, quartile1, quartile3)])
    # whiskers_min, whiskers_max = whiskers[:, 0], whiskers[:, 1]

    # inds = np.arange(1, len(medians) + 1)
    # ax1.scatter(inds, medians, marker='o', color='royalblue', s=30, zorder=3)
    # ax1.vlines(inds, quartile1, quartile3, color='k', linestyle='-', lw=5)
    # ax1.vlines(inds, whiskers_min, whiskers_max, color='k', linestyle='-', lw=1)



'''
    Figure 3d access resistance
'''
if show3d:
    # Get data
    fig3d, ax3d = plt.subplots()
    fig3d.set_size_inches(4,8)
    ax3d.set_ylabel('Access Resistance ($\Omega$)')

    print('CNN.... \n')
    cnn_ras = extractMemtest(desired_param = 'Ra',ROOT_PATH = cnn_root)
    print('cc.... \n')
    cc_ras = extractMemtest(desired_param = 'Ra',ROOT_PATH = cc_root)
    print('cnn',len(cnn_ras))
    print('cc',len(cc_ras))

    all_ras = [cc_ras,cnn_ras]

    # boxplot version
    rasbox = ax3d.boxplot(all_ras,patch_artist = True,positions=[1,2], manage_ticks=True)
    formatBoxplot(rasbox)

    # violin version
    # vio = ax3d.violinplot(all_ras,showmeans=False,showmedians=True,showextrema=True)


    # set style for the axes
    labels = ['Cross\nCorrelation','CNN']
    set_axis_style(ax3d, labels)
    ax3d.spines['right'].set_visible(False)
    ax3d.spines['top'].set_visible(False)
    # ax3d.set_ylim([0,100])

    # plt.subplots_adjust(bottom=0.15, wspace=0.05)
    plt.tight_layout()
    plt.savefig('fig3d.tiff')
    plt.show()
