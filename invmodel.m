function [omega1,omega2] = invmodel(movspd,rotspd,heading)

% The argument 'heading' is there for backward compatibility
% Model constants, keep consistent with those ones in mmodel.m!
% rotspd - in radians per seccond
% movspd - in centimeters per second

R = 1;
la = 3;
lb = 0;

vx = 0;
vy = -movspd;

omega1 = 1/(R * (lb * lb + 1)) * (-la * lb * vx + (-lb * lb - 1) * vy - la * rotspd);
omega2 = 1/(R * (lb * lb + 1)) * (la * lb * vx + (-lb * lb - 1) * vy + la * rotspd);