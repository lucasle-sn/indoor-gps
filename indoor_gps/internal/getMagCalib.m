%% Get corrected magnetics after calibrated
%
% @param magRaw Raw magnetics [N*3]
% @return xMag Magnetics in x axis [N*1]
% @return yMag Magnetics in y axis [N*1]
% @return zMag Magnetics in z axis [N*1]
function [xMag, yMag, zMag] = getMagCalib(magRaw)

    Cs =    [1.0089 0.0048 0.0038; ...
            0.0048 0.9921 -0.0027; ...
            0.0038 -0.0027 0.9991];
    dMag = [0.0538 0.0711 -0.2280];
    magCorrected = (magRaw-dMag)*Cs;

    xMag = magCorrected(:,1);
    yMag = magCorrected(:,2);
    zMag = magCorrected(:,3);

end
