%% Get Relative Heading
% 
% A simple algorithm to estimate relative heading
%
% @param xGyro Gyroscope in x axis [N*1]
% @param yGyro Gyroscope in y axis [N*1]
% @param zGyro Gyroscope in z axis [N*1]
% @param sampling_time Sampling time (seconds)
% @return thetaRel Relative heading theta angle [1*N]
% @return phiRel Relative heading phi angle [1*N]
% @return psiRel Relative heading psi angle [1*N]
% @return FkRel F_k coefficient in SSM (q_k=F_k*q_(k-1)) [4*4N]
function [thetaRel, phiRel, psiRel, FkRel] = getHeadingRel(xGyro, yGyro, zGyro, sampling_time)
    len = length(xGyro);

    %% Calculation
    qw0 = [1;0;0;0];
    qwAll = qw0;
    FkRel = [];

    for i=1:len
        sw = [xGyro(i); yGyro(i); zGyro(i)];
        Fk = (eye(4)+sampling_time/2*getSkewSymMatrix(sw));
        qw = Fk*qwAll(:, i);

        FkRel = [FkRel Fk];
        qw = qw/norm(qw);
        qwAll = [qwAll qw];
    end

    %% Get Angles
    thetaRel = zeros(1,len);
    phiRel = zeros(1,len);
    psiRel = zeros(1,len);

    for i = 1:len
        [theta, phi, psi] = getQuaternionAngle(qwAll(:,i));

        thetaRel(i) = theta;
        phiRel(i) = phi;
        psiRel(i) = psi;
    end
end
