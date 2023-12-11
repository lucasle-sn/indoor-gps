%% Get Euler angles from Directional Cosine Matrix
function [psi,theta,phi] = getEulerAngle(C)
    theta = asind(C(2,3));
    phi = atan2d(-C(1,3),C(3,3));
    psi = atan2d(-C(2,1),C(2,2));
end
