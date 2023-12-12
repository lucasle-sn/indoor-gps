%% Get Gyroscope calibration
%
% Calibrate Gyroscope using Low Pass filter
%
% @param xGyroRaw Raw Gyroscope data in x axis [N*1]
% @param yGyroRaw Raw Gyroscope data in y axis [N*1]
% @param zGyroRaw Raw Gyroscope data in z axis [N*1]
% @param COEFF_GYR_LP Lowpass filter coefficient
% @return xGyro Gyroscope in x axis [N*1]
% @return yGyro Gyroscope in y axis [N*1]
% @return zGyro Gyroscope in z axis [N*1]
function [xGyro, yGyro, zGyro] = getGyroCalib(xGyroRaw, yGyroRaw, zGyroRaw, COEFF_GYRO_LP)
    %% Gyr
    len = length(xGyroRaw);
    
    xGyro = zeros(len,1);
    yGyro = zeros(len,1);
    zGyro = zeros(len,1);

    for i=1:len-1
        xGyro(i+1) = (1-COEFF_GYRO_LP)*xGyro(i) + COEFF_GYRO_LP*xGyroRaw(i);
        yGyro(i+1) = (1-COEFF_GYRO_LP)*yGyro(i) + COEFF_GYRO_LP*yGyroRaw(i);
        zGyro(i+1) = (1-COEFF_GYRO_LP)*zGyro(i) + COEFF_GYRO_LP*zGyroRaw(i);    
    end
end
