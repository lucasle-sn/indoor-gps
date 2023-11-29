%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le

clear all
close all
clc

addpath(genpath("helpers"));

%% Read data
T = readtable('../data/sample.csv');
t = T.time';
len = length(t);
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

%% Low Pass acceleration (e.g gravity)
coeffLPg = 0.025;
xAccLP = getLowPass(xAcc, coeffLPg);
yAccLP = getLowPass(yAcc, coeffLPg);
zAccLP = getLowPass(zAcc, coeffLPg);

%% Linear acceleration
xAcc_linear = xAcc - xAccLP;
yAcc_linear = yAcc - yAccLP;
zAcc_linear = zAcc - zAccLP;


%% Magnitude
accelMag = getAccelMagnitude(xAcc, yAcc, zAcc);
bandPassAccelMag = getBandPass(accelMag, coeffLPg, coeffLP);


%% Plot 
plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,bandPassAccelMag,'Linewidth',1);

plotFigure("Linear Acceleration", "Time (s)", "Acceleration (g)");
plot(t,xAcc_linear,'Linewidth',1)
plot(t,yAcc_linear,'Linewidth',1)
plot(t,zAcc_linear,'Linewidth',1)


%% ========================= FUNCTIONS =========================
%% High Pass Filter
function highPassSignal = getHighPass(signal, coeffHP)
    len = length(signal);

    highPassSignal = zeros(1,len);
    for i=1:len-1
        highPassSignal(i+1) = (1-coeffHP)*highPassSignal(i) + signal(i+1) - signal(i);
    end
end


%% Low Pass Filter
function lowPassSignal = getLowPass(signal, coeffLP)
    len = length(signal);
    lowPassSignal = zeros(1,len);
    
    % Low pass filter
    for i=1:len-1
        lowPassSignal(i+1) = (1-coeffLP)*lowPassSignal(i) + coeffLP*signal(i);
    end
end
