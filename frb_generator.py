# -*- coding: utf-8 -*-
"""
FRB generator
"""

import numpy as np
import matplotlib.pyplot as plt


def myspectro(sig,nResol,f_start,f_stop):
    nSam = np.shape(signal)[0];
    nTime = int(np.floor(nSam/nResol));
    sig = np.reshape(sig[0:nTime*nResol],(nResol,nTime), order='F');
    sig = np.abs(np.fft.fft(sig,axis=0))**2;
    BW = f_stop - f_start;
    plt.figure();
    plt.imshow(10.*np.log10(sig),extent=[0,float(nSam)/float(BW),f_stop,f_start],aspect='auto');
    plt.xlabel('time [s]');
    plt.ylabel('frequency [MHz]');
    plt.title('spectrogram [dB]');

f_start = 100.       # start frequency
f_stop = 1000.       # stop frequency
DM = 150.            # dispersion measure
SNR = 20.            # SNR in dB
nFiltSize = 2.**10   # size of FRB filter
alpha = 1.           # FRB curvature index
frbwidth = 100.      # frb instantaneous frequency bandwidth index


BW = f_stop - f_start   # total signal bandwidth
t_start = 4140.*DM*f_start**(-2)    # FRB delay at start frequency
t_stop = 4140.*DM*f_stop**(-2)      # FRB delay at stop frequency
t_d = t_stop - t_start              # delay between start and stop frequencies
t_d_samples = int(round(abs(t_d*BW)))    # number of samples corresponding to t_d
nTotSam = int(round(t_d_samples/0.6))

if t_d_samples + round(nTotSam/10) >= nTotSam:
    print('increase number of samples')
    print('need at least ' + str(t_d_samples + round(nTotSam/10)) + ' samples in total')
    exit()

t = np.arange(int(t_d_samples),dtype = 'float')     # time....
# FRB filter
filt = np.fft.ifft(np.exp(-(5*np.linspace(-(nFiltSize-1)/nFiltSize,(nFiltSize-1)/nFiltSize,nFiltSize))**2/2*frbwidth))*np.exp(-1j*2*np.pi*0.5*np.arange(nFiltSize))
puls = 10.**(SNR/20.)*(np.random.normal(0.,1.,int(t_d_samples))+1j*np.random.normal(0.,1.,int(t_d_samples)))/np.sqrt(2)  # pulse before filtering
puls = np.convolve(puls,filt,mode='full')
puls = puls[:t_d_samples] # narrow pulse (i.e. after filtering)
# apply fade-in/-out and dispersion
puls  = puls*np.exp(-(1*np.linspace(-(float(t_d_samples)-1)/float(t_d_samples),(float(t_d_samples)-1)/float(t_d_samples),int(t_d_samples)))**2/2*5)*np.exp(1j*2.*np.pi*( alpha/(3.*float(t_d_samples)**2)*t**3 - (alpha+1)*t**2/(2.*float(t_d_samples)) - t))
signal = (np.random.normal(0.,1.,int(nTotSam))+1j*np.random.normal(0.,1.,int(nTotSam)))/np.sqrt(2.)     # background noise
# background noise + FRB starting at 10%
signal[int(round(nTotSam/10)):int(round(nTotSam/10)+t_d_samples)] = puls + signal[int(round(nTotSam/10)):int(round(nTotSam/10)+t_d_samples)]

myspectro(signal,1024,f_start,f_stop)
