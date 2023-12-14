%% Get Travelled distance and step counters
%
% @param accelMag Magnitude of Acceleration [1*N]
% @return stepCount Step counter
% @return peakTime Predicted step timestamp [1*M]
% @return peakAccelMag Acceleration magnitude of predicted step [1*M]
% @return totalDistanceM1 Travelled distance using method 1
% @return totalDistanceM2 Travelled distance using method 2
% @return totalDistanceM1 Travelled distance using method 1 over time [1*N]
% @return totalDistanceM2 Travelled distance using method 2 over time [1*N]
function [stepCount, peakTime, peakAccelMag, totalDistanceM1, totalDistanceM2, distancesM1, distancesM2] = getStepCount(accelMag)

    avgVel = 0;
    HEIGHT = 1.8;

    load thrStepCount THR THR_INTERVAL_MIN THR_INTERVAL_MAX THR_SLOPE_MIN

    len = length(accelMag);
    
    
    stepCheckFlag = false;
    firstStepCheckFlag = false;
    stepCount = 0;
    

    peakTime = [];
    peakAccelMag = zeros(1,len);
    lastPeakTime = 0;
    
    
    lastMaximaTime = 0;
    maximaCheckFlag = false;
    
    realPeakUpdated = true;
    
    for i=1:len-1
        if (firstStepCheckFlag == true && (i - lastPeakTime > THR_INTERVAL_MAX))
            stepCount = stepCount-1;
            peakAccelMag(lastPeakTime) = 0;
            firstStepCheckFlag = false;
        end
        
        if (accelMag(i) >= THR)
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
        

        if (stepCheckFlag == true && (accelMag(i)- accelMag(i-1) <= THR_SLOPE_MIN) && ((i-1)-lastPeakTime>= THR_INTERVAL_MIN))
            
                newMaximaTime = i-1;
                realPeakUpdated = false;
                
                if (maximaCheckFlag == false)
                    lastMaximaTime = newMaximaTime;
                    maximaCheckFlag = true;
                else
                    if (newMaximaTime - lastMaximaTime < THR_INTERVAL_MIN)
                        if (accelMag(lastMaximaTime) < accelMag(newMaximaTime))
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
        peakAccelMag(lastPeakTime) = accelMag(lastPeakTime);
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


    count2s = 0;
    totalDistanceM1 = 0;
    distancesM1 = zeros(1,len);
    for i=1:len
        if (peakAccelMag(i)>0)
            count2s = count2s+1;
        end
        
        if (mod(i-1,100) == 0)
            stride2s = getStride2sM1(count2s,HEIGHT);
            totalDistanceM1 = totalDistanceM1 + stride2s*count2s;
            count2s = 0;
        end
        
        distancesM1(i) = totalDistanceM1;
    end
    
    
    count2s = 0;
    totalDistanceM2 = 0;
    distancesM2 = zeros(1,len);
    for i=1:len
        if (peakAccelMag(i)>0)
            count2s = count2s+1;
        end
        
        if (mod(i-1,100) == 0)
            stride2s = getStride2sM2(count2s,HEIGHT);
            totalDistanceM2 = totalDistanceM2 + stride2s*count2s;
            count2s = 0;
        end
        
        distancesM2(i) = totalDistanceM2;
    end

    
end
    

function stride2s = getStride2sM1(count2s, height)
   switch count2s
       case 0
           stride2s = 0;
       case 1
           stride2s = height/5;
       case 2
           stride2s = height/4;
       case 3
           stride2s = height/3;
       case 4
           stride2s = height/2;
       case 5
           stride2s = height/1.2;
       case 6
           stride2s = height;
       case 7
           stride2s = height;
       otherwise
           stride2s = height*1.2;
   end

%    stride2s = stride2s*2;
end
    
function stride2s = getStride2sM2(count2s, height)
   switch count2s
       case 0
           stride2s = 0;
       case 1
           stride2s = height/5;
       case 2
           stride2s = height/3;
       case 3
           stride2s = height/3;
       case 4
           stride2s = height/2.5;
       case 5
           stride2s = height/2;
       case 6
           stride2s = height/1.5;
       case 7
           stride2s = height/1.5;
       otherwise
           stride2s = height/1.5;
   end

%    stride2s = stride2s*2;
end
  
function stride2s = getStride2sM3(count2s, height)
   switch count2s
       case 0
           stride2s = 0;
       case 1
           stride2s = height/5;
       case 2
           stride2s = height/3;
       case 3
           stride2s = height/3;
       case 4
           stride2s = height/2.5;
       case 5
           stride2s = height/2;
       case 6
           stride2s = height/1.5;
       case 7
           stride2s = height/1.5;
       otherwise
           stride2s = height/1.5;
   end

%    stride2s = stride2s*2;
end
  
