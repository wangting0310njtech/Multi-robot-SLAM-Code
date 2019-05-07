function [ack,listout] = exchangeData(simrobot,list,message,RangeComm,type)
% ack = exchangeData(simrobot,message,type)
% message can be any string, integer, matrix, cell, structure, ...
% type - define type of communication
% type = 0 - local broadcast; returns ack = 1 if any robot in the 
% vicinities receives the message
% type = -1 - multicast to all robots in the multi-hop path; returns ack =
% 1 if any robot within the multi-hop path receives the message
% type >= 1 && type <= number of robots - multi-hop communication to a 
% robot with an ID = #type; returns ack = 1 if robot #type receives the
% message


% define maximum communication range - in the future, this will be a
% feature that depends on the kind of wireless technology of each robot
% RangeComm=3000;   % 30 meters - Equivalent to XBee Shield for Arduino in
% scnearios with a high density of obstacles
ackAux=0;

jj=1;

for j = 1:length(list)
    if (strcmp(getnameR(list(j)),'PoI')==0) % if it is not a point of interest
        listAux(jj)=list(j);
        listIndex(jj)=j;
        jj=jj+1;
        if (j == getnum(simrobot)-1)
            nLin = jj-1;    % line regarding this robot
        end
    end
end

for j = 1:length(listAux)
    xtotal(j,1:2) = getpos(listAux(j));
end

% network topology
commOK=zeros(length(listAux),length(listAux));  %Adjacency Matrix
distanceR=zeros(length(listAux),length(listAux));
angleR=zeros(length(listAux),length(listAux));
for ii=1:length(listAux)
    for iii=1:length(listAux)
        distanceR(ii,iii)=((xtotal(ii,1)-xtotal(iii,1))^2+(xtotal(ii,2)-xtotal(iii,2))^2)^(1/2);
        angleR(ii,iii)=atan2((xtotal(iii,2)-xtotal(ii,2)),(xtotal(iii,1)-xtotal(ii,1)))*180/pi;
        if (ii~=iii)&&(distanceR(ii,iii)<RangeComm)
            commOK(ii,iii)=1;
        end
        if (ii==iii)
            distanceR(ii,iii)=NaN;
        end
    end
end
% commOK

if (type == 0)  % broadcast communication
%     nLin = getnum(simrobot) - 1;    % line regarding this robot
    indexRobot=find(commOK(nLin,:)==1);
    if (isempty(indexRobot)==0)
       for i=1:length(indexRobot)
           listAux(indexRobot(i))=setdata(listAux(indexRobot(i)),listIndex(nLin),message);
       end
       ackAux=1;
    end
    
else            % multi-hop communication
    multicommOK=commOK; %multihop connectivity matrix
    for mm=2:(length(listAux)-1)
        commOKaux=zeros(length(listAux),length(listAux));
        for ii=1:length(listAux)
            for iii=1:length(listAux)
                if ii==iii
                    commOKaux(ii,iii)=0;
                else
                    if multicommOK(ii,iii)>0
                        commOKaux(ii,iii)=0;
                    else
                        if (multicommOK(ii,:)*commOK(:,iii)>0) && (multicommOK(ii,iii)==0)
                            commOKaux(ii,iii)=mm;
                        else
                            commOKaux(ii,iii)=0;
                        end
                    end
                end
            end
        end
        multicommOK=multicommOK+commOKaux;
    end
    
    % multicast communication in a multi-hop network
    if (type == -1) 
%         nLin = getnum(simrobot) - 1;    % line regarding this robot
        indexRobot=find(multicommOK(nLin,:)~=0);
        if (isempty(indexRobot)==0)
           for i=1:length(indexRobot)
               listAux(indexRobot(i))=setdata(listAux(indexRobot(i)),listIndex(nLin),message);
           end
           ackAux=1;
        end
    end
    
    % multi-hop communication to a specific robot
    if ((type >= 1)&& type ~= (getnum(simrobot) - 1)) 
%         nLin = getnum(simrobot) - 1;    % line regarding this robot
        if (multicommOK(nLin,type)~=0)
            listAux(type)=setdata(listAux(type),listIndex(nLin),message);
            ackAux=1;
        end
    end
end

% build list again (introducing the robots to the points of interests)
jj=1;

for j = 1:length(list)
    if (strcmp(getnameR(list(j)),'PoI')==0) % if it is not a point of interest
        list(j)=listAux(jj);
%         if j==1
%             listIndex(nLin)
%             getdata(list(j))
%         end
        jj=jj+1;
    end
end

listout=list;

ack=ackAux;


