function simrobcb(action)
% SIMROBCB 		this is callback function for context menu of robots

h = findobj('Tag','ListStore');
list = get(h,'UserData');

number = get(gcbo,'UserData');	% get robot's number from caller's UserData property

for i = 1:length(list);				% Find position of the robot in the list
    if getnum(list(i)) == number
        pos = i;
        break
    end
end

% The MATRIX is modified by DLLs. These DLLs work with the pointer to the matrix
% so there is only one copy of matrix variable in the memory at a time, which is
% directly modified and it's not necessary to update it every time.
% But, it's there to make the program look 'correct'


switch(action)
    
    case 'info'
        % *********** Get data and display them ************
        name = ['Name                        ' getnameR(list(pos))];
        algfile = ['Algorithm                  ' getaf(list(pos))];
        numstr = ['Number                     ' int2str(getnum(list(pos)))];
        posstr = ['Position                     [' int2str(getpos(list(pos))) ']'];
        headstr = ['Heading                    ' int2str(gethead(list(pos))) '°'];
        scalestr = ['Scale                        ' int2str(getscale(list(pos)))];
        powerstr = ['Power                      ' int2str(getpower(list(pos)))];
        sensstr = ['Sensors                   ' int2str(length(getsens(list(pos))))];
        
        infotext = strvcat(name,algfile,numstr,posstr,headstr,scalestr,powerstr,sensstr);
        h = msgbox(infotext,'Info','help');
        % **************************************************
        
        
    case 'chscale'
        scale = getscale(list(pos));
        scale = inputdlg('Scale:','Scale',[1 15],{num2str(scale)});
        if ~isempty(scale)
            h = findobj('Tag','EditorWindow');
            matrix = get(h,'UserData');
            deleteR(list(pos))
            list(pos) = setscale(list(pos), scale{1});
            list(pos) = putrob(list(pos), getpos(list(pos)), matrix);
            set(h,'UserData',matrix)
            h = findobj('Tag','ListStore');
            set(h,'UserData',list)
        end
        
    case 'chcol'
        oldcolor = getcolor(list(pos));
        color = uisetcolor(oldcolor,'Set Color');
        list(pos) = setcolor(list(pos),color);
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        
    case 'chshape'
        oldsh = getshape(list(pos));
        shape = inputdlg({'X data (default shape - [-2 0 4 0 -2])',...
            'Y data (default shape - [3 4 0 -4 -3])'},...
            'Enter data for new shape',[1 45],...
            {num2str(oldsh.xdata),num2str(oldsh.ydata)});
        if ~isempty(shape)
            xdata = str2num(shape{1});
            ydata = str2num(shape{2});
            h = findobj('Tag','EditorWindow');
            matrix = get(h,'UserData');
            deleteR(list(pos))
            list(pos) = chshape(list(pos),xdata,ydata);
            list(pos) = putrob(list(pos), getpos(list(pos)), matrix);
            set(h,'UserData',matrix)
            h = findobj('Tag','ListStore');
            set(h,'UserData',list)
        end
        
    case 'name'
        name = inputdlg('Name:','Name',[1 15],{getnameR(list(pos))});
        if ~isempty(name)
            list(pos) = setname(list(pos), name{1});
            h = findobj('Tag','ListStore');
            set(h,'UserData',list)
        end
        
    case 'power'
        gui_power(getpower(list(pos)), number);
        
    case 'power_ok'
        h = findobj('Tag','PowerMenu');
        power = get(h,'Value');
        if power == 1
            list(pos) = setpower(list(pos),1);
        else
            list(pos) = setpower(list(pos),0);
        end
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        close(gcbf);
        
        
    case 'delete'
        answer = questdlg('Really delete this robot?','Question','Yes','No','No');
        if strcmp(answer,'Yes')
            h = findobj('Tag','EditorWindow');
            matrix = get(h,'UserData');
            deleteR(list(pos));
            list(pos) = [];
            for i = pos:length(list)
                list(i) = setnum(list(i),i + 1);
                deleteR(list(i))
                list(i) = putrob(list(i),getpos(list(i)),matrix);
            end
            h = findobj('Tag','ListStore');
            set(h,'UserData',list);
            if isempty(list)
                h = findobj('Tag','SaveMenu');
                set(h,'Enable','off')
            end
        end
        
    case 'clearmem'
        answer = questdlg('Really clear memory of this robot?','Question','Yes','No','No');
        if strcmp(answer,'Yes')
            list(pos) = writemem(list(pos),[]);
            h = findobj('Tag','ListStore');
            set(h,'UserData',list);
        end
        
        
    case 'showmem'
        mem = readmem(list(pos));
        contents = whos('mem');
        if ~isempty(mem)
            dispstr = strvcat(['Size: ' num2str(contents.size)],...
                ['Bytes: ' num2str(contents.bytes)],['Class: ' contents.class]);
        else
            dispstr = 'No contents - empty memory';
        end
        h = msgbox(dispstr,'Memory contents','help');
        
        
    case 'savemem'
        mem = readmem(list(pos));
        if ~isempty(mem)
            [filename,pathname] = uiputfile('memory.mat','Save memory contents');
            if filename ~= 0
                save([pathname filename],'mem');
            end
        else
            h = msgbox('The memory is empty','Memory contents','help');
        end
        
        
    case 'saveasc'
        mem = readmem(list(pos));
        if ~isempty(mem)
            if ~isa(mem,'double')
                h = msgbox('Only numeric matrices can be saved as ASCII data files','Warning','warn');
            else
                [filename,pathname] = uiputfile('memory.asc','Save memory contents');
                if filename ~= 0
                    save([pathname filename],'mem','-ascii','-double','-tabs');
                end
            end
        else
            h = msgbox('The memory is empty','Memory contents','help');
        end
        
        
    case 'savemat'
        mem = readmem(list(pos));
        if ~isempty(mem)
            [filename,pathname] = uiputfile('memory.mat','Save memory contents');
            if filename ~= 0
                save([pathname filename],'mem');
            end
        else
            h = msgbox('The memory is empty','Memory contents','help');
        end
        
        
    case 'loadmat'
        mem = readmem(list(pos));
        if ~isempty(mem)
            answer = questdlg('Overwrite memory contents?','Question','Yes','No','No');
        else
            answer = 'Yes';
        end
        if strcmp(answer,'Yes')
            [filename,pathname] = uigetfile('memory.mat','Upload mat file into memory');
            if filename ~= 0
                vars = who('-file',[pathname filename]);	% Lists variables in selected file
                % ** Try to find 'mem' in variable list **
                cmp = strcmp(vars,'mem');
                if ~any(cmp)
                    h = msgbox('Could not find variable called ''mem'' in selected file. Only variable ''mem'' can be loaded into memory.','Error','error');
                else
                    % ****************************************
                    load([pathname filename]);
                    list(pos) = writemem(list(pos),mem);
                    h = findobj('Tag','ListStore');
                    set(h,'UserData',list)
                end
            end
        end
        
    case 'loadasc'
        mem = readmem(list(pos));
        if ~isempty(mem)
            answer = questdlg('Overwrite memory contents?','Question','Yes','No','No');
        else
            answer = 'Yes';
        end
        if strcmp(answer,'Yes')
            [filename,pathname] = uigetfile('memory.asc','Upload ascii file into memory');
            if filename ~= 0
                try
                    mem = load([pathname filename],'-ascii');
                catch
                    h = msgbox('Error loading file (wrong structure?)!','Error','error');
                end
                list(pos) = writemem(list(pos),mem);
                h = findobj('Tag','ListStore');
                set(h,'UserData',list)
            end
        end
        
        
        
    case 'move'
        load cur_put											% Load cursor shape data
        set(gcf,'Pointer','custom',...
            'PointerShapeCData',cdata,...			% User data defining pointer shape
            'PointerShapeHotSpot',[11 5]);			% Pointer active point (center of the p.)
        h = findobj('Tag','Axes');							% Main window axes
        set(h,'ButtonDownFcn','simrobcb move_click')	% Set callback fcn & wait for a click
        set(h,'UserData',getnum(list(pos)))				% Axes will be callback caller of simrobcb
        
        
    case 'move_click'											% Click after move command
        
        % ********* Get coordinates of mouse click *********
        cpoint = get(gca,'CurrentPoint');
        cpoint = round(cpoint(1,1:2));
        % **************************************************
        
        % ********* Change cursor back to arrow ************
        h = findobj('Tag','Axes');							% Main window axes
        
        set(h,'ButtonDownFcn','')							% Delete callback
        set(gcf,'Pointer','arrow',...
            'PointerShapeHotSpot',[1 1])
        % **************************************************
        
        % ********** Make moved robot disappear ************
        deleteR(list(pos))
        % **************************************************
        
        % ********** Get matrix and put in the robot *******
        h = findobj('Tag','EditorWindow');
        matrix = get(h,'UserData');
        list(pos) = delhist(list(pos));
        list(pos) = putrob(list(pos), cpoint, matrix);
        % **************************************************
        
        % ********* Store updated list ***********
        h = findobj('Tag','ListStore');
        set(h,'UserData',list)
        % ****************************************
        
    case 'heading'
        gui_head(round(gethead(list(pos))));
        h = findobj('Tag','OkButton');
        set(h,'UserData',getnum(list(pos)))
        
    case 'head_ok'
        h = findobj('Tag','HeadSlider');
        heading = get(h,'Value');
        heading = round(heading);
        h = findobj('Tag','EditorWindow');
        matrix = get(h,'UserData');
        list(pos) = delhist(list(pos));
        list(pos) = sethead(list(pos), heading);
        deleteR(list(pos))
        close(gcbf)									% Close the dialog
        list(pos) = putrob(list(pos),getpos(list(pos)),matrix);
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        
    case 'sensors'
        gui_sens;
        h = findobj('Tag','SensStore');
        set(h,'UserData',getsens(list(pos)))
        h = findobj('Tag','SensAxes');
        scale = getscale(list(pos));
        set(h,'UserData',scale);
        shape = getsshape(list(pos));
        h = findobj('Tag','SensOK');
        set(h,'Callback','simrobcb sens_ok','UserData',getnum(list(pos)))
        h = findobj('Tag','SensCancel');
        set(h,'UserData',shape)
        gui_senscb initialize;
        
    case 'sens_ok'
        h = findobj('Tag','SensStore');
        sensors = get(h,'UserData');
        for i=1:length(sensors)
            sensors(i).name = strcat(sensors(i).name,'');
        end
        list(pos) = addsenss(list(pos),sensors);
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        close(gcbf);
        
    case 'algedit'
        notepath = 'notepad';
        fullpath = which(getaf(list(pos)));
        conflict = 0;
        answer = 'Yes';
        if ~strcmp(fullpath,'..');
            i = length(list);
            for j = 1:i
                algpath = which(getaf(list(j)));
                if strcmp(algpath,fullpath) & j ~= pos
                    conflict = 1;
                    break
                end
            end
            if conflict
                answer = questdlg('Warning: This algorithm is also used for other robot(s). Edit anyway?','Warning','Yes','No','No');
            end
            if strcmp(answer,'Yes')
