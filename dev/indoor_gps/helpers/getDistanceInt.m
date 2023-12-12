%% Get travel distence based on integral
function [dist,y] = getDistanceInt(accelMag, peakMag, Ts)
    len = length(accelMag);

    ACCEL_GRAVITY = 9.81; % Gravity acceleration
    accelMag = accelMag*ACCEL_GRAVITY;

    step = zeros(1,len);
    lastPeak = 0;
    N=100;
    for i=1:len
        if (peakMag(i) ~= 0)
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
            x(i+2) = 2*x(i+1) - x(i) + Ts^2*(accelMag(i));
        else
            x(i+2) = x(i+1);
        end
    end
    dist = x(len);
    y = x;

end
