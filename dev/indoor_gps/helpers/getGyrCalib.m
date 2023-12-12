%% Get Gyroscope calibration
% Calibrate Gyroscope using Low Pass filter
function [xGyrCalib, yGyrCalib, zGyrCalib] = getGyrCalib(xGyr, yGyr, zGyr, COEFF_GYR_LP)
    %% Gyr
    len = length(xGyr);
    
    xGyrCalib = zeros(len,1);
    yGyrCalib = zeros(len,1);
    zGyrCalib = zeros(len,1);

    for i=1:len-1
        xGyrCalib(i+1) = (1-COEFF_GYR_LP)*xGyrCalib(i) + COEFF_GYR_LP*xGyr(i);
        yGyrCalib(i+1) = (1-COEFF_GYR_LP)*yGyrCalib(i) + COEFF_GYR_LP*yGyr(i);
        zGyrCalib(i+1) = (1-COEFF_GYR_LP)*zGyrCalib(i) + COEFF_GYR_LP*zGyr(i);    
    end
end
