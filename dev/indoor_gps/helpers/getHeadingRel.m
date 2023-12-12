function [theta3All,phi3All,psi3All, FkAll] = getHeadingRel(xGyrCalib,yGyrCalib,zGyrCalib, Ts)
    len = length(xGyrCalib);

    %% Calculation
    qw0 = [1;0;0;0];
    qwAll = qw0;
    FkAll = [];

    for i=1:len
        sw = [xGyrCalib(i); yGyrCalib(i); zGyrCalib(i)];
        Fk = (eye(4)+Ts/2*getSkewSymMatrix(sw));
        qw = Fk*qwAll(:, i);

        FkAll = [FkAll Fk];
        qw = qw/norm(qw);
        qwAll = [qwAll qw];
    end
    


    %% Get Angles
    theta3All = zeros(1,len);
    phi3All = zeros(1,len);
    psi3All = zeros(1,len);

    for i = 1:len
        [theta, phi, psi] = getQuaternionAngle(qwAll(:,i));

        theta3All(i) = theta;
        phi3All(i) = phi;
        psi3All(i) = psi;
    end
end
