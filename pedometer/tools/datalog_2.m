clear all
close all
clc


xAcc_text = "X Acceleration";
yAcc_text = "Y Acceleration";
zAcc_text = "Z Acceleration";
xAcc_calib_text = "X Calib Acceleration";
yAcc_calib_text = "Y Calib Acceleration";
zAcc_calib_text = "Z Calib Acceleration";
xAcc_linear_text = "X Linear Acceleration";
yAcc_linear_text = "Y Linear Acceleration";
zAcc_linear_text = "Z Linear Acceleration";

T = readtable('default(9).csv');
t = T.time';
len = length(t);
xAcc = T.xAcc';
yAcc = T.yAcc';
zAcc = T.zAcc';

coeffLP = 0.02;

[xAcc_calib,yAcc_calib,zAcc_calib] = getLPAcc(xAcc, yAcc, zAcc, coeffLP);
[xAcc_linear,yAcc_linear,zAcc_linear] = getLinearAcc(xAcc,yAcc,zAcc,xAcc_calib,yAcc_calib,zAcc_calib);


Ts = 0.02;
MAX_FREQUENCY = 3;
MIN_FREQUENCY = 1;
coeffLP = Ts*2*pi*MAX_FREQUENCY;
coeffHP = Ts*2*pi*MIN_FREQUENCY;


%% Magnitude
mag = zeros(1,len);
for i=1:len
    mag(i) = ((xAcc_linear(i)*xAcc_calib(i) + yAcc_linear(i)*yAcc_calib(i) + zAcc_linear(i)*zAcc_calib(i)));
end

mag2 = zeros(1,len);
mag3 = zeros(1,len);
for i=1:len-2
    mag2(i+1) = (1-coeffHP)*mag2(i) + mag(i+1) - mag(i);
    mag3(i+2) = (1-coeffLP)*mag3(i+1) + coeffLP*mag2(i+1);
end
% for i=1:len-1
%     mag3(i+1) = (1-coeffLP)*mag3(i) + coeffLP*mag2(i);
% end


%% Algorithm
THR = 0.03; %coeffLP = 0.63 - LP only
THR_WINDOW = 2; % 10*0.02 = 0.2s
THR_INTERVAL = 20;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR - 1)/2*0;
save thrStepCount THR THR_WINDOW THR_INTERVAL THR_INTERVAL_MAX THR_SLOPE_MIN

% [stepCount,peak,peakMag] = getStepCount(mag3);


%% Plot 
figure2("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,(mag3));


%% ========================= FUNCTIONS =========================
%% Figure
function figure2(titleText, xlabelText, ylabelText)
    figure; hold on; grid on;
    title(titleText);
    xlabel(xlabelText);
    ylabel(ylabelText);
end

function plotAcc(t, acc, accText)
    xAcc = acc(1,:);
    yAcc = acc(2,:);
    zAcc = acc(3,:);
    xAccText = accText(1);
    yAccText = accText(2);
    zAccText = accText(3);
    
    xAccPlot = plot(t,xAcc);
    yAccPlot = plot(t,yAcc);
    zAccPlot = plot(t,zAcc);
    legend(xAccText, yAccText, zAccText);
end


%% Get data
function [xAcc_calib,yAcc_calib,zAcc_calib] = getHPAcc(xAcc,yAcc,zAcc, coeffHP)
    len = length(xAcc);
    
    xAcc_calib = zeros(1,len);
    yAcc_calib = zeros(1,len);
    zAcc_calib = zeros(1,len);

%     for i=1:len-1
%         xAcc_calib(i+1) = coeffHP*(xAcc_calib(i) + xAcc(i+1) - xAcc(i));
%         yAcc_calib(i+1) = coeffHP*(yAcc_calib(i) + yAcc(i+1) - yAcc(i));
%         zAcc_calib(i+1) = coeffHP*(zAcc_calib(i) + zAcc(i+1) - zAcc(i));
%     end

    for i=1:len-1
        xAcc_calib(i+1) = (1-coeffHP)*xAcc_calib(i) + xAcc(i+1) - xAcc(i);
        yAcc_calib(i+1) = (1-coeffHP)*yAcc_calib(i) + yAcc(i+1) - yAcc(i);
        zAcc_calib(i+1) = (1-coeffHP)*zAcc_calib(i) + zAcc(i+1) - zAcc(i);
    end
end


function [xAcc_calib,yAcc_calib,zAcc_calib] = getLPAcc(xAcc,yAcc,zAcc, coeffLP)
    len = length(xAcc);
    
    xAcc_calib = zeros(1,len);
    yAcc_calib = zeros(1,len);
    zAcc_calib = zeros(1,len);
    
    % Low pass filter
    for i=1:len-1
        xAcc_calib(i+1) = (1-coeffLP)*xAcc_calib(i) + coeffLP*xAcc(i);
        yAcc_calib(i+1) = (1-coeffLP)*yAcc_calib(i) + coeffLP*yAcc(i);
        zAcc_calib(i+1) = (1-coeffLP)*zAcc_calib(i) + coeffLP*zAcc(i);
    end
end

function [xAcc_linear,yAcc_linear,zAcc_linear] = getLinearAcc(xAcc,yAcc,zAcc,xAcc_calib,yAcc_calib,zAcc_calib)
    xAcc_linear = xAcc - xAcc_calib;
    yAcc_linear = yAcc - yAcc_calib;
    zAcc_linear = zAcc - zAcc_calib;
end