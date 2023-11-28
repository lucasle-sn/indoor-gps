%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le

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


%% Read data
% T = readtable('../data/sample.csv');
T = readtable('../data/slow_walk/SW(2).csv');
t = T.time';
len = length(t);
xAcc = T.xAcc';
yAcc = T.yAcc';
zAcc = T.zAcc';


%% Init data
% Chosen sampling time and frequency 
Ts = 0.02;
Fs = 1/Ts;

% Step frequency at normal movement is 0.5-3Hz (0.33s-2s per step)
MAX_FREQUENCY = 3;
MIN_FREQUENCY = 0.5;


coeffLP = Ts*2*pi*MAX_FREQUENCY;
coeffHP = Ts*2*pi*MIN_FREQUENCY;

% Frequency of Low-pass filter for gravity (Hz)
% This is used to filter out gravity element (g) from acceleration 
coeffLPg = 0.025; 


%% Algorithm
accelMag = getAccelMagnitude(xAcc, yAcc, zAcc);
bandPassAccelMag = getBandPass(accelMag, coeffLPg, coeffLP);


%% Step Count
THR_ACCEL_MAG = 0.1; %coeffLP = 0.63 - LP only
THR_INTERVAL_MIN = 16.67;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR_ACCEL_MAG - 1)/2*0;
save thrStepCount THR_ACCEL_MAG THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN


%% Method 1
% [stepCount,peakTime,peakMag] = getStepCountAlgo1(bandPassAccelMag);
% plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
% plot(t,bandPassAccelMag,'Linewidth',1);
% plot(t,THR_ACCEL_MAG*ones(1,len),'--m','Linewidth',1);

%% Method 2
[stepCount,peakTime,peakMag] = getStepCountAlgo2(bandPassAccelMag);
plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,bandPassAccelMag,'Linewidth',1);
plot(t,THR_ACCEL_MAG*ones(1,len),'--m','Linewidth',1);

% Show peaks
count = 0;
for i = 1:len
    if peakMag(i) > 0
        count = count+1;
        plot(t(i),peakMag(i), 'og', 'MarkerSize',10, 'Linewidth',1.5);
    end
end




%% ========================= FUNCTIONS =========================
%% Get band pass
% @return a vector of band pass filtered signal
function bandPassSignal = getBandPass(signal, lowerFreqFilterCoeff, upperFreqFilterCoeff)
    len = length(signal);

    lowerFreqLowPassSignal = ones(1,len);
    lowerFreqHighPassSignal = zeros(1,len);
    bandPassSignal = zeros(1,len);
    for i=1:len-1
        lowerFreqLowPassSignal(i+1) = (1-lowerFreqFilterCoeff)*lowerFreqLowPassSignal(i) + lowerFreqFilterCoeff*signal(i);
        lowerFreqHighPassSignal(i) = signal(i)-lowerFreqLowPassSignal(i);
        % Apply low pass filter with upper Freq on a high passed signal 
        bandPassSignal(i+1) = (1-upperFreqFilterCoeff)*bandPassSignal(i) + upperFreqFilterCoeff*lowerFreqHighPassSignal(i);
    end
end


%% Figure
% Plot Figure with given title, x label & y label
function plotFigure(titleText, xlabelText, ylabelText)
    figure; hold on; grid on;
    title(titleText);
    xlabel(xlabelText);
    ylabel(ylabelText);
end


%% Get data
% @return acceleration magnitude
function accMag = getAccelMagnitude(xAcc, yAcc, zAcc)
    accMag = sqrt(xAcc.^2 + yAcc.^2 + zAcc.^2);
end


