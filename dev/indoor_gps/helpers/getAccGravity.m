function [xgAcc,ygAcc,zgAcc] = getAccGravity(xAcc, yAcc, zAcc, COEFF_GRAVITY_LP)
    len = length(xAcc);

    xgAcc = zeros(len,1);
    ygAcc = zeros(len,1);
    zgAcc = -ones(len,1);
    accMag = zeros(len,1);

    for i=1:len-1
        xgAcc(i+1) = (1-COEFF_GRAVITY_LP)*xgAcc(i) + COEFF_GRAVITY_LP*xAcc(i);
        ygAcc(i+1) = (1-COEFF_GRAVITY_LP)*ygAcc(i) + COEFF_GRAVITY_LP*yAcc(i);
        zgAcc(i+1) = (1-COEFF_GRAVITY_LP)*zgAcc(i) + COEFF_GRAVITY_LP*zAcc(i);
        accMag(i+1) = sqrt(xgAcc(i+1)^2 + ygAcc(i+1)^2 + zgAcc(i+1)^2);

        xgAcc(i+1) = xgAcc(i+1)/accMag(i+1);
        ygAcc(i+1) = ygAcc(i+1)/accMag(i+1);
        zgAcc(i+1) = zgAcc(i+1)/accMag(i+1);
    end
end

