%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le


clear
close all
clc

addpath(genpath('../data'));

addpath(genpath('algo'));
addpath(genpath('internal'));

%% Read data
datafile = '../data/imu/sample_nw.csv';
T = readtable(datafile);
t = T.time';
len = length(t);
xAccelRaw = T.xAcc';
yAccelRaw = T.yAcc';
zAccelRaw = T.zAcc';


%% Init data
Ts = 0.02;
Fs = 1/Ts;
MAX_FREQUENCY = 3;
MIN_FREQUENCY = 0.5;

coeffLP = Ts*2*pi*MAX_FREQUENCY;
coeffHP = Ts*2*pi*MIN_FREQUENCY;
coeffLPg = 0.025; % 0.2Hz

%% Step Count const
THR = 0.1; %coeffLP = 0.63 - LP only
THR_INTERVAL_MIN = 16.67;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR - 1)/2*0;
save thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

%% Algorithm
accelMagRaw = getAccelMagnitude(xAccelRaw, yAccelRaw, zAccelRaw);
bandPassAccelMag = getBandPass(accelMagRaw, coeffLPg, coeffLP);

[stepCount, peakTime, peakAccelMag, distanceM1, distanceM2, distancesM1, distancesM2] = getStepCount(bandPassAccelMag);
disp("Distance M1: ")
disp(distanceM1);
disp("Distance M2: ")
disp(distanceM2);

[distance, distances] = getDistanceInt(bandPassAccelMag*2, peakAccelMag, Ts);


%% Plot
figure;
subplot(2,1,1); hold on; grid on;
plot(t,bandPassAccelMag,'Linewidth',1); 
plot(t,THR*ones(1,len),'--m','Linewidth',1);
xlabel('Time(s)');
ylabel("Acceleration (g)");
title("Linear Acceleration");


count = 0;
for i = 1:len
    if peakAccelMag(i) > 0
        count = count+1;
        plot(t(i), peakAccelMag(i), 'og', 'MarkerSize',10, 'Linewidth',1.5);
    end
end

subplot(2,1,2); hold on; grid on;
plot(t, distancesM2, 'Linewidth',1);
xlabel('Time(s)');
ylabel("Distance(m)");
title("Walking Distance");
plot(t, distances);

