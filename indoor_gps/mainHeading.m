%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le (987445)


%% MAIN
clear
close all
clc

addpath(genpath('SubFunctions'));

%% Read data
filename = 'test.csv';
T = readtable(filename);
t = T.time;
len = length(t);

xMag = T.xMag;
yMag = T.yMag;
zMag = T.zMag;
xAcc = T.xAcc;
yAcc = T.yAcc;
zAcc = T.zAcc;
xGyr = T.xGyr;
yGyr = T.yGyr;
zGyr = T.zGyr;

mag = [xMag,yMag,zMag];

%% Mag
[xMagCalib, yMagCalib, zMagCalib] = getMagCalib(mag);


%% Acc
Ts = 0.02;
GRAVITY_FREQUENCY = 0.5; % 1Hz
COEFF_GRAVITY_LP = Ts*2*3.14*GRAVITY_FREQUENCY;

[xgAcc,ygAcc,zgAcc] = getAccGravity(xAcc, yAcc, zAcc, COEFF_GRAVITY_LP);


%% Gyr
LP_FREQUENCY = 0.5; % 1Hz
COEFF_GYR_LP = Ts*2*3.14*LP_FREQUENCY;

[xGyrCalib, yGyrCalib, zGyrCalib] = getGyrCalib(xGyr, yGyr, zGyr, COEFF_GYR_LP);


%% Merge
MAG = 60;
gAcc = [xgAcc, ygAcc, zgAcc]';
magCalib = [xMagCalib, yMagCalib, zMagCalib]';
magCalib = magCalib/MAG;


%% Absolute Heading M1
[thetaAllAbs, phiAllAbs, psiAllAbs, qamAll] = getHeadingAbsM1(gAcc, magCalib);


%% Relative Heading: Angular Rate
[thetaAllRel,phiAllRel,psiAllRel, FkAll] = getHeadingRel(xGyrCalib,yGyrCalib,zGyrCalib, Ts);


%% Fusion
N = 50;
[thetaAllFus, phiAllFus, psiAllFus] = getHeadingFusion(qamAll,FkAll,N);

%% Plot
figure; grid on; hold on;
plot(t, psiAllRel + psiAllAbs(N), 'Linewidth',2);
plot(t, psiAllAbs, 'Linewidth',1);
plot(t, psiAllFus, '-', 'Linewidth',1);

xlabel('Time(s)');
ylabel('Orientation(deg)');
title('Heading Estimation');
legend on; 
legend('Realative Heading Offset', 'Absolute Heading', 'Fusion Heading');
set(gca,'color',[0.92;0.92;0.92]);
set(gcf,'color','w');


