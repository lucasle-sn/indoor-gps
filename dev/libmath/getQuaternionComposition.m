function Ohm = getQuaternionComposition(Q1)
    q0 = Q1(1);
    q1 = Q1(2);
    q2 = Q1(3);
    q3 = Q1(4);
    
    Ohm = [q0 -q1 -q2 -q3; ...
            q1 q0 q3 -q2; ...
            q2 -q3 q0 q1; ...
            q3 q2 -q1 q0];
end

    