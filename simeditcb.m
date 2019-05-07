function simeditcb(action)

nameSim = 'MRSim - Multi-Robot Simulator v1.0';

switch action
  
    case 'import'
        % ***************** Import bitmap ********************
        h = findobj('Tag','ListStore');	% We need to check the list
        list = get(h,'UserData');			% Get it
        if ~isempty(list)						% If it is not empty, ask a question
            answer = questdlg('This will delete all robots. Continue?','Question','Yes','No','No');
        else
            answer = 'Yes';
        end
        if strcmp(answer,'Yes')
            set(h,'UserData',[]);				% Delete the list
            [filename,pathname] = uigetfile('*.bmp','Open map');
            if filename ~= 0						% if any file selected
                matrix = matrprep([pathname filename]);
                for i = 1:3
                    matrix = rot90(matrix);		% Ensures normal position of the matrix
                end										% (as it is stored in bitmap)
                LocalDraw(matrix,2);
                list = [];
                h = findobj('Tag','EditorWindow');
                set(h,'UserData',matrix);
                set(h,'Name',['Editor Window - [untitled.mat - ' pwd '\untitled.mat]'])
                h = findobj('Tag','EditPath');
                set(h,'UserData',[pwd '\untitled.mat'])
                save([pwd '\untitled.mat'],'matrix')
                % ******** Enable disabled context menu items *********
                h = findobj('Type','uimenu','Enable','off');
                set(h,'Enable','on')
                h = findobj('Tag','SaveMenu');
                set(h,'Enable','off')
                h = findobj('Tag','StepsMenu');
                set(h,'UserData',Inf)
                h = findobj('Tag','DelayMenu');
                set(h,'UserData',0.001)
                
                % *****************************************************
            end
        end
        % ****************************************************
        
    case 'load'
        
        [filename,pathname] = uigetfile('*.mat','Open simulation');
        robotT = simrobot('',2,2,2,'',[1 1 0],1,10,10);	% Create object
        if filename ~= 0
            % ****** Check the file structure ******
            vars = who('-file',[pathname filename]);
            load([pathname filename],'list')
            if isempty(strmatch('list',vars)) | isempty(strmatch('no_steps',vars)) | isempty(strmatch('delay',vars)) | isempty(strmatch('matrix',vars)) | isempty(strmatch('type',vars)) | isempty(list)
                dispstr = strvcat(['"' pathname filename '"'],' ');
                dispstr = strvcat(dispstr,'Cannot open this file - invalid file structure!');
                h = msgbox(dispstr,'Error','error');
                return
            end
            % **************************************
            
            load([pathname filename]);
            
            %             type = 'replay';		% This is necessary !!
            %             if strcmp(type,'replay')
            %                 answer = questdlg('You are going to edit a replay file. This will delete replay data. Continue?','Question','Yes','No','No');
            %                 if strcmp(answer,'Yes')
            %                     type = 'simulation';
            %                     for i = 1:length(list)
            %                         list(i) = delhist(list(i));
            %                     end
            %                 else
            %                     return
            %                 end
            %             end
            path = [pathname filename];
            save(path,'list','matrix','no_steps','delay','type');
            h = findobj('Tag','EditPath');
            set(h,'UserData',path);
            simeditcb loadfile;
        end
        
        
        
    case 'loadfile'
        % ******** New part ********
        h = findobj('Tag','EditPath');
        path = get(h,'UserData');
        [pathname,filename,ext] = fileparts(path);
        pathname = [pathname '\'];
        filename = [filename ext];
        % **************************
        
%         robotT = simrobot('',2,2,2,'',[1 1 0],1,10,10);	% Create object
        
        load([pathname filename]);
        
        h = findobj('Tag','EditorWindow');
        set(h,'UserData',matrix)
        set(h,'Name',['Editor Window - [' filename ' - ' pathname filename ']'])
        LocalDraw(matrix,2);
        for i = 1:length(list)
            list(i) = putrob(list(i),getpos(list(i)),matrix);
        end
        h = findobj('Tag','ListStore');
        set(h,'UserData',list)				% Store list
        h = findobj('Tag','StepsMenu');
        
        if iscell(no_steps)
            no_steps = no_steps{1};
        end
        
        set(h,'Label',['Steps limit: ' num2str(no_steps)]);
        set(h,'UserData',no_steps)
        h = findobj('Tag','DelayMenu');
        
        if iscell(delay)
            delay = delay{1};
        end
        
        set(h,'Label',['Step time: ' num2str(delay)]);
        set(h,'UserData',delay)
        
        % ******* Enable disabled context menu items ********
        h = findobj('Type','uimenu','Enable','off');
        set(h,'Enable','on')
        % ***************************************************
        % ***********************************************************
        
    case 'save'
        h = findobj('Tag','EditPath');
        path = get(h,'UserData');
        if ~isempty(path)
            loadstr = load(path);			% Load (matrix) from original file
            [pathn,file,ext] = fileparts(path);
            file = [file ext];
            % ***************************************************************************
            if strcmp(file,'untitled.mat')
                [filename,pathname] = uiputfile('newsave.mat','Save simulation');
                if strcmp(filename,'untitled.mat')
                    h = msgbox('Error: Cannot save as ''untitled.mat''. Please select another name','Error','error');
                    return
                end
                if filename ~= 0
                    delete(path)
                    path = [pathname filename];
                    h = findobj('Tag','EditPath');
                    set(h,'UserData',path);
                    h = findobj('Tag','EditorWindow');
                    if isempty(findstr(filename,'.mat'))
                        filename = [filename '.mat'];
                    end
                    set(h,'Name',['Editor Window - [' filename ' - ' pathname filename ']']);
                else
                    return
                end
            end
            h = findobj('Tag','StepsMenu');
            no_steps = get(h,'UserData');
            no_steps = no_steps{1};								% Convert from cell
            h = findobj('Tag','ListStore');
            list = get(h,'UserData');							% Get list
            matrix = loadstr.matrix;
            h = findobj('Tag','DelayMenu');
            delay = get(h,'UserData');							% Get delay
            delay = delay{1};										% Convert from cell
            type = 'simulation';
            save(path,'list','matrix','no_steps','delay','type');
        end
        
    case 'saveas'
        % *********** Select mat file and save simulation ***********
        h = findobj('Tag','EditPath');
        path = get(h,'UserData');
        loadstr = load(path);
        [path,name,ext] = fileparts(path);
        if strcmp(name,'untitled')
            name = 'newsave';
        end
        [filename,pathname] = uiputfile([name ext],'Save simulation');
        if strcmp(filename,'untitled.mat')
            h = msgbox('Error: Cannot save as ''untitled.mat''. Please select another name','Error','error');
            return
        end
        if filename ~= 0											% if any file selected
            h = findobj('Tag','StepsMenu');
            no_steps = get(h,'UserData');
            path = [pathname filename];
            h = findobj('Tag','ListStore');
            list = get(h,'UserData');							% Get list
            matrix = loadstr.matrix;
            h = findobj('Tag','DelayMenu');
            delay = get(h,'UserData');							% Get delay
            type = 'simulation';
            save(path,'list','matrix','no_steps','delay','type');
            h = findobj('Tag','EditPath');						% Store the path
            set(h,'UserData',path);
            h = findobj('Tag','EditorWindow');
            title = ['Editor Window - [' filename ' - ' pathname filename ']'];
            set(h,'Name',title)
            
        end
        % ***********************************************************
        
        
    case 'add'
        gui_addr;													% Open the window
        gui_addrcb('initialize');
        
    case 'add_ok'
        % ********* User pressed OK button on robot-adding screen *********
        h = findobj('Tag','Store');
        robot = get(h,'UserData');
        if ~isempty(robot)
            load cur_put								% Load cursor shape data
            set(gcf,'Pointer','custom',...
                'PointerShapeCData',cdata,...		% User data defining pointer shape
                'PointerShapeHotSpot',[11 5]);	% Pointer active area (center of the p.)
            h = findobj('Tag','Axes');				% Main window axes
            set(h,'ButtonDownFcn','simeditcb add_click')	% Set callback fcn & wait for a click
        end
        % *****************************************************************
        
    case 'add_click'
        % *********** Put down the new robot *************
        cpoint = get(gca,'CurrentPoint');
        cpoint = cpoint(1,1:2);
        
        h = findobj('Tag','Axes');					% Main window axes
        set(h,'ButtonDownFcn','')					% Delete callback
        set(gcf,'Pointer','arrow',...
            'PointerShapeHotSpot',[1 1])
        
        h = findobj('Tag','EditorWindow');
        matrix = get(h,'UserData');
        
        h = findobj('Tag','Store');
        data = get(h,'UserData');
        
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        
        if length(list) > 0
            number = getnum(list(length(list))) + 1;
        else number = 2;				% First robot
        end
        
        robot = simrobot(data.name,number,data.heading,data.power,data.af,...
            data.color,1,data.xdata,data.ydata);	% Create object
        robot = putrob(robot,cpoint,matrix);							% Put it
        robot = addsenss(robot,data.sensors);
        
        if ~isempty(robot)
            if isempty(list)
                list = robot;
            else
                list = list + robot;
            end
        end
        set(h,'UserData',list);
        
        
        h = findobj('Tag','SaveMenu');
        set(h,'Enable','on')
        
        % **************************************************
        
    case 'steps'
        h = findobj('Tag','StepsMenu');
        def = get(h,'UserData');
        steps = inputdlg('Steps limit:','Number of steps',[1 14],{num2str(def{1})});
        if ~isempty(steps)
            if ~strcmp(steps{1},'Inf')
                steps = str2num(steps{1});
                if isempty(steps) | steps <= 0 | strcmpi(num2str(steps),'NaN')
                    h = msgbox('Please enter a valid number','Error','error');
                    waitfor(h)
                    simeditcb steps
                    return
                else
                    steps = round(steps(1));
                end
            else
                steps = Inf;
            end
            set(h,'UserData',steps)
            set(h,'Label',['Steps limit: ' num2str(steps)])
        end
        
        
        
    case 'delay'
        h = findobj('Tag','DelayMenu');
        def = get(h,'UserData');
        steps = inputdlg('Step time (in secs):','Minimum step length',[1 25],{num2str(def{1})});
        if ~isempty(steps)
            if ~strcmp(steps{1},'Inf')
                steps = strrep(steps{1},',','.');
                steps = str2num(steps);
                if isempty(steps) | steps < 0 | strcmpi(num2str(steps),'NaN')
                    h = msgbox('Please enter a valid number','Error','error');
                    waitfor(h)
                    simeditcb delay
                    return
                else
                    steps = steps(1);
                end
                
            else
                steps = Inf;
            end
            set(h,'UserData',steps)
            set(h,'Label',['Step time: ' num2str(steps)])
        end
        
        
    case 'run'
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        if ~isempty(list)
            simeditcb save
            h = findobj('Tag','EditPath');
            path = get(h,'UserData');
            [path,file,ext] = fileparts(path);
            if ~strcmp([file ext],'untitled.mat')
                simview
                h = findobj('Tag','SimPath');
                set(h,'UserData',path)
                close(gcbf)
                
                pathname = [path '\'];
                filename = [file ext];
                h = findobj('Tag','SimPath');
                set(h,'UserData',[pathname filename]);
                
                simviewcb loadfile;
                simviewcb sim;
            end
        else
            h = msgbox('Please insert at least one robot','Request','warn');
        end
        
        % ****************************
        
        
    case 'close'
        % Maybe some question here ??
        h = findobj('Tag','SensWindow');
        delete(h)
        h = findobj('Tag','PowerWindow');
        delete(h)
        h = findobj('Tag','HeadWindow');
        delete(h)
        h = findobj('Tag','AddrWindow');
        delete(h)
        h = findobj('Tag','Info');
        delete(h)
        h = findobj('Tag','EditorWindow');
        delete(h)
        
end



function LocalDraw(matrix,size_of_marker);

[xmax, ymax] = size(matrix);
[x, y] = find(matrix);


figNumber = findobj('Tag','EditorWindow');
figure(figNumber);
axHndl = findobj('Tag','Axes');
color = get(figNumber,'Color');

plotHndl = plot(x,y,'s', ...
    'Color','black', ...
    'MarkerFaceColor','black',...
    'Tag','mapplot',...
    'MarkerSize',size_of_marker,...
    'Parent',axHndl);

axis equal

set(axHndl, ...
    'XLim',[0 xmax+1],'YLim',[0 ymax+1], ...
    'XDir','normal','YDir','normal', ...
    'Drawmode','fast', ...
    'Visible','on', ...
    'NextPlot','replace', ...
    'Tag','Axes',...
    'TickLength',[0 0],...
    'XColor',color,...
    'YColor',color);


drawnow;
