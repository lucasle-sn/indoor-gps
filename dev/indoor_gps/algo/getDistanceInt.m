%% Get travel distence based on integral

% A simple algoorithm to estimate travel distance base on integral
% technique

% @param accelMag Acceleration magnitude [N*1]
% @param peakAccelMag Peak acceleration magnitude detected [M*1]
% @param sampling_time Sampling time
% @return distance Estimated traveled distance over time [N*1]
% @return total_distance Estimated travelled distance [1*1]
function [distance, total_distance] = getDistanceInt(accelMag, peakAccelMag, sampling_time)
    len = length(accelMag);

    ACCEL_GRAVITY = 9.81; % Gravity acceleration
    accelMag = accelMag*ACCEL_GRAVITY;

    step = zeros(1,len);
    lastPeak = 0;
    N=100;
    for i=1:len
        if (peakAccelMag(i) ~= 0)
            step(i) = 1;
            lastPeak = i;
            if (i>=N)
                for j=i-N+1:i
                    step(j) = 1;
                end
            else
                for j=1:i
                    step(j) = 1;
                end
            end
        else 
            if(i-lastPeak < N && lastPeak ~= 0)
                step(i) = 1;
            else
                step(i) = 0;
            end
        end
    end

    x = zeros(1,len);
    for i=1:len-2
        if (step(i) == 1)
            x(i+2) = 2*x(i+1) - x(i) + sampling_time^2*(accelMag(i));
        else
            x(i+2) = x(i+1);
        end
    end
    distance = x(len);
    total_distance = x;

end
