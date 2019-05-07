function [matrixout,xEnt,xFree,newcells] = mapping(simrobot, matrixin, dist, num, sensname)

    newcells=0;
%     matrixin = ones(size(matrix));

    matrixout=matrixin;

%     [simrobot.heading +  simrobot.heading + simrobot.sensors(i).axisangle + simrobot.sensors(i).scanangle/2 simrobot.sensors(i).resolution simrobot.sensors(i).range]

%     xy0 = getpos(simrobot);
%     
%     x = xy0(1,1)
%     y = xy0(1,2)
    
    pos = getpossens(simrobot,sensname);
    
    x = round(pos(1,1));
    y = round(pos(1,2));
    
    [begin_angle, end_angle, n_of_rays, range] = getsensdata(simrobot,sensname);
    
    ang = begin_angle;

%     matrixin(round(x),round(y))=0;
    
    iii=1;
    iv=1;
    xxyy = getpos(simrobot);
    
    tabxy2(iii,1:2)=[xxyy(1) xxyy(2)];
    tabxFree(iv,1:2) = [xxyy(1) xxyy(2)];
    
%     colll=[rand rand rand];
    % Translate and rotate scan to robot position
    for i = 1:n_of_rays
        % Compute end points of rays
        c = cosd(ang);
        s = sind(ang);
        ang = ang + (end_angle - begin_angle)/(n_of_rays);
        
        if (dist(i) < 999999) % it detected an obstacle or robot
            x2p = (dist(i)-range) * c;
            y2p = (dist(i)-range) * s;
            
            x2 = x + x2p;
            y2 = y + y2p;
            
            tabxFree(iv,1:2) = [x2 y2];
            iv = iv + 1;
        end
        
        if (dist(i) < 999999) && (num(i)== 1) % it detected an obstacle
            x2p = (1:dist(i)-1) * c;
            y2p = (1:dist(i)-1) * s;
            
            x2 = x + x2p;
            y2 = y + y2p;
            
            for ii=1:length(x2)
                % did the robot already discovered the vicinities of
                % this position?
%                 matAux = imdilate(not(matrixin),strel('diamond',3));
                if (matrixin(round(x2(ii)),round(y2(ii)))==1)
                    tabxy2(iii,1:2) = [x2(ii) y2(ii)];
                    iii=iii+1;
%                     if ((getnum(simrobot)-1)==1)
%                         hold on;
%                         plot(x2(ii),y2(ii),'.','Color',colll);
%                     end
                end
                matrixout(round(x2(ii)),round(y2(ii)))=0;
            end

%             hold on;
%             plot(round(x2),round(y2),'.');

        end
        if (dist(i) == 999999)  % it didn't detected anything
            x2p = (1:range-1) * c;
            y2p = (1:range-1) * s;

%             x2p = range .* c;
%             y2p = range .* s;
            
            x2 = x + x2p;
            y2 = y + y2p;
  
%             hold on;
%             plot(round(x2),round(y2),'.');
            
            for ii=1:length(x2)
                %undiscovered area so far
%                 if (isempty(find(matrixin(round(x2(ii))-0:round(x2(ii))+0,round(y2(ii))-0:round(y2(ii))+0)==0))==1)
                if (matrixin(round(x2(ii)),round(y2(ii)))==1)
                    tabxy2(iii,1:2) = [x2(ii) y2(ii)];
                    iii=iii+1;
%                     if ((getnum(simrobot)-1)==1)
%                         hold on;
%                         plot(x2(ii),y2(ii),'.','Color',colll);
%                     end
                end
                matrixout(round(x2(ii)),round(y2(ii)))=0;
            end
            
        end
 
    end
    
    
    if (iv<=2)
        xFree = tabxFree;
    elseif (iv>2)
        xFree = mean(tabxFree);
    end

        
    if (iii<=2)
        xEnt = tabxy2;
    else
        xEnt = mean(tabxy2);
    end
    
    newcells = length(tabxy2);
    
    