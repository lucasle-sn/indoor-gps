%% Get Directional Cosine Angle from Euler angles
function C = getDCMEuler(theta,phi,psi)
    C32 = [cosd(phi), 0, -sind(phi);...
            0, 1, 0; ...
            sind(phi), 0, cosd(phi)];
    C21 = [1,0,0;...
            0, cosd(theta), sind(theta); ...
            0, -sind(theta), cosd(theta)];
    C10 = [cosd(psi) sind(psi) 0; ...
            -sind(psi), cosd(psi), 0; ...
            0, 0, 1];
    
    C = C32*C21*C10;
end
