%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le


clear
close all
clc

addpath(genpath('../data'));

addpath(genpath('helpers'));

%% Read data
T = readtable('../data/imu/sample_nw.csv');
t = T.time';
len = length(t);
xAcc = T.xAcc';
yAcc = T.yAcc';
zAcc = T.zAcc';


%% Init data
Ts = 0.02;
Fs = 1/Ts;
MAX_FREQUENCY = 3;
MIN_FREQUENCY = 0.5;


coeffLP = Ts*2*pi*MAX_FREQUENCY;
coeffHP = Ts*2*pi*MIN_FREQUENCY;
coeffLPg = 0.025; % 0.2Hz



%% Algorithm
mag = getMagnitude(xAcc, yAcc, zAcc);

% Band pass 
mag_2 = ones(1,len);
mag_3 = zeros(1,len);
mag_4 = zeros(1,len);
for i=1:len-1
    mag_2(i+1) = (1-coeffLPg)*mag_2(i) + coeffLPg*mag(i);
    mag_3(i) = mag(i)-mag_2(i);
    mag_4(i+1) = (1-coeffLP)*mag_4(i) + coeffLP*mag_3(i);
end


THR = 0.1; %coeffLP = 0.63 - LP only
THR_INTERVAL_MIN = 16.67;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR - 1)/2*0;
save thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

[stepCount,peakTime,peakMag, distanceM1, distanceM2, distanceAllM1, distanceAllM2] = getStepCount(mag_4);
disp("Distance M1: ")
disp(distanceM1);
disp("Distance M2: ")
disp(distanceM2);

[dist,distAll] = getDistanceInt(mag_4*2, peakMag, Ts);


%% Plot
figure;
subplot(2,1,1); hold on; grid on;
plot(t,mag_4,'Linewidth',1); 
plot(t,THR*ones(1,len),'--m','Linewidth',1);
xlabel('Time(s)');
ylabel("Acceleration (g)");
title("Linear Acceleration");


count = 0;
for i = 1:len
    if peakMag(i) > 0
        count = count+1;
        plot(t(i),peakMag(i), 'og', 'MarkerSize',10, 'Linewidth',1.5);
    end
end

subplot(2,1,2); hold on; grid on;
plot(t,distanceAllM2, 'Linewidth',1);
xlabel('Time(s)');
ylabel("Distance(m)");
title("Walking Distance");
plot(t,distAll);


%% ========================= FUNCTIONS =========================
function accMag = getMagnitude(xAcc, yAcc, zAcc)
    accMag = sqrt(xAcc.^2 + yAcc.^2 + zAcc.^2);
end