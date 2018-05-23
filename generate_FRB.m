clear all;
f_start = 100;  % start frequency
f_stop = 1000;  % stop frequency
DM = 500;      % dispersion measure
SNR = 20;       % SNR in dB
nFiltSize = 2^10;   % size of FRB filter
alpha = 1;    % FRB curvature index
frbwidth = 100;    % frb instantaneous frequency bandwidth index


BW = f_stop - f_start;  % total signal bandwidth
t_start = 4140*DM*f_start^(-2); % FRB delay at start frequency
t_stop = 4140*DM*f_stop^(-2);   % FRB delay at stop frequency
t_d = t_stop - t_start;         % delay between start and stop frequencies
t_d_samples = round(abs(t_d*BW));   % number of samples corresponding to t_d
nTotSam = round(t_d_samples/0.6);

if t_d_samples + round(nTotSam/10) >= nTotSam
    disp('increase number of samples');
    disp(['need at least ',num2str(t_d_samples + round(nTotSam/10)),' samples in total']);
    break;
end

t = 0:t_d_samples-1;    % time....
% FRB filter
filt = ifft(exp(-(5*linspace(-(nFiltSize-1)/nFiltSize,(nFiltSize-1)/nFiltSize,nFiltSize)).^2/2*frbwidth)).*exp(-1i*2*pi*0.5*(0:nFiltSize-1));
puls = 10^(SNR/20)*(randn(1,t_d_samples)+1i*randn(1,t_d_samples))/sqrt(2);  % pulse before filtering
puls = conv(puls,filt); puls = puls(1:t_d_samples); % narrow pulse (i.e. after filtering)
% apply fade-in/-out and dispersion
puls  = puls.*exp(-(1*linspace(-(t_d_samples-1)/t_d_samples,(t_d_samples-1)/t_d_samples,t_d_samples)).^2/2*5).*exp(1i*2*pi*( alpha/(3*t_d_samples^2)*t.^3 - (alpha+1)*t.^2/(2*t_d_samples) - t));
signal = (randn(1,nTotSam)+1i*randn(1,nTotSam))/sqrt(2);    % background noise
% background noise + FRB starting at 10%
signal(round(nTotSam/10):round(nTotSam/10)+t_d_samples-1) = puls + signal(round(nTotSam/10):round(nTotSam/10)+t_d_samples-1);

% quantization to 8-bits (uses signal processing toolbox)
signalN = reshape([real(signal(:)),imag(signal(:))]',2*nTotSam,1);
signalN = uencode(signalN,8,max(abs(signalN)),'signed');

% reconstructs signal after quantization
signal_rec = reshape(double(signalN),2,length(signalN)/2);
signal_rec = signal_rec(1,:) + 1i*signal_rec(2,:);

% plot spestrograms before / after quantization
figure;
subplot(1,3,1);
myspectro(signal,128,f_start,f_stop);
title('initial signal');
subplot(1,3,2);
myspectro(signal_rec,128,f_start,f_stop);
title('quantized signal');

% write quantized FRB to binary file
fileID = fopen('frb.bin','w');
fwrite(fileID,signalN,'int8');
fclose(fileID);

% reads file back
fileID = fopen('frb.bin','r');
signalBIN = fread(fileID,Inf,'int8');
fclose('all');

signal_rec_bin = reshape(double(signalBIN),2,length(signalBIN)/2);
signal_rec_bin = signal_rec_bin(1,:) + 1i*signal_rec_bin(2,:);

subplot(1,3,3);
myspectro(signal_rec_bin,128,f_start,f_stop);
title('reconstructed signal');