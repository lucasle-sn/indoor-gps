function [thetaAll, phiAll, psiAll, qamAll] = getHeadingAbsM1(gAcc, magCalib)
    len = length(gAcc(1,:));

    qamAll = [];

    thetaAll = [];
    psiAll = [];
    phiAll = [];

    for i = 1:len  
        r3 = gAcc(:,i);
        r2 = cross(gAcc(:,i), magCalib(:,i));
        r1 = cross(r2,r3);

        r3 = r3/norm(r3);
        r2 = r2/norm(r2);
        r1 = r1/norm(r1);

        C = [r1 r2 r3];
        C = C*[0,1,0; 1,0,0; 0,0,-1];


        [psi,theta,phi] = getEulerAngle(C);
        psiAll = [psiAll psi];
        thetaAll = [thetaAll theta];
        phiAll = [phiAll phi];

        q = getUnitQuaternion(C);
        qamAll = [qamAll q];
    end
end
