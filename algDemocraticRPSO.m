function [listout] = algDPSO(simrobot,list,matrix,step)


% your algorithm starts here ******************Democratic RPSO
%% modifications

% message.xgBest=(((N-1)*message.gBestValue*message.xgBest)+(buffer{i}.fMainBest*buffer{i}.xc))/(((N-1)*message.gBestValue)+1+buffer{i}.fMainBest);
% message.ygBest=(((N-1)*message.gBestValue*message.ygBest)+(buffer{i}.fMainBest*buffer{i}.yc))/(((N-1)*message.gBestValue)+1+buffer{i}.fMainBest);

%            ps=(message.gBestValue_t1-90)/500;  at 330
%            pc= 0.84 -abs(ps);
% only run the algorithm if it is a robot
if (strcmp(getnameR(simrobot),'PoI')==0) % if it is not a point of interest, then it is a robot

    % constant variables
    % Get number of robots
    Nrobots=0;
    jj=1;
    for j = 1:length(list)
        if (strcmp(getnameR(list(j)),'PoI')==0) % it is not a point of interest
            Nrobots=Nrobots+1;
            listAux(jj)=list(j);
            jj=jj+1;
        end
    end
    
    % Get robot ID
    robotid=0;
    for j = 1:length(listAux)
        if (getnum(simrobot)==getnum(listAux(j)))
            robotid=j;
        end
    end

    % choose number of swarms:
    N_SWARMS=2;    % initial
    MAX_SWARMS=3;  % maximum
    MIN_SWARMS=0;  % minimum - to allow the social exclusion of all robots

    % calculate number of robots in each swarm
    N_Init=5;    % initial number of robots in a swarm
    N_MAX=7;   % maximum number of robots in a swarm
    N_MIN=3;   % minimum number of robots in a swarm  

    % RDPSO coefficients
    fract = 0.65;    % fractional coefficient
    pc=0.5;  %cognitive weight
    ps=0.5;  %social weight
    pobs=0.35;  %obstacle susceptibility weight
    pgoal=0.35;  %goal constraint weight

    % maximum number of iterations without improving the swarm
    SCmax = 40;  % estava 40
    
    % maximum communication range
    RangeComm = 300; % estava 300

    % runs only in first iteration
    if (step == 1)  % it will only enter this condition in the first iteration of all
        message.matrixout = ones(size(matrix));  
        [begin_angle, end_angle, n_of_rays, range] = getsensdata(simrobot,'sens1');
        % initialize first step of patrolling
        message.firststep = [];
        message.idleness = [];
        message.intentions = [];
        message.positions = [];
        message.beginning = [];
        message.decision = [];
        message.previous = [];
        message.current = [];
        message.next = [];
        message.idl_current=[];
        message.visited=zeros(15,1);
        % memorize previous velocities
        message.vx = 0;
        message.vx_t1 = 0;
        message.vx_t2 = 0;
        message.vx_t3 = 0;
        message.vy = 0;
        message.vy_t1 = 0;
        message.vy_t2 = 0;
        message.vy_t3 = 0;
        % memorize number of "killed" robots in the swarm and the search
        % counter
        message.Nkill = 0;
        message.SC = 0;
        % memorize the need of calling a robot or create a new swarm
        message.callrobot=0;
        message.createswarm=0;
        % memorize swarm ID
        if (getcolor(simrobot)==[1 0 0])
            swarm = 1;
        elseif (getcolor(simrobot)==[0 1 0])
            swarm = 2;
        elseif (getcolor(simrobot)==[0 0 1])
            swarm = 3;
        elseif (getcolor(simrobot)==[0 0 0])
            swarm = 4;  % socially excluded swarm
        end
        message.swarm = swarm;
        % initialize best objective function so far as zero
        message.fMainBest = 0;
        message.gBestValue = 0;
        message.fObsBest = range;
        % initialize best cognitive, global and obstacle position as its own
        xyc = getpos(simrobot);
        message.xc = xyc(1);
        message.yc = xyc(2);
        message.xgBest = xyc(1);
        message.ygBest = xyc(2);
        message.xobs=xyc(1);
        message.yobs=xyc(2);
        % matrixout - mapping of matrix
        % save data to the memory of the robot
        simrobot = setdata(simrobot,getnum(simrobot)-1,message);
        % send data to teammates
        [ack,list] = exchangeData(simrobot,list,message,RangeComm,-1);
    else   % only run the algorithm after the first iteration of all robots so as to update the buffer
        %% check messages in the buffer of the robot
%         getnum(simrobot)-1
        buffer = getdata(simrobot);
        message = buffer{getnum(simrobot)-1};
        
        % update variables
        vx=message.vx;
        vx_t1=message.vx_t1;
        vx_t2=message.vx_t2;
        vx_t3=message.vx_t3;
        
        vy=message.vy;
        vy_t1=message.vy_t1;
        vy_t2=message.vy_t2;
        vy_t3=message.vy_t3;
        
        Nkill=message.Nkill;
        SC=message.SC;
        
        swarm=message.swarm;
        
