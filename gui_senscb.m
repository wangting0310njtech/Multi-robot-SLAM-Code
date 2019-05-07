function gui_senscb(action);

if nargin == 0
   action = 'initialize';
end

% Data - in SensStore (static text)
% SensAdd (add button) - 1 if new sensor
% Shape in SensCancel 
% SensOK = OK Button - number of callbacking robot (when called from robot's uicm)

switch(action)
   
case 'initialize'
   
   	h = findobj('Tag','SensStore');
      sensors = get(h,'UserData');
      h = findobj('Tag','SensAdd');
      new = get(h,'UserData');
      
      if isempty(sensors) | new
         if new 
				h = findobj('Tag','NamesMenu');
            name = get(h,'String');
            s = size(name);
            name = name(s(1),:);
         else
            name = 'sensor_1';
         end
      	sensor = struct(	'name',name,'position',[5 0],'axisangle',0,...
         					   'scanangle',60,'range',30,'resolution',30);
	      sensors = [sensors sensor];
			h = findobj('Tag','SensStore');
         set(h,'UserData',sensors);
         h = findobj('Tag','SensAdd');
         set(h,'UserData',0);
         i = length(sensors);
   	else
			h = findobj('Tag','NamesMenu');
   		i = get(h,'Value');
	   end
   
      % ********* Fill in the popup menu with names of sensors *********
		names = sensors(1).name;		
		for j = 2:length(sensors)
         names = [names '|' sensors(j).name];
      end
      % ****************************************************************
		h = findobj('Tag','NamesMenu');	% Needed when adding new sensor
      set(h,'Value',i);
      set(h,'String',names)
      h = findobj('Tag','XPos');
      set(h,'String',num2str(sensors(i).position(1)))
      h = findobj('Tag','YPos');
      set(h,'String',num2str(sensors(i).position(2)))
	   h = findobj('Tag','AxisSlider');
      set(h,'Value',sensors(i).axisangle)
      h = findobj('Tag','AxisVal');
      set(h,'String',num2str(sensors(i).axisangle))
      h = findobj('Tag','ScanSlider');
      set(h,'Value',sensors(i).scanangle)
      h = findobj('Tag','ScanVal');
      set(h,'String',num2str(sensors(i).scanangle));
		h = findobj('Tag','EditRes');
      set(h,'String',num2str(sensors(i).resolution));
		h = findobj('Tag','EditRange');
      set(h,'String',num2str(sensors(i).range));



      h = findobj('Tag','SensCancel');
      shape = get(h,'UserData');
      UpdatePreview(shape,sensors)
      
	case 'xpos'
     	h = findobj('Tag','XPos');
	   xpos = get(h,'String');
      xpos = str2num(xpos);
      h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).position(1) = xpos;
      set(h,'UserData',sensors)
      
   case 'ypos'
      h = findobj('Tag','YPos');
	   ypos = get(h,'String');
      ypos = str2num(ypos);
      h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).position(2) = ypos;
      set(h,'UserData',sensors)


   case 'res'
		h = findobj('Tag','EditRes');
	   res = get(h,'String');
      res = str2num(res);
      h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).resolution = res;
      set(h,'UserData',sensors)
      
   case 'range'
		h = findobj('Tag','EditRange');
	   range = get(h,'String');
      range = str2num(range);
      h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).range = range;
      set(h,'UserData',sensors)
      
   case 'axisangle'
      h = findobj('Tag','AxisSlider');
      angle = get(h,'Value');
      angle = round(angle);
      h = findobj('Tag','AxisVal');
      set(h,'String',num2str(angle));
      h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).axisangle = angle;
      set(h,'UserData',sensors)

      
   case 'scanangle'
      h = findobj('Tag','ScanSlider');
      angle = get(h,'Value');
      angle = round(angle);
      h = findobj('Tag','ScanVal');
      set(h,'String',num2str(angle));
		h = findobj('Tag','NamesMenu');		% Get index of the sensor in sensors' structure
      i = get(h,'Value');
      h = findobj('Tag','SensStore');		
      sensors = get(h,'UserData');
      sensors(i).scanangle = angle;
      set(h,'UserData',sensors)

      
	case 'ok'
      % The callback routine is assigned by caller of the editor
      
   case 'cancel'
      close(gcbf)									
      
   case 'select'
      gui_senscb initialize;
      
   case 'sensdel'
      answer = questdlg('Really delete selected sensor ?','Question','Yes','No','No');
      if strcmp(answer,'Yes')
         h = findobj('Tag','NamesMenu');
         i = get(h,'Value');
         set(h,'Value',1)
      	h = findobj('Tag','SensStore');		
	      sensors = get(h,'UserData');
         sensors(i) = [];
         set(h,'UserData',sensors)
         gui_senscb initialize;
      end
      
   case 'sensren'
      h = findobj('Tag','NamesMenu');
      i = get(h,'Value');
      names = get(h,'String');
		name = inputdlg('Name:','Enter name',[1 15],{names(i,:)});
      if ~isempty(name)
   		h = findobj('Tag','SensStore');		
	      sensors = get(h,'UserData');
      	sensors(i).name = name{1};
      	set(h,'UserData',sensors)
         gui_senscb initialize;
      end
            
      
   case 'updprev'
      h = findobj('Tag','SensStore');
      sensors = get(h,'UserData');
      h = findobj('Tag','SensCancel');
      shape = get(h,'UserData');
      UpdatePreview(shape,sensors)

      
   case 'add'
      name = inputdlg('Name:','Enter name',[1 15]);% This returns CELL
      if ~isempty(name{1})
         h = findobj('Tag','NamesMenu');
         names = get(h,'String');						% Get list of names
         if names == ' '									% This is value for new-defined menu
            names = '';										% and we need empty string instead
         end													% because otherwise we'll have an empty line
         names = strvcat(names,name{1});				% Add new name to menu's list
         set(h,'String',names,'Value',length(names))
         h = findobj('Tag','SensAdd');
         set(h,'UserData',1)         
         gui_senscb initialize;
      end
      
   
   	   
   end
   
