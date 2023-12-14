%% Get Acceleration magnitude
% @return acceleration magnitude
function accMag = getAccelMagnitude(xAcc, yAcc, zAcc)
    accMag = sqrt(xAcc.^2 + yAcc.^2 + zAcc.^2);
end
