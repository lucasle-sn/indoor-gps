%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le


%% MAIN
clear
close all
clc

addpath(genpath('../libmath'));
addpath(genpath('../data'));

addpath(genpath('algo'));
addpath(genpath('internal'));

%% Read data
datafile = '../data/imu/test.csv';
T = readtable(datafile);
t = T.time;
len = length(t);

xMagRaw = T.xMag;
yMagRaw = T.yMag;
zMagRaw = T.zMag;
xAccelRaw = T.xAcc;
yAccelRaw = T.yAcc;
zAccelRaw = T.zAcc;
xGyroRaw = T.xGyr;
yGyroRaw = T.yGyr;
zGyroRaw = T.zGyr;

magRaw = [xMagRaw,yMagRaw,zMagRaw];

%% Mag
[xMagCalib, yMagCalib, zMagCalib] = getMagCalib(magRaw);


%% Acc
Ts = 0.02;
GRAVITY_FREQUENCY = 0.5; % 1Hz
COEFF_GRAVITY_LP = Ts*2*3.14*GRAVITY_FREQUENCY;

[xgAccel,ygAccel,zgAccel] = getGravityAccel(xAccelRaw, yAccelRaw, zAccelRaw, COEFF_GRAVITY_LP);


%% Gyr
LP_FREQUENCY = 0.5; % 1Hz
COEFF_GYRO_LP = Ts*2*3.14*LP_FREQUENCY;

[xGyroCalib, yGyroCalib, zGyroCalib] = getGyroCalib(xGyroRaw, yGyroRaw, zGyroRaw, COEFF_GYRO_LP);


%% Merge
MAG = 60;
gAccel = [xgAccel, ygAccel, zgAccel]';
magCalib = [xMagCalib, yMagCalib, zMagCalib]';
magCalib = magCalib/MAG;


%% Absolute Heading M1
[thetaAbs, phiAbs, psiAbs, qaAbs] = getHeadingAbs(gAccel, magCalib);


%% Relative Heading: Angular Rate
[thetaRel, phiRel, psiRel, FkRel] = getHeadingRel(xGyroCalib, yGyroCalib, zGyroCalib, Ts);


%% Fusion
DELAY_STEPS = 50;
[thetaFused, phiFused, psiFused] = getHeadingFusion(qaAbs, FkRel, DELAY_STEPS);

%% Plot
figure; grid on; hold on;
plot(t, psiRel + psiAbs(DELAY_STEPS), 'Linewidth',2);
plot(t, psiAbs, 'Linewidth',1);
plot(t, psiFused, '-', 'Linewidth',1);

xlabel('Time(s)');
ylabel('Orientation(deg)');
title('Heading Estimation');
legend on; 
legend('Realative Heading Offset', 'Absolute Heading', 'Fusion Heading');
set(gca,'color',[0.92;0.92;0.92]);
set(gcf,'color','w');