%                 cmd = ['! ' notepath ' ' fullpath];
                % open algorithm in notepad (not possible in MATLAB editor)
%                 eval(cmd);
                open(fullpath);
                getaf(list(pos))
            end
        else h = msgbox('Error: File not found','Error occurred','error');end
        
    case 'algnew'
        notepath = 'notepad';
        answer = questdlg('Create new algorithm?','Question','Yes','No','No');
        if strcmp(answer,'Yes')
            fullpath = which('algtemp.m');			% path to algorithm template
            [path name ext] = fileparts(fullpath);
            cmd = ['cd ' path];
%             eval(cmd);
            [newalg, newpath] = uiputfile('*.m','Create new file');
            list(pos) = setaf(list(pos),newalg(1:length(newalg)-2));
            newalg = [newalg];						% add extension
            fnewpath = fullfile(newpath,newalg);	% create path to new alg. file from path & filename
            result = copyfile(fullpath,fnewpath);	% copy template and then open it as new file
            if result == 0
                h = msgbox('Error: Error creating file','Error occurred','error');
            else
%                 cmd = ['! ' notepath ' ' fnewpath]
                % open algorithm in notepad (not possible in MATLAB editor)
%                 eval(cmd);
                open(fnewpath);
            end
        end
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        
        
    case 'algassign'
        [filename,pathname] = uigetfile('*.m','Assign algorithm file');
        if filename ~= 0							% if any file selected
            filename = strrep(filename,'.m','');			% delete extension .m
            list(pos) = setaf(list(pos),filename);
        end
        h = findobj('Tag','ListStore');
        set(h,'UserData',list);
        
        
end

