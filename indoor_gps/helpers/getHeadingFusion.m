function [theta4All, phi4All, psi4All] = getHeadingFusion(qamAll,FkAll, N)
    len = length(qamAll(1,:));

    Q = 10^-10*eye(4);
    R = 10^-3*eye(4);  
%     R = 1.0e-03 *...
%             [0.0004   -0.0022    0.0052   -0.0001;...
%            -0.0022    0.0380   -0.0923    0.0003;...
%             0.0052   -0.0923    0.2247   -0.0008;...
%            -0.0001    0.0003   -0.0008    0.0002];
    Ts = 0.02;

    PkAll = zeros(4,4);
%     qkAll = qamAll(:,1);
    qkAll = [];
    C = eye(4);
    
    for i=1:N-1
        qk = qamAll(:,N);
        qkAll = [qkAll, qk];
        PkAll = [PkAll zeros(4,4)];
    end
    
    for i = N:len
        Pk = PkAll(:,(4*i-7):(4*i-4));
        A = FkAll(:,(4*i-3):(4*i));
        qk = qkAll(:,i-1);
% 
%         Sq = [0 -qk(4) qk(3); qk(4) 0 -qk(2); -qk(3) qk(2) 0];
%         Ohm = -Ts/2*[Sq + qk(1)*eye(3); -qk(2:4)'];
%         Q = Ohm*10^-2*eye(3)*Ohm';

        qkn = A*qk;
        Pkn = A*Pk*A' + Q;

        Kk = (Pkn*C')/(C*Pkn*C'+R);

        qk = qkn + Kk*(qamAll(:,i) - C*qkn);
        Pk = (eye(4)-Kk*C)*Pkn;

        qkAll = [qkAll, qk];
        PkAll = [PkAll, Pk];
    end
    
    
    %% Get Angles
    theta4All = zeros(1,len);
    phi4All = zeros(1,len);
    psi4All = zeros(1,len);

    for i = 1:len
        [theta, phi, psi] = getQuaternionAngle(qkAll(:,i));

        theta4All(i) = theta;
        phi4All(i) = phi;
        psi4All(i) = psi;
    end
end
