close all
clc

[f, P1] = getFFT(bandPassAccelMag, Ts);

figure; hold on; grid on;
title('Single-Sided Amplitude Spectrum of magAcc(t)');
plot(f,P1,'Linewidth',1);
xlabel('Frequency (Hz)')
ylabel('|P1(f)|')


function [f, P1] = getFFT(signal, sampling_time)
    len = length(signal);
    
    Fs = 1/sampling_time;
    Y = fft(signal);
    P2 = abs(Y/len);
    P1 = P2 (1:len/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(len/2))/len;
end

