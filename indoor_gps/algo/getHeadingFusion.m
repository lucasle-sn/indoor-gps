%% Fuse Absolute and Relative heading
% 
% Simple algorithm fusing absolute and relative heading using Kalman filter
%
% @param qaAbs Quaternion form of Absolute heading [4*N]
% @param FkRel F_k coefficient in SSM (q_k=F_k*q_(k-1)) [4*4N] 
% @param delay Number of delayed steps to prevent heading bias 
% @return thetaFused Estimated fused heading theta angle [1*N]
% @return phiFused Estimated fused heading phi angle [1*N]
% @return psiFused Estimated fused heading psi angle [1*N]
function [thetaFused, phiFused, psiFused] = getHeadingFusion(qaAbs,FkRel,delay)
    len = length(qaAbs(1,:));

    Q = 10^-10*eye(4);
    R = 10^-3*eye(4);  
%     R = 1.0e-03 *...
%             [0.0004   -0.0022    0.0052   -0.0001;...
%            -0.0022    0.0380   -0.0923    0.0003;...
%             0.0052   -0.0923    0.2247   -0.0008;...
%            -0.0001    0.0003   -0.0008    0.0002];
    Ts = 0.02;

    PkAll = zeros(4,4);
    qkAll = [];
    C = eye(4);
    
    for i=1:delay-1
        qk = qaAbs(:,delay);
        qkAll = [qkAll, qk];
        PkAll = [PkAll zeros(4,4)];
    end
    
    for i = delay:len
        Pk = PkAll(:,(4*i-7):(4*i-4));
        A = FkRel(:,(4*i-3):(4*i));
        qk = qkAll(:,i-1);
% 
%         Sq = [0 -qk(4) qk(3); qk(4) 0 -qk(2); -qk(3) qk(2) 0];
%         Ohm = -Ts/2*[Sq + qk(1)*eye(3); -qk(2:4)'];
%         Q = Ohm*10^-2*eye(3)*Ohm';

        qkn = A*qk;
        Pkn = A*Pk*A' + Q;

        Kk = (Pkn*C')/(C*Pkn*C'+R);

        qk = qkn + Kk*(qaAbs(:,i) - C*qkn);
        Pk = (eye(4)-Kk*C)*Pkn;

        qkAll = [qkAll, qk];
        PkAll = [PkAll, Pk];
    end
    
    
    %% Get Angles
    thetaFused = zeros(1,len);
    phiFused = zeros(1,len);
    psiFused = zeros(1,len);

    for i = 1:len
        [theta, phi, psi] = getQuaternionAngle(qkAll(:,i));

        thetaFused(i) = theta;
        phiFused(i) = phi;
        psiFused(i) = psi;
    end
end
