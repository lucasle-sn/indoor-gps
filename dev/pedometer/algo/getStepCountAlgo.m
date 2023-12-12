%% Step Count Algorithm updated
function [stepCount,peakTime,peakMag] = getStepCountAlgo(accelMag)
    % A peak is detected as:
    %  (1) at the occurence of a jump in acceleration magnitude (drop at the other slope)
    %  (2) distance between peaks = [THR_INTERVAL_MIN ; THR_INTERVAL_MAX]
    %  (3) magnitude of the peak is > threshold
    %  (4) peak is updated within THR_INTERVAL_MIN
    % For the 1st peak, the distance between peaks rule is not applied
    % If there is a lone peak, set it as false positive -> remove

    load thresholdStepCount THR_ACCEL_MAG THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(accelMag);
    stepFoundFlag = false;  % Flag to check if step is detected
    firstStepFlag = false;  % Flag to check if this is the 1st step
    stepCount = 0;          % Number of step counter
    
    peakTime = [];          % store timestamp of accel magnitude peak
    peakMag = zeros(1,len); % store peak accel magnitude
    lastPeakTime = 0;       % store timestamp of last peak
    
    lastMaximaTime = 0;         % store timestamp of the last maxima
    maximaFoundFlag = false;    % Flag to check if a maxima found
    
    for i=1:len-1
        % Lone peak detection -> false positive -> remove
        if (firstStepFlag && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount - 1;
            peakMag(lastPeakTime) = 0;
            firstStepFlag = false;
        end
        
        % According to rule (4), real peak is set if either:
        % (1) No other peak within time interval (as dealt later on)
        % (2) The accel magnitude drops < threshold after a maxima found 
        if (~stepFoundFlag)
            if (maximaFoundFlag)
                firstStepFlag = (lastMaximaTime - lastPeakTime > THR_INTERVAL_MAX);
                updatePeak();
                maximaFoundFlag = false;
            end
        end

        % rule (1) and rule (2)
        if (stepFoundFlag && (accelMag(i) - accelMag(i-1) <= THR_SLOPE_MIN) ... 
                && ((i-1) - lastPeakTime >= THR_INTERVAL_MIN))
            newMaximaTime = i-1;
            
            % If there was no maxima, set the new maxima as the candidate.
            % If found a 2nd maxima within Interval, compare new maxima vs the last maxima & update
            % If reaching to end of Interval, update the peak (force). 
            if (maximaFoundFlag == false)
                lastMaximaTime = newMaximaTime;
                maximaFoundFlag = true;
            else
                % rule (4)
                if (newMaximaTime - lastMaximaTime < THR_INTERVAL_MIN)
                    if (accelMag(newMaximaTime) > accelMag(lastMaximaTime))
                        lastMaximaTime = newMaximaTime;
                    end
                else
                    firstStepFlag = (lastMaximaTime - lastPeakTime > THR_INTERVAL_MAX);
                    updatePeak();
                    maximaFoundFlag = false;
                end
            end
        end

        stepFoundFlag = accelMag(i) >= THR_ACCEL_MAG; % rule (3)
    end
    
    function updatePeak()
        % Set maxima as peak
        lastPeakTime = lastMaximaTime;
        
        peakTime = [peakTime lastPeakTime];
        peakMag(lastPeakTime) = accelMag(lastPeakTime);
        stepCount = stepCount + 1;
    end
    
end