%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le

clear all
close all
clc

addpath(genpath('../../libplot'));
addpath(genpath('../../data'));

addpath(genpath('helpers'));
addpath(genpath('../src'));

%% Read data
T = readtable('../../data/sample.csv');
t = T.time';
xAcc = T.xAcc';
yAcc = T.yAcc';
zAcc = T.zAcc';

%% Init data
% Chosen sampling time 
Ts = 0.02;

% Step frequency at normal movement is 0.5-3Hz (0.33s-2s per step)
MAX_FREQUENCY = 3;
MIN_FREQUENCY = 0.5;

coeffLP = Ts*2*pi*MAX_FREQUENCY;
coeffHP = Ts*2*pi*MIN_FREQUENCY;

% Frequency of Low-pass filter for gravity (Hz)
% This is used to filter out gravity element (g) from acceleration 
coeffLPg = 0.025; 

%% Step Count
THR_ACCEL_MAG = 0.15; %coeffLP = 0.63 - LP only
THR_INTERVAL_MIN = 16.67;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR_ACCEL_MAG - 1)/2*0;
save thresholdStepCount THR_ACCEL_MAG THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

%% Algorithm
accelMag = getAccelMagnitude(xAcc, yAcc, zAcc);
bandPassAccelMag = getBandPass(accelMag, coeffLPg, coeffLP);

% [stepCount,peakTime,peakMag] = getStepCountAlgoDep(bandPassAccelMag); % Deprecate Method
[stepCount,peakTime,peakMag] = getStepCountAlgo(bandPassAccelMag); % Updated Method
plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,bandPassAccelMag,'Linewidth',1);
plot(t,THR_ACCEL_MAG*ones(1,length(t)),'--m','Linewidth',1);

% Plot peaks
for i = 1:length(t)
    if (peakMag(i) > 0)
        plot(t(i),peakMag(i), 'og', 'MarkerSize',10, 'Linewidth',1.5);
    end
end
