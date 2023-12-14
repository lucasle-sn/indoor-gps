%% Step count Algorithm
function [stepCount,peakTime,peakMag] = getStepCountAlgoDep(accelMag)
    % A peak is detected as:
    %  (1) at the occurence of a jump in acceleration magnitude (drop at the other slope)
    %  (2) distance between peaks = [THR_INTERVAL_MIN ; THR_INTERVAL_MAX]
    %  (3) magnitude of the peak is > threshold
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

    for i=1:len-1
        % Lone peak detection -> false positive -> remove
        if (firstStepFlag && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakMag(lastPeakTime) = 0;
            firstStepFlag = false;
        end

        % rule (1) & (2)
        if (stepFoundFlag && (accelMag(i) - accelMag(i-1) <= THR_SLOPE_MIN) ...
                && ((i-1) - lastPeakTime >= THR_INTERVAL_MIN))
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
