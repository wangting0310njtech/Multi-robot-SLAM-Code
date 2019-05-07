function gui_headcb(action);

number = get(gcbo,'UserData');

switch(action)
   
	case 'slider'
     	h = findobj('Tag','HeadSlider');
	   heading = get(h,'Value');
  		heading = round(heading);
   	h = findobj('Tag','HeadVal');
   	set(h,'String',num2str(heading))
   
	case 'ok'
      h = findobj('Tag','OkButton');
      set(h,'UserData',number)
      simrobcb head_ok;
      %close(gcbf)
      
   case 'cancel'
      close(gcbf)										% No other action is necessary
   	   
   end
   