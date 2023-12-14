%% Extract gravity element in accelerations
%
% @param xAccel Acceleration in x axis [N*1]
% @param yAccel Acceleration in y axis [N*1]
% @param zAccel Acceleration in z axis [N*1]
% @param COEFF_GRAVITY_LP Lowpass filter coefficient to get gravity
% @return xgAccel Gravity in x axis [N*1]
% @return ygAccel Gravity in y axis [N*1]
% @return zgAccel Gravity in z axis [N*1]
function [xgAccel, ygAccel, zgAccel] = getGravityAccel(xAccel, yAccel, zAccel, COEFF_GRAVITY_LP)
    len = length(xAccel);

    xgAccel = zeros(len,1);
    ygAccel = zeros(len,1);
    zgAccel = -ones(len,1);
    accMag = zeros(len,1);

    for i=1:len-1
        xgAccel(i+1) = (1-COEFF_GRAVITY_LP)*xgAccel(i) + COEFF_GRAVITY_LP*xAccel(i);
        ygAccel(i+1) = (1-COEFF_GRAVITY_LP)*ygAccel(i) + COEFF_GRAVITY_LP*yAccel(i);
        zgAccel(i+1) = (1-COEFF_GRAVITY_LP)*zgAccel(i) + COEFF_GRAVITY_LP*zAccel(i);
        accMag(i+1) = sqrt(xgAccel(i+1)^2 + ygAccel(i+1)^2 + zgAccel(i+1)^2);

        xgAccel(i+1) = xgAccel(i+1)/accMag(i+1);
        ygAccel(i+1) = ygAccel(i+1)/accMag(i+1);
        zgAccel(i+1) = zgAccel(i+1)/accMag(i+1);
    end
end