function UpdatePreview(shape,sensors)
   
   axHndl = findobj('Tag','SensAxes');
   scale = get(axHndl,'UserData');
   axes(axHndl);
   cla;							% Clear Axes
   h = findobj('Tag','NamesMenu');
   active = get(h,'Value');
   xmax = 0;
   % ****** Determine plotting order of sensors - the active one goes last ******
   order = 1:length(sensors);
   order(active) = [];				% Delete active
   order = [order active];			% ... and put it at the end
   % This all is necessarry when drawing two indentical sensors
   % (the active one could be overlapped by non-active one)
   % ****************************************************************************
   for j = 1:length(order)
      i = order(j);
      angles = sensors(i).axisangle - sensors(i).scanangle/2:1:sensors(i).axisangle + sensors(i).scanangle/2;
      angles = angles*pi/180;
      % *** Points of ending arcs ***
      x = sensors(i).position(1) * scale + sensors(i).range * cos(angles);
      y = sensors(i).position(2) * scale + sensors(i).range * sin(angles);     
      % *****************************
      tx = max(max(x),abs(min(x)));
      ty = max(max(y),abs(min(y)));
      if tx > xmax
         xmax = tx;
      end     
		if ty > xmax
         xmax = ty;
      end
      x1 = sensors(i).position(1) * scale;
      y1 = sensors(i).position(2) * scale;
     	x2 = x1 + sensors(i).range * cos((sensors(i).axisangle + sensors(i).scanangle/2)*pi/180);
      y2 = y1 + sensors(i).range * sin((sensors(i).axisangle + sensors(i).scanangle/2)*pi/180);
      line1 = line([x1 x2],[y1 y2]);
      x2 = x1 + sensors(i).range * cos((sensors(i).axisangle - sensors(i).scanangle/2)*pi/180);
      y2 = y1 + sensors(i).range * sin((sensors(i).axisangle - sensors(i).scanangle/2)*pi/180);
      line2 = line([x1 x2],[y1 y2]);
      plot1 = plot(x,y);
         set(line1,'Color','b')
         set(line2,'Color','b')
         set(plot1,'Color','b')      
      end
      	% ***** The last drawn sensor is the active one, color it red *****
         set(line1,'Color','r')
         set(line2,'Color','r')
         set(plot1,'Color','r')
         % *****************************************************************
         
   % ******* Now set axes limits ********   
   set(axHndl,	'XLim',[-xmax-0.25*xmax xmax+0.25*xmax],...
			      'YLim',[-xmax-0.25*xmax xmax+0.25*xmax],...
      			'XTickMode','auto','YTickMode','auto')
   % ************************************
   rob = patch(shape.xdata,shape.ydata,[1 1 1]);
   