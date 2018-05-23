function myspectro(sig,nResol,f_start,f_stop)

    nSam = length(sig);
    nTime = floor(nSam/nResol);
    sig = reshape(sig(1:nTime*nResol),nResol,nTime);
    sig = abs(fft(sig,[],1)).^2;
    BW = f_stop - f_start;
%     figure;
    imagesc(linspace(0,nSam/BW,nTime),linspace(f_start,f_stop,nResol),10*log10(sig));
    xlabel('time [s]');
    ylabel('frequency [MHz]');
    title('spectrogram [dB]');
    colorbar;
    title(colorbar,'Spectrogram [dB]');
    
end

