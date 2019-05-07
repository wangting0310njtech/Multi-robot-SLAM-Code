function [xspeed, yspeed, rotspd] = mmodel(omega1, omega2, heading)

% Model constants, keep consistent with those ones in invmodel.m!
R = 1;
la = 3;
lb = 0;

sps = 1;	% Steps per second

vx = (R/(2*la))*(-lb*omega1 + lb*omega2);
vy = (R/(2*la))*(-la*omega1 - la*omega2);

% Convert degrees to radians
heading = pi*heading/180;											

% vx and vy are in robot's coordinate system -> need conversion to 'global' coordinates
xspeed = (vx * cos(heading + pi) + vy * cos(heading + pi)) / sps;
yspeed = (vx * sin(heading + pi) + vy * sin(heading + pi)) / sps;
% rotspd has to be converted into degrees per second (used in update.m)
rotspd = ((R/(2*la))*(-omega1 + omega2)*180/pi) / sps;