%         swarm=1;
 
        %% update best global solution and get collective map
                
        matrixin=ones(size(matrix));
%         matrixin=zeros(size(matrix)); %estava com "ones"
        improve=0;
        N=0;    % number of robots within the swarm
        
        % see if there is any information on buffer
        for i=1:length(buffer)
            if (isempty(buffer{i})==0)
                % update shared map - the map is shared with all robots
                matrixin = matrixin.*buffer{i}.matrixout;
                % check broadcasts for any swarm that needs a robot or a
                % swarm
                callrobotswarm(i)=buffer{i}.callrobot;
                createswarmswarm(i)=buffer{i}.createswarm;
%                 if(buffer{i}.swarm==swarm)
                    % filter the data from its swarm
                    %                 if (i ~= getnum(simrobot)-1)
                    N=N+1;
                    xswarm(N)=buffer{i}.xc;
                    yswarm(N)=buffer{i}.yc;
                    fswarm(N)=buffer{i}.fMainBest;
                    numR(N)=i;
                    %                 callrobotswarm[nrobots]=buffer[i+4];
                    %                 createswarmswarm[nrobots]=buffer[i+5];
                    %                 end
                    % update the best solution of the whole swarm so far
%                     if (buffer{i}.fMainBest > message.gBestValue)
%                         message.xgBest=buffer{i}.xc;
%                         message.ygBest=buffer{i}.yc;
%                         message.gBestValue = buffer{i}.fMainBest;

                        message.xgBest=(((N-1)*message.gBestValue*message.xgBest)+(buffer{i}.fMainBest*buffer{i}.xc))/(((N-1)*message.gBestValue)+1+buffer{i}.fMainBest);
                        message.ygBest=(((N-1)*message.gBestValue*message.ygBest)+(buffer{i}.fMainBest*buffer{i}.yc))/(((N-1)*message.gBestValue)+1+buffer{i}.fMainBest);

                        message.gBestValue = (message.gBestValue*(N-1)+buffer{i}.fMainBest)/N;
%                         improve=1;  % swarm of this robot did improve

                         if (message.gBestValue > 120)
                            improve=1;  % swarm of this robot did improve
                         end
%                 end
            end
        end
        
        message.gBestValue_t1 = message.gBestValue;

        message.gBestValue=0;
        
        xgBest = message.xgBest;
        ygBest = message.ygBest;

        %% update best cognitive solution, update and share map
        
        % read laser
        [dist,num] = readlaser(simrobot,'sens1',matrix);
        
        
