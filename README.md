# FRB_simulation

generates a simulated FRB pulse

## generate_FRB.m
Matlab script that creates a 8-bits signed integers binary file containing background noise and one single FRB pulse. The pulse lasts for 60% of the signal, with 20% of empty noise on both ends of the signal.  
Real and imaginary parts are interleaved.  
The first lines of the script allow the user to indicates all parameters of the signal such as DM, bandwidth, SNR...  

## myspectro.m
Home-made spectrogram function, taking as parameters:  
[1] signal  
[2] frequency resolution in # of frequency bins  
[3] start frequency  
[4] stop frequency  
