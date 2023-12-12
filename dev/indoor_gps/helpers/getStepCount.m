%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le (987445)


%% FUNCTION
function [stepCount,peakTime,peakMag, distanceM1, distanceM2, distanceAllM1, distanceAllM2] = getStepCount(mag)

    avgVel = 0;
    HEIGHT = 1.8;

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


    count2s = 0;
    distanceM1 = 0;
    distanceAllM1 = zeros(1,len);
    for i=1:len
        if (peakMag(i)>0)
            count2s = count2s+1;
        end
        
        if (mod(i-1,100) == 0)
            stride2s = getStride2sM1(count2s,HEIGHT);
            distanceM1 = distanceM1 + stride2s*count2s;
            count2s = 0;
        end
        
        distanceAllM1(i) = distanceM1;
    end
    
    
    count2s = 0;
    distanceM2 = 0;
    distanceAllM2 = zeros(1,len);
    for i=1:len
        if (peakMag(i)>0)
            count2s = count2s+1;
        end
        
        if (mod(i-1,100) == 0)
            stride2s = getStride2sM2(count2s,HEIGHT);
            distanceM2 = distanceM2 + stride2s*count2s;
            count2s = 0;
        end
        
        distanceAllM2(i) = distanceM2;
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
  
