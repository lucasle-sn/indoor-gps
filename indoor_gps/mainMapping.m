%% AUTHORSHIP STATEMENT
% The University of Melbourne
% School of Engineering
% MCEN90032 Sensor Systems
% Author: Quang Trung Le (987445)


clear
close all
clc

addpath(genpath('SubFunctions'));

%% Read data
filename = 'exp.csv';
T = readtable(filename);
t = T.time;
len = length(t);


%% Interpolate the distance
distance = zeros(1,len);
for i=2:len
    delta = T.distanceM2(i)-T.distanceM2(i-1);
    if (delta~=0)
        for j=i-100+1:i
            distance(j) = distance(j-1) + delta/100;
        end
    else 
        distance(i) = distance(i-1);
    end
end

deltaDist = zeros(1,len);
for i=2:len
    deltaDist(i) = distance(i) - distance(i-1);
end


%% Walking area
angleMap = 13;
width = 2.5; length = 4;
mapX = [0, width*cosd(angleMap), width*cosd(angleMap)+length*cosd(angleMap+90), length*cosd(angleMap+90), 0];
mapY = [0, width*sind(angleMap), width*sind(angleMap)+length*sind(angleMap+90), length*sind(angleMap+90), 0];

path1X = [0.5, 0.5+3*cosd(angleMap+90), 0.5+3*cosd(angleMap+90)+1.2*cosd(angleMap)];
path1Y = [0.5, 0.5+3*sind(angleMap+90), 0.5+3*sind(angleMap+90)+1.2*sind(angleMap)];

path2X = [0.5, 0.5+2*cosd(angleMap+75), 0.5+2*cosd(angleMap+75)+1*cosd(angleMap+75+90)];
path2Y = [0.5, 0.5+2*sind(angleMap+75), 0.5+2*sind(angleMap+75)+1*sind(angleMap+75+90)];


%% Calculate the Path
psi0 = T.psiAbs(1);
xKm=0.5*ones(2,len);
xAbs=0.5*ones(2,len);
xRel=0.5*ones(2,len);
for i = 1:len
    xKm(:,i+1) = xKm(:,i) + [deltaDist(i)*cosd(T.psiKm(i)); deltaDist(i)*sind(T.psiKm(i))];
end
for i = 1:len
    xAbs(:,i+1) = xAbs(:,i) + [deltaDist(i)*cosd(T.psiAbs(i)); deltaDist(i)*sind(T.psiAbs(i))];
end
for i = 1:len
    xRel(:,i+1) = xRel(:,i) + [deltaDist(i)*cosd(T.psiRel(i)+psi0); deltaDist(i)*sind(T.psiRel(i)+psi0)];
end


%% Plot
figure; 
subplot(1,2,1); hold on;  grid on;
% plot(path1X, path1Y, '-om', 'Linewidth',2);
plot(path2X, path2Y, '-om', 'Linewidth',2);
plot(mapX, mapY, '--b', 'Linewidth',2);


axis equal;
xlabel('North(m)');
ylabel('West(m)');
title('Expected Walking Path');
set(gca,'color',[0.92;0.92;0.92]);
set(gcf,'color','w');

subplot(1,2,2); hold on;  grid on;
plot(xRel(1,:),xRel(2,:) ,'Linewidth', 4);
plot(xAbs(1,:),xAbs(2,:), 'Linewidth', 2);
plot(xKm(1,:),xKm(2,:), 'Linewidth', 2);
axis equal;
xlabel('North(m)');
ylabel('West(m)');
title('Experimental Walking Path');

for i=1:len
    if mod(i,100)==1
        plot(xKm(1,i),xKm(2,i),'mo');
    end
end

plot(mapX, mapY, '--b', 'Linewidth',2);

set(gca,'color',[0.92;0.92;0.92]);
set(gcf,'color','w');
legend('Realative Heading Offset', 'Absolute Heading', 'Fusion Heading');