%         % Get Robots
%         clear listAux;
%         jj=1;
%         for j = 1:length(list)
%             if (strcmp(getnameR(list(j)),'PoI')==0) % it is not a point of interest
%                 listAux(jj)=list(j);
%                 jj=jj+1;
%             end
%         end
% 
%         Nexc=0;
%         for j = 1:length(listAux)
%             if (getcolor(listAux(j))==[0 0 0])
%                 Nexc=Nexc+1;
%             end
%         end
% % % % % % % % % % % % % no patrol        % %%++++++++++++++++++++++++
%         if (N==Nrobots) && (swarm==4)
%             simrobot = setvel(simrobot,[0 0]);
% 
%             if isempty(message.firststep)   %save patrol first step
%                 message.firststep = step;
%                 disp(['[Robot ' num2str(robotid) ']: Patrol Mode (Step  ' num2str(step) ')']);
%                 % save data to the memory of the robot
%                 simrobot = setdata(simrobot,getnum(simrobot)-1,message);
%             end
%             
%             [simrobot,message] = patrol4(simrobot,list,step,dist,message);    
% 
%         else   
            
            % map the surroundings
            [message.matrixout, xyc, xFree, newcells] = mapping(simrobot,matrixin,dist,num,'sens1');
            
            % update the map with all the information acquired so far
            message.matrixout = message.matrixout.*matrixin;
            
            xy0 = getpos(simrobot);
            x0=xy0(1);
            y0=xy0(2);
            
            x1 = xyc(1);
            y1 = xyc(2);
            
            %         distT = sqrt((x0-x1)^2+(y0-y1)^2);
            fMain = newcells;
            
            %         if (fMain >= message.fMainBest)
            
            if (fMain >= 70)
                message.fMainBest = fMain;
                improve=1;  % swarm of this robot did improve
            end
            
            message.xc = x1;
            message.yc = y1;
            
            xc = message.xc;
            yc = message.yc;
            
            %% update obstacle avoidance component
            
            x1 = xFree(1);
            y1 = xFree(2);
            
            distT = sqrt((x0-x1)^2+(y0-y1)^2);
            
            fObs = distT;
            
            % minimize obstacle detection
            %         if (fObs<=message.fObsBest)
            message.fObsBest=fObs;
            message.xobs=x1;
            message.yobs=y1;
            %         end
            
            xobs = message.xobs;
            yobs = message.yobs;
            
            %% chose closest neighboor to maintain communication with it
            
            % This robot is the fist element of the swarm
            %         xswarm(1) = x0;
            %         yswarm(1) = y0;
            
            % force robots to be at a distance less or equal the range of communication
            if (N>1)
                distanceR=zeros(N,N);
                angleR=zeros(N,N);
                
                for (ii=1:N)
                    for (iii=1:N)
                        distanceR(ii,iii)=sqrt((xswarm(ii)-xswarm(iii))^2+(yswarm(ii)-yswarm(iii))^2);
                        angleR(ii,iii)=atan2((yswarm(iii)-yswarm(ii)),(xswarm(iii)-xswarm(ii)))*180/pi;
                        if (ii==iii)
                            distanceR(ii,iii)=NaN;
                        end
                    end
                end
                
                C_neighbor=0;
                I_neighbor=0;
                angle_neighbor=0;
                
                for ii=1:N
                    [C_neighbor(ii),I_neighbor(ii)]=min(distanceR(ii,:)');
                    if (isnan(C_neighbor(ii))==0)
                        distanceR(I_neighbor(ii),ii)=NaN;
                        angle_neighbor(ii)=angleR(ii,I_neighbor(ii));
                        %                     numNeighbor=numR(I_neighbor(1,:));
                        dist_neighbor=C_neighbor;
                    else
                        C_neighbor(ii)=RangeComm;
                        angle_neighbor(ii)=0;
                    end
                end
                dist_neighbor=C_neighbor;
                dist_neighbor = dist_neighbor(find(numR==getnum(simrobot)-1));
                angle_neighbor = angle_neighbor(find(numR==getnum(simrobot)-1));
            end
            
            %         ['swarm' num2str(swarm) ':']
            %         ['robot ' num2str(getnum(simrobot)-1) ' choose robot ' num2str(numNeighbor(find(numR==getnum(simrobot)-1)))]
            
            
            %% compute RDPSO equations
            Ix = fract*vx + (1.0/2.0)*fract*vx_t1 + (1.0/6.0)*fract*(1.0-fract)*vx_t2 + (1.0/24.0)*fract*(1.0-fract)*(2.0-fract)*vx_t3;
            Iy = fract*vy + (1.0/2.0)*fract*vy_t1 + (1.0/6.0)*fract*(1.0-fract)*vy_t2 + (1.0/24.0)*fract*(1.0-fract)*(2.0-fract)*vy_t3;
            Ox = pobs*rand*(xobs-x0);
            Oy = pobs*rand*(yobs-y0);
            Cx = pc*rand*(xc-x0);
            Cy = pc*rand*(yc-y0);
            auxgbestv=message.gBestValue_t1;
            ps=(message.gBestValue_t1-90)/500;
            pc= 0.65 -abs(ps);
%             if swarm~=4
                Sx = ps*rand*(xgBest-x0);
                Sy = ps*rand*(ygBest-y0);
%             else
%                 Sx = Ix;
%                 Sy = Iy;
%             end
            if (N>1)
                Nx = pgoal*rand*(xgoal-x0);
                Ny = pgoal*rand*(ygoal-y0);
            else
                Nx = 0;
                Ny = 0;
            end
            %         figure(2)
            %         hold on;
            %         plot(Cx,Cy,'r*');
            %         plot(Ox,Oy,'g*');
            %         plot(Sx,Sy,'b*');
            %         plot(Nx,Ny,'y*');
            
            
            vx = Ix + Cx + Sx + Ox + Nx;
            vy = Iy + Cy + Sy + Oy + Ny;
            
            %         vx = Ix + Ox;
            %         vy = Iy + Oy;
            
            %         if (vx>1)
            %             vx=1;
            %         end
            %         if (vy>1)
            %             vy=1;
            %         end
            %         if (vx<-1)
            %             vx=-1;
            %         end
            %         if (vy<-1)
            %             vy=-1;
            %         end
            
            % update previous velocities
            message.vx_t3=vx_t2;
            message.vx_t2=vx_t1;
            message.vx_t1=vx;
            
            message.vy_t3=vy_t2;
            message.vy_t2=vy_t1;
            message.vy_t1=vy;
            
            % new desired position
            x1=round(x0+vx);
            y1=round(y0+vy);
            
            %         hold on;
            %         plot(x1,y1,'r*');
            
            %         message.xy = [x1 y1];
            
            % call low level control function (update position)
            simrobot = LLC(simrobot,[x1 y1],dist);
            
            %% Evolutive component
            callrobot=0;
            createswarm=0;
            
            %         if N==1
            %             improve
            %         end
            
%             if(swarm~=4)    % if the robot belongs to the excluded group none of this matters
%                 if (improve==0)  % check performance of the swarm -> 0 - didn't improve; 1 - improve
%                     SC=SC+1;
%                     if (SC>=SCmax)        % reached search limit
%                         if (N>N_MIN)        % exclude robot
%                             Nkill=Nkill+1;
%                             N=N-1;
%                             SC=round(SCmax*(1.0-1.0/(Nkill+1.0)));  % initialize search counter
%                             
%                             % detect if it is the worst robot - the one with lower objective function
%                             worstRobot=1;
%                             a=find(fswarm<fswarm(find(numR==getnum(simrobot)-1)));
%                             if (isempty(a)~=1)
%                                 worstRobot=0;
%                             end
%                             
%                             if(worstRobot==1)  % it is the worst robot so it needs to be excluded
%                                 swarm=4;  % swarm ID = 4 - excluded swarm
%                             end
%                         else  % not enough robots in the swarm - delete swarm
%                             N=0;
%                             Nkill=0;
%                             swarm=4;
%                             SC=0;        % reset search counter
%                         end
%                     end
%                 else  % see if it possible to call a new robot
%                     if (Nkill>0)
%                         Nkill=Nkill-1;
%                     end
%                     if ((Nkill==0)&&(N<N_MAX))     % call a new robot to the swarm
%                         SC=0;
%                         prob = rand/(2.0*N_SWARMS);
%                         create_swarm = rand;
%                         if (create_swarm<prob)
%                             callrobot=1;
%                         else
%                             callrobot=0;
%                         end
%                     end
%                     if ((Nkill==0)&&(N_SWARMS<MAX_SWARMS))     % see if it is possible to create a new swarm
%                         prob = rand/(2.0*N_SWARMS);
%                         create_swarm = rand;
%                         if (create_swarm<prob)
%                             SC=0;
%                             createswarm=1;
%                         else
%                             createswarm=0;
%                         end
%                     end
%                 end
%             else  % if the robot belongs to the excluded swarm
%                 a=find(callrobotswarm==1);
%                 if(isempty(a)~=1)   % a new robot is needed
%                     % detect if it is the best robot - the one with higher objective function
%                     b=find(fswarm>fswarm(find(numR==getnum(simrobot)-1)));
%                     if (isempty(b)==1)
%                         swarm=buffer{a(1)}.swarm;
%                         SC=0;
%                         Nkill=0;
%                     end
%                 else
%                     a=find(createswarmswarm==1);
%                     if(isempty(a)~=1)   % a new swarm is needed
%                         % however, it can only create a new swarm
%                         % if there are at least N_Init robots in the excluded swarm
%                         if (N>=N_Init)
%                             % detect if it is one of the best robots
%                             %                       b=sort(fswarm,'descend')
%                             %                       c=find(b(1:N_Init)==fswarm(find(numR==getnum(simrobot)-1)))
%                             %                       if (isempty(a)~=1)
%                             swarm=1+round(2*rand);
%                             SC=0;
%                             Nkill=0;
%                             %                       end
%                         end
%                     end
%                 end
%             end
            
            message.callrobot=callrobot;
            message.createswarm=createswarm;
            
            message.Nkill=Nkill;
            message.SC=SC;
            
            message.swarm=swarm;
            
            %% update swarm
            
            switch swarm
                case 1
                    simrobot = setcolor(simrobot,[1 0 0]);
                case 2
                    simrobot = setcolor(simrobot,[0 1 0]);
                case 3
                    simrobot = setcolor(simrobot,[0 0 1]);
                case 4
                    simrobot = setcolor(simrobot,[0 0 0]);  % socially excluded swarm
            end
        
%         end
        
        
        %% share data
        simrobot = setdata(simrobot,getnum(simrobot)-1,message);
        [ack,list] = exchangeData(simrobot,list,message,RangeComm,-1);  % send the new map to all robots
    
%         % show map from 20 to 20 iterations (just for debug)
%         if (rem(step,100) == 0)
%             figure(2);
%             hold on;
%             %     [x, y] = find(matrix==1);
%             %     plot(x,y,'.','Color','blue');
%             %     axis equal
%             %     [xmax, ymax] = size(matrix);
%             %     length(find(message.matrixout==0))
%             %     [x, y] = find(message.matrixout==0);
%             %     set(hmap,'Name','Collective Mapping');
%             %     plot(x,y,'.','Color','black');
%             A=imrotate(not(message.matrixout),90);
%             imshow(A);
%             %     axis([0 xmax+1 0 ymax+1]);
%             drawnow;
%         end
    end
end

% end of your algorithm

list(getnum(simrobot)-1)=simrobot;
listout = list;

