function gui_addrcb(action);

switch action
   
case 'initialize'
   sensors = struct(	'name','sensor_1','position',[5 0],'axisangle',0,...
         					   'scanangle',60,'range',30,'resolution',30);
   data = struct(	'name','','color',[1 1 0],'power',1,'af','algtemp',...
				      'xdata',[-2 0 4 0 -2],'ydata',[3 4 0 -4 -3],'heading',0,...
				      'sensors',sensors);
   h = findobj('Tag','Store');
   set(h,'UserData',data);
   h = findobj('Tag','ColFrame');
   set(h,'BackgroundColor',data.color)
   h = findobj('Tag','AlgText');
   set(h,'String',[data.af '.m']);
   
case 'cancel'								% Cancel button pressed
   h = findobj('Tag','Store');
   set(h,'UserData','')
   close(gcbf)
   
case 'name'									% Got new string from text edit box
   h = findobj('Tag','NameEdit');	% Find Name edit uicontrol
   name = get(h,'String'); 			% Get name of new robot from it and store it in the struct
   h = findobj('Tag','Store');		% Reuse var h for another handle
   data = get(h,'UserData');			% Get struct 'data' 
   data.name = name;						% Insert name into the struct
   set(h,'UserData',data);				% ... and back
   
case 'dispnames'							% Display list of names
   h = findobj('Tag','ListStore');
   list = get(h,'UserData');
   names = ' ';
   if length(list) > 0
	   for i = 1:length(list)
   	   names = strvcat(names,getnameR(list(i)));
	   end
   else names = strvcat(names,'No robots yet ...'); end
   h = msgbox(names,'Names','help');	% Display names in msgbox - style help
   
case 'algbrowse'
   [filename,pathname] = uigetfile('*.m','Open algorithm file');
	   if filename ~= 0							% if any file selected
         h = findobj('Tag','AlgText');
         set(h,'ToolTipString',[pathname filename])
         h = findobj('Tag','AlgText');
         set(h,'String',filename)
         filename = strrep(filename,'.m','');			% delete extension .m
 			h = findobj('Tag','Store');
         data = get(h,'UserData');
         data.af = filename;
         set(h,'UserData',data)
   	end
   
case 'ok'									% OK button pressed
   close(gcbf)
	simeditcb add_ok;   
   
case 'chcol'								% Change color
   h = findobj('Tag','Store');		% Reuse var h for another handle
   data = get(h,'UserData');			% Get struct 'data' 
   data.color = uisetcolor(data.color,'Set color');
   set(h,'UserData',data);
   h = findobj('Tag','ColFrame');
   set(h,'BackgroundColor',data.color)
   
case 'udshape'		% User defined shape
   h = findobj('Tag','Store');
   data = get(h,'UserData');
   shape = inputdlg({'X data (default shape - [-2 0 4 0 -2])',...
         				'Y data (default shape - [3 4 0 -4 -3])'},...
                  	'Enter data for new shape',[1 45],...
	                  {num2str(data.xdata),num2str(data.ydata)});
   if ~isempty(shape)
      h = findobj('Tag','Store');
      data = get(h,'UserData');
      data.xdata = str2num(shape{1});
      data.ydata = str2num(shape{2});
      set(h,'UserData',data);
      h = findobj('Tag','ShapeText');
      set(h,'String','User Defined')
   end
   
case 'stshape'		% Standard (default) shape
   answer = questdlg('Restore default shape ?','Question','Yes','No','No');
      if strcmp(answer,'Yes')
         h = findobj('Tag','ShapeText');
         set(h,'String','Default')
         h = findobj('Tag','Store');
         data = get(h,'UserData');
   	   data.xdata = [-2 0 4 0 -2];
      	data.ydata = [3 4 0 -4 -3];
      	set(h,'UserData',data);
      end   
      
case 'heading'
   h = findobj('Tag','HeadSlider');
   heading = get(h,'Value');
   heading = round(heading);
   h = findobj('Tag','HeadVal');
   set(h,'String',num2str(heading))
   h = findobj('Tag','Store');
   data = get(h,'UserData');
   data.heading = heading;
   set(h,'UserData',data)
      
case 'power'
   h = findobj('Tag','Power');
   state = get(h,'Value');
   h = findobj('Tag','Store');		% Reuse var h for another handle
   data = get(h,'UserData');			% Get struct 'data' 
   if state == 1
      data.power = 1;
   else data.power = 0;
   end
   set(h,'UserData',data);
      
case 'sensors'
   gui_sens;
   h = findobj('Tag','Store');		% Reuse var h for another handle
   data = get(h,'UserData');			% Get struct 'data' 
   h = findobj('Tag','SensAxes');
   %   scale = getscale(list(pos));
   scale = 1;
	set(h,'UserData',scale);
   h = findobj('Tag','SensStore');
   set(h,'UserData',data.sensors)
   shape = struct('xdata',data.xdata,'ydata',data.ydata);	% Data without scale
   h = findobj('Tag','SensCancel');
   set(h,'UserData',shape)
   h = findobj('Tag','SensOK');
   set(h,'Callback','gui_addrcb sens_ok')
   gui_senscb;

case 'sens_ok'
	h = findobj('Tag','SensStore');
   sensors = get(h,'UserData');
   h = findobj('Tag','Store');		
   data = get(h,'UserData');
   data.sensors = sensors;
   set(h,'UserData',data);
	close(gcbf)
end
