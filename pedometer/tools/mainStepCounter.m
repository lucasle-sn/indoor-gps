%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le (987445)

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
T = readtable('../sample.csv');
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

% Frequency of Low-pass filter for gravity 
% This is used to filter out gravity element (g) from acceleration 
coeffLPg = 0.025; % 0.2Hz



%% Algorithm
mag = getAccelMagnitude(xAcc, yAcc, zAcc);

% Band pass 
mag_2 = ones(1,len);
mag_3 = zeros(1,len);
mag_4 = zeros(1,len);
for i=1:len-1
    mag_2(i+1) = (1-coeffLPg)*mag_2(i) + coeffLPg*mag(i);
    mag_3(i) = mag(i)-mag_2(i);
    mag_4(i+1) = (1-coeffLP)*mag_4(i) + coeffLP*mag_3(i);
end



%% Step Count
THR = 0.1; %coeffLP = 0.63 - LP only
THR_INTERVAL_MIN = 16.67;
THR_INTERVAL_MAX = 100; %2s/0.02 = 100
THR_SLOPE_MIN = -(THR - 1)/2*0;
save thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN


%% Method 1
[stepCount,peakTime,peakMag] = getStepCountM1(mag_4);
plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,mag_4,'Linewidth',1);
plot(t,THR*ones(1,len),'--m','Linewidth',1);


[stepCount,peakTime,peakMag] = getStepCountM2(mag_4);
plotFigure("Acceleration Magnitude", "Time (s)", "Acceleration (g)");
plot(t,mag_4,'Linewidth',1);
plot(t,THR*ones(1,len),'--m','Linewidth',1);

% Show peaks
count = 0;
for i = 1:len
    if peakMag(i) > 0
        count = count+1;
        plot(t(i),peakMag(i), 'og', 'MarkerSize',10, 'Linewidth',1.5);
    end
end




%% ========================= FUNCTIONS =========================
%% Figure
function plotFigure(titleText, xlabelText, ylabelText)
    figure; hold on; grid on;
    title(titleText);
    xlabel(xlabelText);
    ylabel(ylabelText);
end


%% Get data
function accMag = getAccelMagnitude(xAcc, yAcc, zAcc)
    accMag = sqrt(xAcc.^2 + yAcc.^2 + zAcc.^2);
end


%% Step count Algorithm
function [stepCount,peakTime,peakMag] = getStepCountM1(mag)

    load thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(mag);
    stepCheckFlag = false;
    firstStepCheckFlag = false;
    stepCount = 0;
    

    peakTime = [];
    peakMag = zeros(1,len);
    lastPeakTime = 0;
    
    
    for i=1:len-1
        if (firstStepCheckFlag == true && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakMag(lastPeakTime) = 0;
            firstStepCheckFlag = false;
        end
        

        if (stepCheckFlag == true && (mag(i)- mag(i-1) <= THR_SLOPE_MIN) && ((i-1)-lastPeakTime>= THR_INTERVAL_MIN))
            if (firstStepCheckFlag == false)
                if (i-1 - lastPeakTime > THR_INTERVAL_MAX)
                    firstStepCheckFlag = true;
                end
            else
                firstStepCheckFlag = false;
            end
            
            
            lastPeakTime = i-1;
            stepCount = stepCount+1;
            peakTime = [peakTime lastPeakTime];
            peakMag(lastPeakTime) = mag(lastPeakTime);
        end
        
        if (mag(i) >= THR)
            stepCheckFlag = true;
        else
            stepCheckFlag = false;
        end
    end
    
end

%% Step Count Algorithm updated
function [stepCount,peakTime,peakMag] = getStepCountM2(mag)

    load thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(mag);
    stepCheckFlag = false;
    firstStepCheckFlag = false;
    stepCount = 0;
    

    peakTime = [];
    peakMag = zeros(1,len);
    lastPeakTime = 0;
    
    
    lastMaximaTime = 0;
    maximaCheckFlag = false;
    
    realPeakUpdated = true;
    
    for i=1:len-1
        if (firstStepCheckFlag == true && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakMag(lastPeakTime) = 0;
            firstStepCheckFlag = false;
        end
        
        if (mag(i) >= THR)
            stepCheckFlag = true;
        else
            stepCheckFlag = false;
            if (realPeakUpdated == false)
                checkFirstPeak();
                updatePeak();          
            end
            maximaCheckFlag = false;
            realPeakUpdated = true;
        end
        

        if (stepCheckFlag == true && (mag(i)- mag(i-1) <= THR_SLOPE_MIN) && ((i-1)-lastPeakTime>= THR_INTERVAL_MIN))
            
                newMaximaTime = i-1;
                realPeakUpdated = false;
                
                if (maximaCheckFlag == false)
                    lastMaximaTime = newMaximaTime;
                    maximaCheckFlag = true;
                else
                    if (newMaximaTime - lastMaximaTime < THR_INTERVAL_MIN)
                        if (mag(lastMaximaTime) < mag(newMaximaTime))
                            lastMaximaTime = newMaximaTime;
                        end
                    else
                        checkFirstPeak();
                        updatePeak();
                        lastMaximaTime = newMaximaTime;
                    end
                end
            
%             if (newMaximaTime-lastPeakTime>= THR_INTERVAL_MIN)
%                 if (newMaximaTime - lastPeakTime > THR_INTERVAL_MAX)
%                     firstStepCheckFlag = true;
%                 else
%                     firstStepCheckFlag = false;
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
        lastPeakTime = lastMaximaTime;
        
        peakTime = [peakTime lastPeakTime];
        peakMag(lastPeakTime) = mag(lastPeakTime);
        stepCount = stepCount+1;

        realPeakUpdated = true;
    end

    function checkFirstPeak()
        if (lastMaximaTime - lastPeakTime > THR_INTERVAL_MAX)
            firstStepCheckFlag = true;
        else
            firstStepCheckFlag = false;
        end
    end
    
end
    

