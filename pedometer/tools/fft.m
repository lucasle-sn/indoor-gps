close all
clc

% S = 0.7*sin(2*pi*10*t) + sin(2*pi*20*t)+0.1;
% X = S + randn(size(t));

Fs = 1/Ts;
Y = fft(mag_3);
P2 = abs(Y/len);
P1 = P2 (1:len/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(len/2))/len;

figure;
plot(f,P1);
title('Single-Sided Amplitude Spectrum of magAcc(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
grid on;