%% Step count Algorithm
function [stepCount,peakTime,peakMag] = getStepCountAlgo1(accelMag)
    % A peak is detected as:
    %  (1) at the occurence of a jump in acceleration magnitude (drop at the other slope)
    %  (2) distance between peaks = [THR_INTERVAL_MIN ; THR_INTERVAL_MAX]
    %  (3) magnitude of the peak is > threshold
    % For the 1st peak, the distance between peaks rule is not applied

    load thrStepCount THR_ACCEL_MAG THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(accelMag);
    stepFoundFlag = false; % Flag to check if step is detected
    firstStepFlag = false; % Flag to check if this is the 1st step
    stepCount = 0; % Number of step counter
    
    peakTime = [];      % store timestamp of accel magnitude peak
    peakMag = zeros(1,len); % store peak accel magnitude
    lastPeakTime = 0;   % store timestamp of last peak

    for i=1:len-1
        % New walk -> reset 1st step check flag
        if (firstStepFlag && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakMag(lastPeakTime) = 0;
            firstStepFlag = false;
        end

        if (stepFoundFlag && (accelMag(i) - accelMag(i-1) <= THR_SLOPE_MIN) && ((i-1)-lastPeakTime>= THR_INTERVAL_MIN))
            % Check if this is the 1st step
            if (firstStepFlag == false)
                firstStepFlag = ((i-1) - lastPeakTime > THR_INTERVAL_MAX);
            else
                firstStepFlag = false;
            end
            
            
            lastPeakTime = i-1;
            stepCount = stepCount+1;
            peakTime = [peakTime lastPeakTime];
            peakMag(lastPeakTime) = accelMag(lastPeakTime);
        end
        
        stepFoundFlag = (accelMag(i) >= THR_ACCEL_MAG); % rule (3)
    end
end

%% Step Count Algorithm updated
function [stepCount,peakTime,peakMag] = getStepCountAlgo2(accelMag)
    % A peak is detected as:
    %  (1) at the occurence of a jump in acceleration magnitude (drop at the other slope)
    %  (2) distance between peaks = [THR_INTERVAL_MIN ; THR_INTERVAL_MAX]
    %  (3) magnitude of the peak is > threshold
    %  (4) peak is updated within THR_INTERVAL_MIN
    % For the 1st peak, the distance between peaks rule is not applied

    load thrStepCount THR_ACCEL_MAG THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(accelMag);
    stepFoundFlag = false; % Flag to check if step is detected
    firstStepFlag = false; % Flag to check if this is the 1st step
    stepCount = 0; % Number of step counter
    
    peakTime = [];      % store timestamp of accel magnitude peak
    peakMag = zeros(1,len); % store peak accel magnitude
    lastPeakTime = 0;   % store timestamp of last peak
    
    lastMaximaTime = 0; % store timestamp of the last maxima
    maximaFoundFlag = false; % Flag to check if a maxima found
    realPeakFoundFlag = true; % Flag to check if the peak is updated
    
    for i=1:len-1
        % New walk -> reset 1st step check flag
        if (firstStepFlag && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakMag(lastPeakTime) = 0;
            firstStepFlag = false;
        end
        
        if (accelMag(i) >= THR_ACCEL_MAG)
            stepFoundFlag = true; % rule (3)
        else
            stepFoundFlag = false;
            if (realPeakFoundFlag == false)
                firstStepFlag = (lastMaximaTime - lastPeakTime > THR_INTERVAL_MAX);
                updatePeak();   
                realPeakFoundFlag = true;
            end
            maximaFoundFlag = false;
%             realPeakFoundFlag = true;
        end
        
        % rule (1) and rule (2)
        if (stepFoundFlag && (accelMag(i) - accelMag(i-1) <= THR_SLOPE_MIN) ... 
                && ((i-1) - lastPeakTime >= THR_INTERVAL_MIN))
            newMaximaTime = i-1;
            realPeakFoundFlag = false;
            
            if (maximaFoundFlag == false)
                lastMaximaTime = newMaximaTime;
                maximaFoundFlag = true;
            else
                % rule (4)
                if ((newMaximaTime - lastMaximaTime < THR_INTERVAL_MIN) ...
                        && (accelMag(lastMaximaTime) < accelMag(newMaximaTime)))
                    lastMaximaTime = newMaximaTime;
                else
                    firstStepFlag = (lastMaximaTime - lastPeakTime > THR_INTERVAL_MAX);
                    updatePeak();
                    realPeakFoundFlag = true;
                    lastMaximaTime = newMaximaTime;
                end
            end
            
%             if (newMaximaTime-lastPeakTime>= THR_INTERVAL_MIN)
%                 if (newMaximaTime - lastPeakTime > THR_INTERVAL_MAX)
%                     firstStepFlag = true;
%                 else
%                     firstStepFlag = false;
%                 end
%             
%                 lastPeakTime = newMaximaTime;
%                 peakTime = [peakTime lastPeakTime];
%                 peakMag(lastPeakTime) = mag(lastPeakTime);
%                 stepCount = stepCount+1;
%             end
        end
    end
    
    
    function updatePeak()
        % Set maxima as peak
        lastPeakTime = lastMaximaTime;
        
        peakTime = [peakTime lastPeakTime];
        peakMag(lastPeakTime) = accelMag(lastPeakTime);
        stepCount = stepCount + 1;
    end
    
end
    

