function simviewcb(action)

% Path - in SimPath
% ListStore = for list
% ActualStep - for future enhancements
% SimWindow(UserData) - 1=running, 0=not running

nameSim = 'MRSim - Multi-Robot Simulator v1.0';

switch action
    
    case 'initialize'
        
     
    case 'help'
        open('help/helpMRSim.htm');
        
    case 'about'
        figAbout = figure;
        set(figAbout,'MenuBar','none',...
            'NumberTitle','off',...
            'Name',['About ' nameSim],...
            'RendererMode','manual',...
            'Renderer','Painters',...
            'Backingstore','off',...
            'Position',[450 300 580 400],...
            'Color',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'Tag','SimWindow','units','normalized',...
            'Resize','off');
        uicontrol('Parent',figAbout, ...
            'Units','points', ...
            'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'FontWeight','bold',...
            'HorizontalAlignment','left', ...
            'Position',[10 260 250 15], ...
            'ListboxTop',0, ...
            'FontSize',12, ...
            'String',nameSim, ...
            'Style','text');
        uicontrol('Parent',figAbout, ...
            'Units','points', ...
            'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'HorizontalAlignment','left', ...
            'Position',[10 240 400 15], ...
            'ListboxTop',0, ...
            'FontSize',10, ...
            'String','Institute of Systems and Robotics, Mobile Robotics Laboratory', ...
            'Style','text');
        uicontrol('Parent',figAbout, ...
            'Units','points', ...
            'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'HorizontalAlignment','left', ...
            'Position',[10 225 400 15], ...
            'ListboxTop',0, ...
            'FontSize',10, ...
            'String','Faculty of Sciences and Technology, University of Coimbra', ...
            'Style','text');
         uicontrol('Parent',figAbout, ...
            'Units','points', ...
            'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'HorizontalAlignment','center', ...
            'Position',[10 -50 420 100], ...
            'ListboxTop',0, ...
            'FontSize',7, ...
            'String','© Copyright by Micael S. Couceiro, micaelcouceiro@isr.uc.pt, 2012. All Rights Reserved.', ...
            'Style','text');
        uicontrol('Parent',figAbout, ...
            'Units','points', ...
            'BackgroundColor',[0.752941176470588 0.752941176470588 0.752941176470588], ...
            'HorizontalAlignment','left', ...
            'Position',[10 -70 420 100], ...
            'ListboxTop',0, ...
            'FontSize',7, ...
            'String','Extended from the Autonomous Mobile Robotics Toolbox SIMROBOT (SIMulated ROBOTs) developed at the Department of Control, Measurement and Instrumentation, Faculty of Electrical Engineering and Computer Science, Brno University of Technology, Czech Republic, 2001.', ...
            'Style','text');
        
        axHndl=gca;
        set(axHndl, ...
            'Position',[0.22 0.12 0.6 0.6], ...
            'XDir','normal','YDir','normal', ...
            'Drawmode','fast', ...
            'Visible','on', ...
            'Tag','Axes',...
            'TickLength',[0 0],...
            'XColor',[0.752941176470588 0.752941176470588 0.752941176470588],...
            'YColor',[0.752941176470588 0.752941176470588 0.752941176470588]);
        hold on;
        A=imread('logo.bmp');
        imshow(A);
        drawnow;
    
        
    case 'sim'
        h = findobj('Tag','RunType');
        set(h,'UserData','simulation')
        h = findobj('Tag','SimWindow');
        set(h,'UserData',1)
        h = findobj('Tag','ActualStep');	% Must be here (due to continue option}
        set(h,'UserData',0);
        simviewcb run;
        
    case 'rep'
        h = findobj('Tag','RunType');
        set(h,'UserData','replay');
        h = findobj('Tag','SimWindow');
        set(h,'UserData',1)
        h = findobj('Tag','ActualStep');	% Must be here (continue option}
        set(h,'UserData',0);
        simviewcb run;
        
    case 'run'
        % ****** Menus ******
        h = findobj('Type','uimenu');
        set(h,'Enable','off')
        h = findobj('Tag','WinRunMenu');
        set(h,'Enable','on')
        h = findobj('Tag','StopContMenu');
        set(h,'Enable','on')
        % *******************
        h = findobj('Tag','ActualStep');
        step = get(h,'UserData');
        h = findobj('Tag','SimPath');
        path = get(h,'UserData');
        loadstr = load(path);
        matrix = loadstr.matrix;
        h = findobj('Tag','RunType');
        type = get(h,'UserData');
        h = findobj('Tag','StepsMenu');
        no_steps = get(h,'UserData');
        no_steps = no_steps{1};
        h = findobj('Tag','DelayMenu');
        delay = get(h,'UserData');
        delay = delay{1};
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        % ********* Reset robots **********
        for j = 1:length(list)
            history = gethist(list(j));
            deleteR(list(j))
            list(j) = sethead(list(j),history(1,3));
            list(j) = putrob(list(j),history(1,1:2),matrix);
            list(j) = addinfo(list(j));		% Add context menu
            list(j) = clearcf(list(j));
            list(j) = setpower(list(j),1);
        end
        % *********************************
        
        h = findobj('Tag','StepText');
        
        switch type
            case 'simulation'
                h = findobj('Tag','Track');
                if ~isempty(h)
                    delete(h);
                    drawnow;
                end
                for j = 1:length(list)
                    hist = gethist(list(j));						% Store first history step
                    list(j) = delhist(list(j));
                    list(j) = sethist(list(j),hist(1,:));
                    % We need to clear the buffer of the robots
                    list(j) = cleardata(list(j));
                end
                
                h = findobj('Tag','SimWindow');
                title = get(h,'Name');
                title = strrep(title,'(waiting ...)','(simulating ...)');
                set(h,'Name',title)
                clear functions;      % We need to clear compiled algorithms
                figHndl = findobj('Tag','SimWindow');
                rand('seed',cputime);   % random seed - this is necessary for stochastic algorithms
                while (get(figHndl,'UserData')==1) && (step<1200)
                    step = step + 1;
                    h = findobj('Tag','StepText');
                    set(h,'String',int2str(step))
                    [list,matrix]=runR(list,matrix,step);
                    drawnow;
                    if (delay>0.1)
                        pause(delay);
                    end
                    
                    h = findobj('Tag','StepsMenu');
                    no_steps = get(h,'UserData');
                    no_steps = no_steps{1};
                    
                end
                
                h = findobj('Tag','ActualStep');
                set(h,'UserData',step);
                % This is here for the case of Steps limit condition = true
                % (simviewcb stop is not executed in that case)
                % ****** Menus ******
                h = findobj('Type','uimenu');
                set(h,'Enable','on')
                h = findobj('Tag','StopContMenu');
                set(h,'Enable','off')
                h = findobj('Tag','SimWindow');
                title = get(h,'Name');
                if findstr(title,'simulating')	% This assures unexpected states handling
                    title = strrep(title,'(simulating ...)','(waiting ...)');
                else
                    title = strrep(title,'(replaying ...)','(waiting ...)');
                end
                set(h,'Name',title)
                
                h = findobj('Tag','ListStore');
                set(h,'UserData',list)
                
                
            case 'replay'
                h = findobj('Tag','Track');
                if ~isempty(h)
                    delete(h);
                    drawnow;
                end
                h = findobj('Tag','RunType');
                set(h,'UserData','replay');
                h = findobj('Tag','SimWindow');
                title = get(h,'Name');
                title = strrep(title,'(waiting ...)','(replaying ...)');
                set(h,'Name',title)
                h = findobj('Tag','StepsMenu');
                no_steps = get(h,'UserData');
                no_steps = no_steps{1};
                h = findobj('Tag','StepText');
                figHndl = findobj('Tag','SimWindow');
                true_steps = size(gethist(list(1)));
                true_steps = true_steps(1);
                while (get(figHndl,'UserData')==1) & (step<true_steps-1) & (step<no_steps)
                    step = step + 1;
                    set(h,'String',int2str(step))
                    tic
                    [list,matrix]=guireplay(list,matrix,step+1);
                    drawnow;
                    if (delay>0.1)
                        pause(delay);
                    end
                end
                h = findobj('Tag','ActualStep');
                set(h,'UserData',step);
                % This is here for the case of Steps limit condition = true
                % (simviewcb stop is not executed in that case)
                % ****** Menus ******
                h = findobj('Type','uimenu');
                set(h,'Enable','on')
                h = findobj('Tag','StopContMenu');
                set(h,'Enable','off')
                h = findobj('Tag','SimWindow');
                title = get(h,'Name');
                if findstr(title,'simulating')	% This assures unexpected states handling
                    title = strrep(title,'(simulating ...)','(waiting ...)');
                else
                    title = strrep(title,'(replaying ...)','(waiting ...)');
                end
                set(h,'Name',title)
                
                h = findobj('Tag','ListStore');
                set(h,'UserData',list)
                
        end
        
        
        
        
    case 'stop'
        % ****** Menus ******
        h = findobj('Type','uimenu');
        set(h,'Enable','on')
        h = findobj('Tag','StopContMenu');
        set(h,'Enable','off')
        h = findobj('Tag','RunMenu');
        set(h,'Enable','on')
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        s = size(gethist(list(1)));
        if s(1) == 1
            h = findobj('Tag','RunRepMenu');
            set(h,'Enable','off')
        end
        % *******************
        % ******* *******
        h = findobj('Tag','RunType');
        type = get(h,'UserData');
        h = findobj('Tag','SimWindow');
        title = get(h,'Name');
        if findstr(title,'simulating')	% This assures unexpected states handling
            title = strrep(title,'(simulating ...)','(waiting ...)');
        else
            title = strrep(title,'(replaying ...)','(waiting ...)');
        end
        set(h,'Name',title)
        
        h = findobj('Tag','SimWindow');
        set(h,'UserData',0)
        
        
    case 'tracks'
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        axHndl = findobj('Tag','SimAxes');
        for j = 1:length(list)
            h = line('XData',[],'YData',[],'Tag','Track');
            set(h,'Parent',axHndl);
            data = gethist(list(j));
            xdata = data(:,1);
            ydata = data(:,2);
            set(h,'Color',getcol(list(j)));
            set(h,'XData',xdata,'YData',ydata)
        end
        
        
    case 'save'
        % Here could be some actions to be done before saving (incl. saving refusion)
        simviewcb savefile
        
    case 'savefile'
        h = findobj('Tag','SimPath');
        oldpath = get(h,'UserData');
        loadstr = load(oldpath);
        [path,name,ext] = fileparts(oldpath);
        if strcmp(name,'untitled')
            name = 'newsave';
        end
        [filename,pathname] = uiputfile([name ext],'Save replay');
        if strcmp(filename,'untitled.mat')
            h = msgbox('Error: Cannot save as ''untitled.mat''. Please select another name','Error','error');
            return
        end
        if filename ~= 0											% if any file selected
            h = findobj('Tag','StepsMenu');
            no_steps = get(h,'UserData');
            no_steps = no_steps{1};
            path = [pathname filename];
            h = findobj('Tag','ListStore');
            list = get(h,'UserData');							% Get list
            matrix = loadstr.matrix;							% We need unmodified matrix
            h = findobj('Tag','DelayMenu');
            delay = get(h,'UserData');							% Get delay
            delay = delay{1};
            h = findobj('Tag','ActualStep');
            step = get(h,'UserData');
            s = size(gethist(list(1)));
            if s(1) > 1						% Decide if saving simulation or replay
                type = 'replay';
                %if step > no_steps
                %   dispstr = strvcat('Warning!',['Replay contains ' num2str(step) ' steps.']);
                %   dispstr = strvcat(dispstr,['Steps limit is ', num2str(no_steps)]);
                %   dispstr = strvcat(dispstr,'Would you like to correct the limit?');
                %   dispstr = strvcat(dispstr,'Select ''Yes'' to set the limit equal to replay length');
                %   dispstr = strvcat(dispstr,'Select ''No'' to cut out the replay steps above limit');
                %   dispstr = strvcat(dispstr,'Select ''Cancel'' to abort saving');
                %	answer = questdlg(dispstr,'Question');
                %end
            else
                type='simulation';
            end
            save(path,'list','matrix','no_steps','delay','type');
            h = findobj('Tag','SimPath');						% Store the path
            set(h,'UserData',path);
            h = findobj('Tag','SimWindow');
            title = get(h,'Name');
            title = strrep(title,oldpath,path);
            set(h,'Name',title)
            
        end
        % ***********************************************************
        
        
    case 'load'
         [filename,pathname] = uigetfile('*.mat','Open simulation/replay'); 
