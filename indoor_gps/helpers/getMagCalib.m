function [xMagCalib, yMagCalib, zMagCalib] = getMagCalib(mag)

    Cs =    [1.0089 0.0048 0.0038; ...
            0.0048 0.9921 -0.0027; ...
            0.0038 -0.0027 0.9991];
    dMag = [0.0538 0.0711 -0.2280];
    magCorrected = (mag-dMag)*Cs;

    xMagCalib = magCorrected(:,1);
    yMagCalib = magCorrected(:,2);
    zMagCalib = magCorrected(:,3);

end