%% Get Absolute Heading
% 
% A simple algorithm to estimate absolute heading
%
% @param gravity Gravity acceleration element [3*N]
% @param magnetics Magnetic signals [3*N]
% @return thetaAbs Absolute heading theta angle [1*N]
% @return phiAbs Absolute heading phi angle [1*N]
% @return psiAbs Absolute heading psi angle [1*N]
% @return qaAbs Absolute heading in Quaternion [4*N]
function [thetaAbs, phiAbs, psiAbs, qaAbs] = getHeadingAbs(gravity, magnetics)
    len = length(gravity(1,:));

    qaAbs = [];

    thetaAbs = [];
    psiAbs = [];
    phiAbs = [];

    for i = 1:len  
        r3 = gravity(:,i);
        r2 = cross(gravity(:,i), magnetics(:,i));
        r1 = cross(r2,r3);

        r3 = r3/norm(r3);
        r2 = r2/norm(r2);
        r1 = r1/norm(r1);

        C = [r1 r2 r3];
        C = C*[0,1,0; 1,0,0; 0,0,-1];


        [psi,theta,phi] = getEulerAngle(C);
        psiAbs = [psiAbs psi];
        thetaAbs = [thetaAbs theta];
        phiAbs = [phiAbs phi];

        q = getUnitQuaternion(C);
        qaAbs = [qaAbs q];
    end
end