%%%%% ete remplacé par
%         filename = '10map2RPSO.mat';
%         pathname = './';
%%%%% 
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
            h = findobj('Tag','SimPath');
            set(h,'UserData',[pathname filename]);
            simviewcb loadfile;
        end
        
        
    case 'loadfile'
        % ****** Disable menus ******
        h = findobj('Tag','TracksMenu');
        set(h,'Enable','off')
        h = findobj('Tag','RunRepMenu');
%         set(h,'Enable','off')
        % ***************************
        % ******** New part ********
        h = findobj('Tag','SimPath');
        path = get(h,'UserData');
        [pathname,filename,ext] = fileparts(path);
        pathname = [pathname '\'];
        filename = [filename ext];
        % **************************
        load([pathname filename]);
        h = findobj('Tag','RunType');
        set(h,'UserData',type);
        h = findobj('Tag','SimWindow');
        title = ['Simulation Window - [' filename ' - ' pathname filename ']' ' (waiting ...)'];
        set(h,'Name',title)
%         h = findobj('Tag','ListStore');
%         list = get(h,'UserData');
        %set(h,'UserData',type)			% Store type of loaded file
        LocalDraw(matrix,2);
        for i = 1:length(list)
            name = getnameR(list(i));
            num = getnum(list(i));
            power = getpower(list(i));
            af = getaf(list(i));
            color = getcol(list(i));
            scale = getscale(list(i));
            shape = getshape(list(i));
            history = gethist(list(i));
            head = history(1,3);
            memory = readmem(list(i));
            list1(i) = simrobot(name,num,head,power,af,color,scale,shape.xdata,shape.ydata);
            list1(i) = putrob(list1(i),history(1,1:2),matrix);
            list1(i) = addsenss(list1(i),getsens(list(i)));
            list1(i) = sethist(list1(i),history);
            list1(i) = addinfo(list1(i));		% Add context menu
            list1(i) = writemem(list1(i),memory);
            
        end
        list = list1;
        h = findobj('Tag','StepText');
        set(h,'String','Step')
        h = findobj('Tag','StepsMenu');
        
        if iscell(no_steps)
            no_steps = no_steps{1};
        end
        
        set(h,'Label',['Steps limit: ' num2str(no_steps)])
        set(h,'Enable','on')
        set(h,'UserData',no_steps)
        h = findobj('Tag','DelayMenu');
        set(h,'Enable','on')
        
        if iscell(delay)
            delay = delay{1};
        end
        
        set(h,'Label',['Step time: ' num2str(delay)])
        set(h,'UserData',delay)
        h = findobj('Tag','ListStore');
        set(h,'UserData',list)				% Store list
        h = findobj('Tag','SimMatrix');
        set(h,'UserData',matrix)			% Store matrix
        h = findobj('Tag','StepsMenu');
        set(h,'UserData',no_steps)
        h = findobj('Tag','DelayMenu');
        set(h,'UserData',delay)
        h = findobj('Tag','RunMenu');
        set(h,'Enable','on')
        h = findobj('Tag','WinRunMenu');
        set(h,'Enable','on')
        h = findobj('Tag','ParMenu');
        set(h,'Enable','on')
        h = findobj('Tag','ParamsMenu');
        set(h,'Enable','on')
        h = findobj('Tag','SaveMenu');
        set(h,'Enable','on')
        h = findobj('Tag','EditMenu');
        set(h,'Enable','on')
        h = findobj('Tag','TracksMenu');
        set(h,'Enable','off')
        if strcmp(type,'replay')
            h = findobj('Tag','RunRepMenu');
            set(h,'Enable','on')
            h = findobj('Tag','TracksMenu');
            set(h,'Enable','on')
        end
        
        
        
        %   	end
        % ***********************************************************
        
        
    case 'editor'
        h = findobj('Tag','RunType');
        type = get(h,'UserData');
        h = findobj('Tag','ListStore');
        list = get(h,'UserData');
        for j = 1:length(list)
            history = gethist(list(j));
            list(j) = setpos(list(j),history(1,1:2));
            list(j) = sethead(list(j),history(1,3));
            list(j) = delhist(list(j));
            list(j) = sethist(list(j),history(1,:));
        end
        h = findobj('Tag','SimPath');
        path = get(h,'UserData');
        loadstr = load(path);
        matrix = loadstr.matrix;
        h = findobj('Tag','DelayMenu');
        delay = get(h,'UserData');							% Get delay
        delay = delay{1};
        h = findobj('Tag','StepsMenu');
        no_steps = get(h,'UserData');
        no_steps = no_steps{1};
        type = 'simulation';
        save(path,'list','matrix','no_steps','delay','type');
        simedit;
        close(gcbf);
        h = findobj('Tag','EditPath');
        set(h,'UserData',path)
        simeditcb loadfile;
        
        
    case 'steps'
        h = findobj('Tag','StepsMenu');
        % Because there ar two menus - context and toolbar - the cell array is returned
        % by get() command, which couldn't be handled by inputdlg
        def = get(h,'UserData');
        def = def{1};
        steps = inputdlg('Steps limit:','Number of steps',[1 14],{num2str(def)});
        if ~isempty(steps)
            if ~strcmp(steps{1},'Inf')
                steps = str2num(steps{1});
                if isempty(steps) | steps <= 0 | strcmpi(num2str(steps),'NaN')
                    h = msgbox('Please enter a valid number','Error','error');
                    waitfor(h)
                    simviewcb steps
                    return
                else
                    steps = round(steps(1));
                end
            else
                steps = Inf;
            end
            set(h,'UserData',steps)
            set(h,'Label',['Steps limit: ' num2str(steps)])
            h = findobj('Tag','RunRepMenu');
            set(h,'Enable','off')
            h = findobj('Tag','TracksMenu');
            set(h,'Enable','off')
        end
        
        
        
    case 'delay'
        h = findobj('Tag','DelayMenu');
        % Because there ar two menus - context and toolbar - the cell array is returned
        % by get() command, which couldn't be handled by inputdlg -> need to be fixed
        def = get(h,'UserData');
        def = def{1};
        steps = inputdlg('Step time (in secs):','Minimal step length',[1 25],{num2str(def)});
        if ~isempty(steps)
            if ~strcmp(steps{1},'Inf')
                steps = strrep(steps{1},',','.');
                steps = str2num(steps);
                if isempty(steps) | steps < 0 | strcmpi(num2str(steps),'NaN')
                    h = msgbox('Please enter a valid number','Error','error');
                    waitfor(h)
                    simviewcb delay
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
        
        
        
    case 'close'
        h = findobj('Tag','SimWindow');
        delete(h)
end

%load(filename);
% Variables = matrix, delay, list, no_steps



function LocalDraw(matrix,size_of_marker);

[xmax, ymax] = size(matrix);
[x, y] = find(matrix);


figNumber = findobj('Tag','SimWindow');
figure(figNumber);
axHndl = findobj('Tag','SimAxes');
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
    'Tag','SimAxes',...
    'TickLength',[0 0],...
    'XColor',color,...
    'YColor',color);


drawnow;
