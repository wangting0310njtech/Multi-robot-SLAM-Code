function simrobot = LLC(simrobot,xEnt,dist)

xy0 = getpos(simrobot);

xy1 = xEnt;

distT = sqrt((xy0(1,1)-xy1(1,1))^2+(xy0(1,2)-xy1(1,2))^2);



rot = atan2(xy1(2)-xy0(2),xy1(1)-xy0(1))*180/pi;
if (rot<0)
    rot = 360 + rot;
end

ang = gethead(simrobot);

angR = rot - ang;

if (abs(angR) > 180)
    angR = angR - (angR/abs(angR))*360;
end

tr=0.7;
tl=0.7;

if angR > 5
    tl=0.4;
    tr=0.9;
elseif angR < -5
    tl=0.9;
    tr=0.4;
end

[a,b] = min(dist);

if a(1) > 10 || sum(a)==0
    simrobot = setvel(simrobot,[tl tr]);
elseif b(1)>length(dist)/2 - 1
    simrobot = setvel(simrobot,[-1.6 1.6]);
else
    simrobot = setvel(simrobot,[-1.6 1.6]);
end
    

