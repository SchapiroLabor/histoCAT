function [h1,h2,hDivider] = uisplitpane(varargin)
% uisplitpane Split a container (figure/frame/uipanel) into two resizable sub-containers
%
% Syntax:
%    [h1,h2,hDivider] = uisplitpane(hParent, 'propName',propVal,...)
%
% Description:
%    UISPLITPANE splits the specified container(s) (figure, panel or frame,
%    referenced by handle(s) hParent) into two distinct panes (panels)
%    separated by a movable divider. If no hParent container is specified,
%    then the current figure (gcf) is assumed. Matlab components may freely
%    be added to each of the panes. Pane sizes may be modified by dragging
%    or programmatically repositioning the movable divider.
%
%    UISPLITPANE returns the handles to the left/bottom sub-container h1,
%    right/top sub-container h2, and the split-pane divider hDivider.
%    If a vector of several hParents was specified, then h1,h2 & hDivider
%    will be corresponding vectors in the containing hParents. If the
%    hParents are found to be non-unique, then the returned handles will
%    correspond to the unique sorted vector of hParents, so that no hParent
%    will be split more than once.
%
%    The UISPLITPANE divider can be dragged to either side, up to the
%    specified DividerMinLocation to DividerMaxLocation property values
%    (defaults: 0.1 and 0.9 respectively, meaning between 10-90% of range).
%    In Matlab 7+, additional one-click buttons are added to the divider,
%    which enable easy flushing of the divider to either side, regardless
%    of DividerMinLocation & DividerMaxLocation property values.
%
%    Several case-insensitive properties may be specified as P-V pairs:
%      'Orientation':        'horizontal' (default) or 'vertical'
%                            Note: this specifies sub-pane alignment (R/L or U/D):
%                                  divider direction is always perpendicular
%      'Parent':             Handle(s) of containing figure, panel or frame
%      'DividerWidth':       Divider width (1-25 [pixels], default=5)
%      'DividerColor':       Divider color (default = figure background color)
%                            Note: accepts both [r,g,b] and 'colorname' formats
%      'DividerLocation':    Divider normalized initial location (.001-.999, default=0.5)
%                            Note: 0 = far left/bottom, 1 = far right/top
%      'DividerMinLocation': Normalized minimal left/bottom pane size (0-1, default=0.1)
%      'DividerMaxLocation': Normalized maximal left/bottom pane size (0-1, default=0.9)
%
%    hDivider is a standard Matlab object handle possessing all these additional
%    properties. All these properties are gettable/settable via the hDivider
%    handle, except for the 'Orientation' & 'Parent' properties which become
%    read-only after the UISPLITPANE is constructed. hDivider also exposes
%    the following read-only properties:
%      'LeftOrBottomPaneHandle': the h1 value returned by this function
%      'RightOrTopPaneHandle':   the h2 value returned by this function
%      'DividerHandle':          the HG container handle (a numeric value)
%      'JavaComponent':          handle to the underlying java divider obj
%      'ContainerParentHandle':  handle to hParent container
%                                Note: this is important in Matlab 6 which does
%                                ^^^^  not allow hierarchical UI containers
%      'ContainerParentVarName': name of the hParent variable (if available)
%
% Example:
%    [hDown,hUp,hDiv1] = uisplitpane(gcf,'Orientation','ver','dividercolor',[0,1,0]);
%    [hLeft,hRight,hDiv2] = uisplitpane(hDown,'dividercolor','r','dividerwidth',3);
%    t=0:.1:10; 
%    hax1=axes('Parent',hUp);    plot(t,sin(t));
%    hax2=axes('parent',hLeft);  plot(t,cos(t));
%    hax3=axes('parent',hRight); plot(t,tan(t));
%    hDiv1.DividerLocation = 0.75;    % one way to modify divider properties...
%    set(hDiv2,'DividerColor','red'); % ...and this is another way...
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code heavily relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 6+, but use at your own risk!
%    A detailed list of undocumented/unsupported functionality can
%    be found at: <a href="http://undocumentedmatlab.com/blog/uisplitpane">http://UndocumentedMatlab.com/blog/uisplitpane</a>
%
% Change log:
%    2015-01-14: Fixes for HG2 (R2014b); improved mouse-movement performance (responsivity)
%    2014-05-12: Fixes for HG2 (not released, still buggy)
%    2013-05-13: Fixed some HG-Java warnings; fixed the panel's default backgroundcolor to be the same as their parent's bgcolor
%    2010-05-05: Fixed divider size upon dragging (panel resize)
%    2010-04-22: Fixed minor Java issues with the divider sub-component
%    2009-03-30: Fixed DividerColor parent's color based on Co Melissant's suggestion; re-fixed JavaFrame warning
%    2009-03-27: Fixed R2008b JavaFrame warning
%    2009-02-23: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/authors/27420">MathWorks File Exchange</a>
%
% See also:
%    gcf, javax.swing.JSplitPane

% Technical implementation:
%    UISPLITPANE is a Matlab implementation of the Java-Swing
%    javax.swing.JSplitPane component. Since Matlab currently prevents
%    Matlab objects (axes etc.) to be placed within java containers (such as
%    those returned by JSplitPane), a pure-Matlab implementation was needed.
%    JSplitPane is actually used (if available) for the user-interface, but
%    hidden Matlab containers actually display the pane contents.
%
%    The basic idea was to take the platform-dependent divider sub-component
%    created by Java's JSplitPane, and place this divider in a stand-alone
%    Matlab container. Two sub-panes (uipanels or frames) are then placed
%    on either side of this divider. Property linking and divider callbacks
%    are then set in order to ensure that whenever the divider is dragged or
%    programmatically modified, the two sub-panes are updated accordingly.
%
%    Matlab 6 needs special treatment because in that version Java UI
%    components and uipanels were still unavailable. Therefore, standard
%    Matlab uicontrol buttons are used to represent the divider, and frames
%    (instead of uipanels) represent the sub-panes. Also, hierarchical UI
%    controls were not allowed - all controls and axes need to be direct
%    children of the containing figure frame, so special handling needs to
%    be done to correctly handle hierarchical dividers. Additional special
%    handling was also done to overcome bugs/limitations with mouse event
%    tracking in Matlab 6.

% On a personal note, this has been my most challenging project of all my
% submissions to the File Exchange. Ensuring backward compatibility all the
% way back to Matlab 6 proved extremely difficult.

% Programmed by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.8 $  $Date: 2015/01/14 21:09:53 $

  try
      %dbstop if error
      h1 = [];  %#ok
      h2 = [];  %#ok
      hDivider = handle([]);  %#ok

      % Process input arguments
      paramsStruct = processArgs(varargin{:});

      % Capture the parent var name, if supplied
      try
          paramsStruct.parentName = inputname(1);
      catch
          paramsStruct.parentName = '';
      end

      % Split the specified parent container(s)
      [h1, h2, hDivider] = splitPanes(paramsStruct);

      % TODO - setup hContainer return arg

      return;  % debug point

  % Error handling
  catch
      %handleError;
      v = version;
      if v(1)<='6'
          err.message = lasterr;  % no lasterror function...
      else
          err = lasterror;
      end
      try
          err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = findstr(err.message,'Error using ==> ');
              stopIdx = findstr(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(findstr(mfilename,err.message))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end
  end

%% Internal error processing
function myError(id,msg)
    v = version;
    if (v(1) >= '7')
        error(id,msg);
    else
        % Old Matlab versions do not have the error(id,msg) syntax...
        error(msg);
    end
%end  % myError  %#ok for Matlab 6 compatibility

%% Process optional arguments
function paramsStruct = processArgs(varargin)

    % Get the properties in either direct or P-V format
    [parent, pvPairs] = parseparams(varargin);

    % Now process the optional P-V params
    try
        % Initialize
        paramName = [];
        paramsStruct = [];
        paramsStruct.dividercolor = '';

        supportedArgs = {'orientation','parent','tooltip',...
                         'dividerwidth','dividercolor','dividerlocation',...
                         'dividerminlocation','dividermaxlocation'};
        while ~isempty(pvPairs)

            % Ensure basic format is valid
            paramName = '';
            if ~ischar(pvPairs{1})
                myError('YMA:uisplitpane:invalidProperty','Invalid property passed to uisplitpane');
            elseif length(pvPairs) == 1
                myError('YMA:uisplitpane:noPropertyValue',['No value specified for property ''' pvPairs{1} '''']);
            end

            % Process parameter values
            paramName  = pvPairs{1};
            paramValue = pvPairs{2};
            %paramsStruct.(lower(paramName)) = paramValue;  % no good on ML6...
            paramsStruct = setfield(paramsStruct, lower(paramName), paramValue);  %#ok ML6
            pvPairs(1:2) = [];
            if ~any(strcmpi(paramName,supportedArgs))
                url = ['matlab:help ' mfilename];
                urlStr = getHtmlText(['<a href="' url '">' strrep(url,'matlab:','') '</a>']);
                myError('YMA:uisplitpane:invalidProperty',...
                        ['Unsupported property - type "' urlStr ...
                         '" for a list of supported properties']);
            end
        end  % loop pvPairs

        % Process parent container property
        if isfield(paramsStruct,'parent')
            % Parent property supplied as a P-V pair
            if ~all(ishandle(paramsStruct.parent))
                myError('YMA:uisplitpane:invalidProperty','Parent must be a handle of a figure, panel or frame');
            end
        elseif ~isempty(parent)
            % Parent container was supplied as a direct (first) parameter
            paramsStruct.parent = parent{1};
            if ~all(ishandle(paramsStruct.parent))
                myError('YMA:uisplitpane:invalidProperty','Parent must be a handle of a figure, panel or frame');
            end
        else
            % Default parent container = current figure (gcf)
            paramsStruct.parent = gcf;
        end
        % Ensure we don't split any parent container more than once...
        if length(paramsStruct.parent) > length(unique(paramsStruct.parent))
            % Don't sort hParents (a side-effect of the unique() function) unless we have to...
            paramsStruct.parent = unique(paramsStruct.parent);
        end

        % Process DividerColor property
        paramsStruct.dividercolor = processColor(paramsStruct.dividercolor, paramsStruct.parent);

        % Set default param values
        if ~isfield(paramsStruct,'orientation'),         paramsStruct.orientation = 'horizontal';  end
        if ~isfield(paramsStruct,'tooltip'),             paramsStruct.tooltip = '';  end
        if ~isfield(paramsStruct,'dividerwidth'),        paramsStruct.dividerwidth = 5;  end
        if ~isfield(paramsStruct,'dividerlocation'),     paramsStruct.dividerlocation = 0.50;  end
        if ~isfield(paramsStruct,'dividerminlocation'),  paramsStruct.dividerminlocation = 0.1;  end
        if ~isfield(paramsStruct,'dividermaxlocation'),  paramsStruct.dividermaxlocation = 0.9;  end

        % Check min/max data
        checkNumericValue(paramsStruct.dividerminlocation,0,1,'DividerMinLocation');
        checkNumericValue(paramsStruct.dividermaxlocation,0,1,'DividerMaxLocation');
        if paramsStruct.dividermaxlocation <= paramsStruct.dividerminlocation
            myError('YMA:uisplitpane:invalidProperty','DividerMaxLocation must be greater than DividerMinLocation');
        end

        % Check other properties
        checkNumericValue(paramsStruct.dividerlocation,0,1,'DividerLocation');
        checkNumericValue(paramsStruct.dividerwidth,1,25,'DividerWidth');
        if isfield(paramsStruct,'tooltip') & ~ischar(paramsStruct.tooltip)  %#ok ML6
            myError('YMA:uisplitpane:invalidProperty','Tooltip must be a string');
        elseif isfield(paramsStruct,'orientation') & (~ischar(paramsStruct.orientation)  | ...
                (~strncmpi(paramsStruct.orientation,'horizontal',length(paramsStruct.orientation)) & ...
                 ~strncmpi(paramsStruct.orientation,'vertical',  length(paramsStruct.orientation)))) %#ok ML6
            myError('YMA:uisplitpane:invalidProperty','Orientation must be ''horizontal'' or ''vertical''');
        elseif lower(paramsStruct.orientation(1)) == 'h'
            paramsStruct.orientation = 'horizontal';
        else
            paramsStruct.orientation = 'vertical';
        end
    catch
        if ~isempty(paramName),  paramName = [' ''' paramName ''''];  end
        myError('YMA:uisplitpane:invalidProperty',['Error setting uisplitpane property' paramName ':' char(10) lasterr]);
    end
%end  % processArgs  %#ok for Matlab 6 compatibility

%% Check a property value for numeric boundaries
function checkNumericValue(value,minVal,maxVal,propName)
    errMsg = sprintf('number between %g - %g', minVal, maxVal);
    if ~isnumeric(value) | isempty(value)  %#ok ML6
        myError('YMA:uisplitpane:invalidProperty',sprintf('%s must be a %s',propName,errMsg));
    elseif numel(value) ~= 1
        myError('YMA:uisplitpane:invalidProperty',sprintf('%s must be a single %s',propName,errMsg));
    elseif value<minVal | value>maxVal  %#ok ML6
        myError('YMA:uisplitpane:invalidProperty',sprintf('%s must be a %s',propName,errMsg));
    end
%end  % checkNumericValue  %#ok for Matlab 6 compatibility

%% Strip HTML tags for Matlab 6
function txt = getHtmlText(txt)
    v = version;
    if v(1)<='6'
        leftIdx  = findstr(txt,'<');
        rightIdx = findstr(txt,'>');
        if length(leftIdx) ~= length(rightIdx)
            newLength = min(length(leftIdx),length(rightIdx));
            leftIdx  = leftIdx(1:newLength);
            rightIdx = leftIdx(1:newLength);
        end
        for idx = length(leftIdx) : -1 : 1
            txt(leftIdx(idx) : rightIdx(idx)) = [];
        end
    end
%end  % getHtmlText  %#ok ML6

%% Process color argument
function color = processColor(color,hParent)
    try
        % Convert color names to RBG triple (0-1) if not already in that format
        if isempty(color)
            % Get the parent's background color
            if isprop(hParent,'Color')
                color = get(hParent,'color');
            elseif isprop(hParent,'BackgroundColor')
                color = get(hParent,'BackgroundColor');
            elseif isprop(hParent,'Background')
                color = get(hParent,'Background');
            else
                color = get(gcf,'color');  % default = figure background color
            end
        end
        if ischar(color)
            switch lower(color)
                case {'y','yellow'},   color = [1,1,0];
                case {'m','magenta'},  color = [1,0,1];
                case {'c','cyan'},     color = [0,1,1];
                case {'r','red'},      color = [1,0,0];
                case {'g','green'},    color = [0,1,0];
                case {'b','blue'},     color = [0,0,1];
                case {'w','white'},    color = [1,1,1];
                case {'k','black'},    color = [0,0,0];
                otherwise,  myError('YMA:uisplitpane:invalidColor', ['''' color '''']);
            end
        elseif ~isnumeric(color) | length(color)~=3  %#ok ML6
            myError('YMA:uisplitpane:invalidColor', color);
        end

        % Convert decimal RGB format (0-255) to fractional format (0-1)
        if max(color) > 1
            color = color / 255;
        end
    catch
        myError('YMA:uisplitpane:invalidColor',['Invalid color specified: ' lasterr]);
    end
%end  % processColor  %#ok ML6

%% Split the specified parent container(s)
function [h1, h2, hDivider] = splitPanes(paramsStruct)
    % Initialize
    h1 = [];
    h2 = [];
    hDivider = handle([]);

    % Loop over all specified parent containers
    for parentIdx = 1 : length(paramsStruct.parent)
        % Add the divider button to the parent container
        % Note: use temp vars a,b,c to bypass []-handle errors
        [a,b,c] = splitPane(paramsStruct.parent(parentIdx), paramsStruct);
        if parentIdx==1
            if ~isempty(a),  h1 = a;  end
            if ~isempty(b),  h2 = b;  end
            if ~isempty(c),  hDivider = c;  end
        else
            if ~isempty(a),  h1(parentIdx) = a;  end  %#ok<AGROW>
            if ~isempty(b),  h2(parentIdx) = b;  end  %#ok<AGROW>
            try
                if ~isempty(c), hDivider(parentIdx) = c;  end
            catch
                hDivider = c;
            end
        end
    end

    % Clear any invalid handles
    if ~isempty(h1),        h1(h1==0) = [];  end
    if ~isempty(h2),        h2(h2==0) = [];  end
    if ~isempty(hDivider),  hDivider(hDivider==0) = [];  end
%end  % splitPanes  %#ok ML6

%% Split a specific parent container
function [h1, h2, hDivider] = splitPane(hParent, paramsStruct)
    % Initialize
    h1 = [];  %#ok in case of premature exit
    h2 = [];  %#ok in case of premature exit

    % Matlab 6 has a bug that causes mouse movements to be ignored over Frames
    % The workaround is to leave a very small margin next to the divider
    dvMargin = 0;
    v = version;
    if v(1)<='6'
        dvMargin = 0.005;
    end

    % Get the container dimensions
    if strcmpi(paramsStruct.orientation(1),'v')
        % vertical
        dvPos = [0,paramsStruct.dividerlocation,1,paramsStruct.dividerwidth];
        h1Pos = [0,0,1,paramsStruct.dividerlocation-dvMargin];
    else
        % horizontal
        dvPos = [paramsStruct.dividerlocation,0,paramsStruct.dividerwidth,1];
        h1Pos = [0,0,paramsStruct.dividerlocation-dvMargin,1];
    end

    % Prepare the divider
    transformFlag = 0;
    originalParent = hParent;
    try
        hDivider = addDivider(hParent, paramsStruct, dvPos);
    catch
        % Matlab 6 required a uicontrol parent to be a figure, not a frame...
        % get the hParent position in containing figure coordinates
        T = getPos(hParent,'normalized');

        % Hide parent frames so that mouse movements around the divider can be found & fired
        if isa(handle(hParent),'hg.uicontrol')
            set(hParent,'Visible','off');
            % TODO: link originalParent resizing events to this divider (listener?)
        end
        hParent = get(hParent,'parent');

        while ~isempty(hParent) & ishandle(hParent) & hParent~=0  %#ok for Matlab 6 compatibility
            %if ~isa(handle(hParent),'figure')  % this is best but always returns 0 in Matlab 6!
            if ~strcmpi(get(hParent,'type'),'figure')
                parentPos = getPos(hParent,'normalized');
                T = transformParentChildCoords(parentPos, T);
                hParent = get(hParent,'parent');
            else
                break;
            end
        end

        % Reconfigure the split-pane positions in normalized figure coords
        dvPos = transformParentChildCoords(T, dvPos);
        h1Pos = transformParentChildCoords(T, h1Pos);
        %h2Pos = transformParentChildCoords(T, h2Pos);
        transformFlag = 1;

        % Now try again...
        hDivider = addDivider(hParent, paramsStruct, dvPos);
    end

    % Recompute the sub-containers dimensions now that the divider is displayed
    dvPos = get(hDivider,'pos');
    if strcmpi(paramsStruct.orientation(1),'v')
        % vertical
        h2PosStart = paramsStruct.dividerlocation + dvPos(4) + dvMargin;
        h2Pos = [0,h2PosStart,1,1-h2PosStart];
    else
        % horizontal
        h2PosStart = paramsStruct.dividerlocation + dvPos(3) + dvMargin;
        h2Pos = [h2PosStart,0,1-h2PosStart,1];
    end
    if transformFlag
        h2Pos = transformParentChildCoords(T, h2Pos);
    end

    % Setup the mouse-click callback
    mouseDownSetup(hParent);

    % Help messages (right-click context menu)
    %hMenu = uicontextmenu;
    %set(hDivider, 'UIContextMenu',hMenu);
    %uimenu(hMenu, 'Label','drag-able divider', 'Callback',@moveCursor, 'UserData',hDivider);

    % Set the mouse callbacks
    hFig = ancestor(hParent,'figure');
    winFcn = get(hFig,'WindowButtonMotionFcn');
    if ~isempty(winFcn) & ~isequal(winFcn,@mouseMoveCallback) & (~iscell(winFcn) | ~isequal(winFcn{1},@mouseMoveCallback))  %#ok for Matlab 6 compatibility
        setappdata(hFig, 'uisplitpane_oldButtonMotionFcn',winFcn);
    end
    set(hFig,'WindowButtonMotionFcn',@mouseMoveCallback);

    % Prepare the sub-panes
    h1 = addSubPane(hParent,h1Pos);
    h2 = addSubPane(hParent,h2Pos);

    % Add extra props to hDivider
    addSpecialProps(hDivider, h1, h2, paramsStruct, originalParent);

    % Add listeners to hDivider props
    listenedPropNames = {'DividerColor','DividerWidth','DividerLocation','DividerMinLocation','DividerMaxLocation'};
    listeners = addPropListeners(hFig, hDivider, h1, h2, listenedPropNames);
    setappdata(hDivider, 'uisplitpane_listeners',listeners);  % These will be destroyed with hDivider so no need to un-listen upon hDivider deletion
%end  % splitPane6  %#ok ML6

%% Add the divider button
function hDivider = addDivider(hParent,paramsStruct,position)
    try
        % Get a handle to a platform-specific Java divider object
        % by creating an invisible temporary javax.swing.JSplitPane container
        if lower(paramsStruct.orientation(1)) == 'h'
            jsp = javax.swing.JSplitPane(javax.swing.JSplitPane.HORIZONTAL_SPLIT);
        else  % =vertical
            jsp = javax.swing.JSplitPane(javax.swing.JSplitPane.VERTICAL_SPLIT);
        end
        jsp.setOneTouchExpandable(1);
        jdiv = jsp.getComponent(0);
        clear jsp; % release memory
        jpanel = javax.swing.JPanel;
        jpanel.add(jdiv);

        % Place onscreen at the correct position & size (but still normalized to container)
        [jdiv,hDivider] = javacomponent(jdiv, [], hParent);  %#ok jdiv is used for debugging only
%        [jdiv2,hDivider] = javacomponent(jpanel, [], hParent);  %#ok jdiv is used for debugging only
        jdiv = handle(jdiv,'CallbackProperties');
        jdiv.Visible = 1;
        drawnow;
%        pause(0.03);
        jdiv.setLocation(java.awt.Point(0,0));
        set(hDivider, 'tag','uisplitpane divider', 'units','norm', 'pos',position); %[dvPos,0,.01,1]);
        drawnow;
        dvPosPix = getPixelPos(hDivider);
        if lower(paramsStruct.orientation(1)) == 'h'
            newPixelPos = [dvPosPix(1:2) paramsStruct.dividerwidth dvPosPix(4)];
        else  % =vertical
            newPixelPos = [dvPosPix(1:3) paramsStruct.dividerwidth];
        end
        setPixelPos(hDivider,newPixelPos);
        jdiv.setSize(java.awt.Dimension(newPixelPos(3),newPixelPos(4)));
        jdiv.DividerSize = paramsStruct.dividerwidth;

        % Set the divider color
        color = mat2cell(paramsStruct.dividercolor,1,[1,1,1]);
        color = java.awt.Color(color{:});
        jdiv.setBackground(color);
        for childIdx = 1 : jdiv.getComponentCount
            jdiv.getComponent(childIdx-1).setBackground(color);
        end
        
        % Add cross-referencing data
        storeHandles(handle(hDivider),jdiv,hDivider);
        addNewProp(jdiv,'Orientation',paramsStruct.orientation,1);

        % Add resizing & drag/click callbacks
        jdiv.ComponentResizedCallback = @dividerResizedCallback;
        jdiv.MouseDraggedCallback     = @dividerResizedCallback;
        import java.awt.*
        oldWarn = warning('off','MATLAB:hg:PossibleDeprecatedJavaSetHGProperty');
        if paramsStruct.orientation(1)=='h'
            jLeft  = jdiv.getComponent(0);
            jRight = jdiv.getComponent(1);
            set(jLeft, 'ActionPerformedCallback',{@dividerActionCallback,handle(hDivider),jRight,'left'},'ToolTipText','Click to hide left sub-pane');
            set(jRight,'ActionPerformedCallback',{@dividerActionCallback,handle(hDivider),jLeft,'right'},'ToolTipText','Click to hide right sub-pane');
            jLeft.setCursor(Cursor(Cursor.HAND_CURSOR));    % should be Cursor.W_RESIZE_CURSOR but problematic icon on JRE 1.6 = Matlab R2007b+...
            jRight.setCursor(Cursor(Cursor.HAND_CURSOR));   % should be Cursor.E_RESIZE_CURSOR but problematic icon on JRE 1.6 = Matlab R2007b+...
        else
            jTop = jdiv.getComponent(0);
            jBot = jdiv.getComponent(1);
            set(jTop,'ActionPerformedCallback',{@dividerActionCallback,handle(hDivider),jBot,'top'},   'ToolTipText','Click to hide top sub-pane');
            set(jBot,'ActionPerformedCallback',{@dividerActionCallback,handle(hDivider),jTop,'bottom'},'ToolTipText','Click to hide bottom sub-pane');
            jTop.setCursor(Cursor(Cursor.HAND_CURSOR));   % should be Cursor.S_RESIZE_CURSOR but problematic icon on JRE 1.6 = Matlab R2007b+...
            jBot.setCursor(Cursor(Cursor.HAND_CURSOR));   % should be Cursor.N_RESIZE_CURSOR but problematic icon on JRE 1.6 = Matlab R2007b+...
        end
        warning(oldWarn);
    catch
        % Prepare & display the divider button
        hDivider = uicontrol('parent',hParent, 'style','togglebutton', ...
                             'tag','uisplitpane divider', ...
                             'background',paramsStruct.dividercolor, ...  %TODO
                             'tooltip',   paramsStruct.tooltip, ...
                             'enable', 'inactive', ...
                             ... %'callback',@mouseDownCallback, ...
                             ... %'ButtonDownFcn',@mouseDownCallback, ...
                             'units','norm', 'position',position);

        drawnow;
        dvPosPix = getPixelPos(hDivider);
        if lower(paramsStruct.orientation(1)) == 'h'
            newPixelPos = [dvPosPix(1:2) paramsStruct.dividerwidth dvPosPix(4)];
        else  % =vertical
            newPixelPos = [dvPosPix(1:3) paramsStruct.dividerwidth];
        end
        setPixelPos(hDivider,newPixelPos);
        try
            set(hParent,'ResizeFcn',@dividerResizedCallback);
        catch
            % never mind... :-(((
        end
        %jDivider = javax.swing.JButton;
        %set(jDivider,'parent',hParent, 'tag','uisplitpane divider', ...
        %             'background',paramsStruct.dividercolor, ...  %TODO
        %             'tooltip',   paramsStruct.tooltip, 'ButtonDownFcn',@mouseDownCallback);
    end

    % Transform from HG double handle to handle object, so that extra props will become visible in get()
    hDivider = handle(hDivider);
    set(double(hDivider), 'UserData', hDivider);

    % Store the divider handle in the figure's AppData
    hFig = ancestor(hParent,'figure');
    hDividers = getappdata(hFig,'uisplitpane_dividers');
    setappdata(hFig, 'uisplitpane_dividers', [hDividers, hDivider]);
%end  % addDivider  %#ok ML6

%% Add a sub-pane to a parent container
function h = addSubPane(hParent,hPos)
    try
        % Try a uipanel first...
        h = uipanel('parent',hParent, 'units','norm', 'position',hPos, 'bordertype','none', 'tag','uisplitpane');
    catch
        % Error - probably Matlab 6... - try using a frame instead of a panel
        h = uicontrol('parent',hParent, 'style','frame', 'enable', 'inactive', 'units','norm', 'position',hPos, 'tag','uisplitpane');
    end
    
    % Set the panel's bgcolor to the parent's bgcolor
    try
        set(h,'BackgroundColor',processColor([],hParent));
    catch
        % never mind...
    end
%end  % addSubPane %#ok ML6

%% Divider one-click callback function
function dividerActionCallback(varargin)
    try
        jButton = varargin{2}.getSource;
        hDivider = varargin{3};
        jOther = varargin{4};
        str = varargin{5};
        dvPos = getProp(hDivider,'DividerLocation');
        if any(strcmp(str,{'right','top'}))
            flag = (dvPos <= getProp(hDivider,'DividerMinLocation'));  % flushed left/bottom
            dvFlush = 0.99;
        else  % left/bottom
            flag = (dvPos >= getProp(hDivider,'DividerMaxLocation'));  % flushed right/top
            dvFlush = 0.001;
        end
        if flag  % flushed on the side => move back to center
            setProp(hDivider,'DividerLocation',0.5);
            jButton.setToolTipText(['Click to hide ' str ' sub-pane']);
            jOther.setVisible(1);
        else
            setProp(hDivider,'DividerLocation',dvFlush);
            jOther.setToolTipText(['Click to restore ' str ' sub-pane']);
            jButton.setVisible(0);
        end
    catch
        % never mind...
        disp(lasterr);
    end
%end  % dividerActionCallback  %#ok for Matlab 6 compatibility

%% Divider property pre-change callback
function newValue = dividerPropChangedCallback(varargin)
    %try
        [prop,newValue,hFig,hDivider,h1,h2,propName] = deal(varargin{:});
        try newValue = newValue.NewValue;  catch,  end  %#ok ML6 sends EventData obj, not scalar newValue
        try jDivider = getProp(hDivider,'JavaComponent'); catch, end  %#ok
        %disp([propName ' (new value: ' num2str(newValue) ')']);
        switch propName
            case 'DividerLocation'
                checkNumericValue(newValue,.001,.999,'DividerLocation');
                dvPos = get(hDivider,'pos');
                hParent1 = get(hDivider,'Parent');
                hParent2 = getProp(hDivider,'ContainerParentHandle');
                orientation = getProp(hDivider,'Orientation');
                if ~isequal(hParent1,hParent2)
                    % Matlab 6 required a uicontrol parent to be a figure, not a frame...
                    % get the hParent position in containing figure coordinates
                    T = getPos(hParent2,'normalized');
                    newVal2 = T(1:2) + T(3:4) .* newValue([1,1]); % variant of transformParentChildCoords(T, newValue*[1,1,0,0]);
                    if lower(orientation(1))=='h'
                        newValue = newVal2(1);
                    else
                        newValue = newVal2(2);
                    end
                end
                if lower(orientation(1))=='h'
                    set(hDivider,'position',[newValue dvPos(2:4)]);
                else
                    set(hDivider,'position',[dvPos(1) newValue dvPos(3:4)]);
                end
                h1 = getProp(hDivider, 'LeftOrBottomPaneHandle');
                h2 = getProp(hDivider, 'RightOrTopPaneHandle');
                updateSubPaneSizes(h1,h2,hDivider,newValue);
                % Both flush buttons should now become visible, since divider cannot be flushed
                try
                    jDivider = getProp(hDivider,'JavaComponent');
                    jDivider.getComponent(0).setVisible(1);
                    jDivider.getComponent(1).setVisible(1);
                catch
                    % never mind - probably Matlab 6 without jDivider...
                end

            case 'DividerColor'
                newValue = processColor(newValue,get(hDivider,'Parent'));  % convert to [R,G,B]
                color = mat2cell(newValue,1,[1,1,1]);  % java-readable format
                try
                    jDivider.setBackground(java.awt.Color(color{:}));
                catch
                    % probably Matlab 6 without jDivider...
                    set(hDivider, 'BackgroundColor', newValue);
                end
                jDivider.repaint;

            case 'DividerWidth'
                checkNumericValue(newValue,1,25,'DividerWidth');
                dvPos = getPixelPos(hDivider);
                orientation = getProp(hDivider,'Orientation');
                if lower(orientation(1))=='h'
                    setPixelPos(hDivider,[dvPos(1:2),newValue,dvPos(4)]);
                else
                    setPixelPos(hDivider,[dvPos(1:3),newValue]);
                end
                updateSubPaneSizes(h1,h2,hDivider,getProp(hDivider,'DividerLocation'));
                try
                    jDivider.setDividerSize(newValue);
                catch
                    % never mind - probably Matlab 6 without jDivider...
                end
                jDivider.repaint;
                
            case 'DividerMinLocation'
                % nothing to do except check the value and store it for later use
                checkNumericValue(newValue,0,1,propName);
                if newValue >= getProp(hDivider,'DividerMaxLocation')
                    myError('YMA:uisplitpane:invalidProperty','DividerMaxLocation must be greater than DividerMinLocation');
                end

            case 'DividerMaxLocation'
                % nothing to do except check the value and store it for later use
                checkNumericValue(newValue,0,1,propName);
                if newValue <= getProp(hDivider,'DividerMinLocation')
                    myError('YMA:uisplitpane:invalidProperty','DividerMaxLocation must be greater than DividerMinLocation');
                end

            otherwise
                disp(['Unrecognized property: ' propName ' (new value: ' num2str(newValue) ')']);
        end
    %catch
    %    % never mind...
    %    disp(lasterr);
    %    newValue = get(hDivider,propName);  % revert to the current value
    %end
%end  % dividerPropChangedCallback  %#ok for Matlab 6 compatibility

%% Divider resizing callback function
function outsideLimitsFlag = dividerResizedCallback(varargin)
    try
        outsideLimitsFlag = 0;
        try
            hDivider = varargin{1}.MatlabHGContainer;
            hDivider = get(hDivider, 'UserData');
        catch
            try
                hDivider = varargin{2}.AffectedObject;
            catch
                hDivider = handle(findobj(gcbf,'tag','uisplitpane divider'));
            end
        end

        % exit if invalid handle or already in Callback
        if ~ishandle(hDivider) | ~isempty(getappdata(hDivider(1),'inCallback')) %#ok ML6  % | length(dbstack)>1  %exit also if not called from user action
            return;
        end
        setappdata(hDivider(1),'inCallback',1);  % used to prevent endless recursion

        if isempty(varargin{1}) | (~isa(hDivider(1),'hg.uicontrol')) % & varargin{2}.getID == java.awt.event.MouseEvent.MOUSE_DRAGGED)  %#ok ML6
            % This will throw an error in case of a COMPONENT_RESIZED event - that's ok
            pixelPos = getPixelPos(hDivider);
            hParent = getProp(hDivider,'ContainerParentHandle');
            parentPixelPos = getPixelPos(hParent);
            if isequal(hParent, get(hDivider,'Parent'))
                parentPixelPos(1:2) = 0;
            end
            orientation = getProp(hDivider,'Orientation');
            if orientation(1) == 'h'
                deltaX = varargin{2}.getX;
                newDvPos = (pixelPos(1) + deltaX - parentPixelPos(1)) / parentPixelPos(3);
                %disp([pixelPos(1),deltaX,newDvPos,hDivider.DividerLocation])
            else  % vertical
                deltaY = -varargin{2}.getY;
                newDvPos = (pixelPos(2) + deltaY - parentPixelPos(2)) / parentPixelPos(4);
                %disp([pixelPos(2),deltaY,newDvPos,hDivider.DividerLocation])
            end
            outsideLimitsFlag = (newDvPos > getProp(hDivider,'DividerMaxLocation')+.02) | ...
                                (newDvPos < getProp(hDivider,'DividerMinLocation')-.02);
            newDvPos = max(getProp(hDivider,'DividerMinLocation'), newDvPos);
            newDvPos = min(getProp(hDivider,'DividerMaxLocation'), newDvPos);
            setProp(hDivider,'DividerLocation',newDvPos);
        else  % uicontrol - probably ML6
            for hIdx = 1 : length(hDivider)  % might be several in case the Frame was resized in ML6
                pixelPos = getPixelPos(hDivider(hIdx));
                orientation = getProp(hDivider(hIdx),'Orientation');
                if lower(orientation(1)) == 'h'
                    newPixelPos = [pixelPos(1:2) getProp(hDivider(hIdx),'DividerWidth') pixelPos(4)];
                else  % =vertical
                    newPixelPos = [pixelPos(1:3) getProp(hDivider(hIdx),'DividerWidth')];
                end
                if ~isequal(pixelPos,newPixelPos)
                    setPixelPos(hDivider(hIdx),newPixelPos);
                    hLeft  = getProp(hDivider(hIdx),'LeftOrBottomPaneHandle');
                    hRight = getProp(hDivider(hIdx),'RightOrTopPaneHandle');
                    updateSubPaneSizes(hLeft, hRight, hDivider(hIdx), getProp(hDivider(hIdx),'DividerLocation'));
                end
            end
        end
    catch
        % never mind...
        %disp(lasterr);  % COMPONENT_RESIZED events etc.
    end
    %drawnow;
    pause(0.005);
    setappdata(hDivider(1),'inCallback',[]);  % used to prevent endless recursion
%end  % dividerResizedCallback  %#ok for Matlab 6 compatibility

%% Update sub-pane sizes after the divider has moved
function updateSubPaneSizes(h1,h2,hDivider,dvPos)
    try
        dvPixPos = getPixelPos(hDivider);
        hDivider = handle(hDivider);
        orientation = getProp(hDivider,'Orientation');
        if lower(orientation(1))=='h'

            if ~isa(hDivider,'hg.uicontrol')  % regular java obj
                % Left sub-pane
                set(h1,'position',[0,0,dvPos,1]);
                h1PixPos = getPixelPos(h1);
                setPixelPos(h1,[0,0,max(1,h1PixPos(3)-1),h1PixPos(4)+1]);

                %Zach 5/5/2010
                hParent = getProp(hDivider,'ContainerParentHandle');
                tree_handle = findobj(hParent,'UserData','com.mathworks.hg.peer.UITreePeer');
                if (~isempty(tree_handle))
                    pixelPos = getPixelPos(hDivider);
                    set(tree_handle,'Units','pixels')
                    current_tree_pos = get(tree_handle,'Position');
                    set(tree_handle,'Position',[current_tree_pos(1) current_tree_pos(2) pixelPos(1)-2 pixelPos(4)]);
                    drawnow;
                end
                %Zach

                % Right sub-pane
                set(h2,'position',[dvPos,0,1-dvPos,1]);
                h2PixPos = getPixelPos(h2);
                parentPixPos = getPixelPos(hDivider.Parent);
                h2Width = max(1, parentPixPos(3)-dvPixPos(1)-dvPixPos(3)+2);
                setPixelPos(h2,[dvPixPos(1)+dvPixPos(3)-1,0,h2Width,h2PixPos(4)+1]);

            else  % old ML6 uicontrol obj

                % Left sub-pane
                dvPos = hDivider.position;
                hParent = getProp(hDivider,'ContainerParentHandle');
                if ~isequal(hParent,hDivider.Parent)
                    h1Pos = get(hParent,'pos');
                else
                    h1Pos = get(h1,'pos');
                end
                newPos = [h1Pos(1),dvPos(2),max(0.001,dvPos(1)-h1Pos(1)-0.005),dvPos(4)];  % 0.5% margin due to ML6 frame bug: not firing mouse movement events
                set(h1,'pos',newPos);
                updateLogicalSubPane(h1);

                % Right sub-pane
                if ~isequal(hParent,hDivider.Parent)
                    h2Pos = get(hParent,'pos');
                else
                    h2Pos = get(h2,'pos');
                end
                newPos = dvPos(1)+dvPos(3)+0.005;  % 0.5% margin due to ML6 frame bug: not firing mouse movement events
                newPos = [newPos,dvPos(2),max(0.001,h2Pos(1)+h2Pos(3)-newPos),dvPos(4)];
                set(h2,'pos',newPos);
                updateLogicalSubPane(h2);
            end

        else  % vertical

            if ~isa(hDivider,'hg.uicontrol')  % regular java obj
                % Bottom sub-pane
                set(h1,'position',[0,0,1,dvPos]);
                h1PixPos = getPixelPos(h1);
                setPixelPos(h1,[0,0,max(1,h1PixPos(3)),max(1,h1PixPos(4))]);  % theoretically unneeded, used to align with pixel boundaries

                % Top sub-pane
                set(h2,'position',[0,dvPos,1,1-dvPos]);
                h2PixPos = getPixelPos(h2);
                parentPixPos = getPixelPos(hDivider.Parent);
                h2Height = max(1, parentPixPos(4)-dvPixPos(2)-dvPixPos(4));
                setPixelPos(h2,[0,dvPixPos(2)+dvPixPos(4),h2PixPos(3)+3,h2Height]);

            else  % old ML6 uicontrol obj

                % Bottom sub-pane
                dvPos = hDivider.position;
                hParent = getProp(hDivider,'ContainerParentHandle');
                if ~isequal(hParent,hDivider.Parent)
                    h1Pos = get(hParent,'pos');
                else
                    h1Pos = get(h1,'pos');
                end
                newPos = [h1Pos(1:2),dvPos(3),max(0.001,dvPos(2)-h1Pos(2)-0.005)];  % 0.5% margin due to ML6 frame bug: not firing mouse movement events
                set(h1,'pos',newPos);
                updateLogicalSubPane(h1);

                % Top sub-pane
                if ~isequal(hParent,hDivider.Parent)
                    h2Pos = get(hParent,'pos');
                else
                    h2Pos = get(h2,'pos');
                end
                newPos = dvPos(2)+dvPos(4)+0.005;  % 0.5% margin due to ML6 frame bug: not firing mouse movement events
                newPos = [h2Pos(1),newPos,dvPos(3),max(0.001,h2Pos(2)+h2Pos(4)-newPos)];
                set(h2,'pos',newPos);
                updateLogicalSubPane(h2);
            end
        end
    catch
        % never mind...
        disp(lasterr);
    end
    return;
%end  % updateSubPaneSizes  %#ok for Matlab 6 compatibility

%% Update logical child sub-pane size (necessary in ML6 which requires all frames to be children of the figure)
function updateLogicalSubPane(hPane)
    try
        hFig = gcbf;
        if isempty(hFig) %& isa(handle(hPane),'hg.uicontrol')
            hFig = ancestor(hPane,'figure');
        end
        hDivider = handle(findobj(hFig, 'ContainerParentHandle', hPane));
        for hIdx = 1 : length(hDivider)
            hParent = get(hDivider(hIdx),'Parent');
            if ~isequal(hPane,hParent)  % ML6
                dvLoc = getProp(hDivider(hIdx),'DividerLocation');
                pixelPos = getPixelPos(hDivider(hIdx));
                hPanePos = getPixelPos(hPane);
                orientation = getProp(hDivider(hIdx),'Orientation');
                if lower(orientation(1)) == 'h'
                    newDvPos = hPanePos(1) + hPanePos(3)*dvLoc;
                    newPixelPos = [newDvPos hPanePos(2) getProp(hDivider(hIdx),'DividerWidth') hPanePos(4)];
                else  % =vertical
                    newDvPos = hPanePos(2) + hPanePos(4)*dvLoc;
                    newPixelPos = [hPanePos(1) newDvPos hPanePos(3) getProp(hDivider(hIdx),'DividerWidth')];
                end
                if ~isequal(pixelPos,newPixelPos)
                    setPixelPos(hDivider(hIdx),newPixelPos);
                    hLeft  = getProp(hDivider(hIdx),'LeftOrBottomPaneHandle');
                    hRight = getProp(hDivider(hIdx),'RightOrTopPaneHandle');
                    updateSubPaneSizes(hLeft, hRight, hDivider(hIdx), dvLoc);
                end
            end
        end
    catch
        % never mind...
        disp(lasterr);
    end
%end  % updateLogicalSubPane  %#ok for Matlab 6 compatibility

%% Get ancestor figure - used for old Matlab versions that don't have a built-in ancestor()
function hObj = ancestor(hObj,type)
    if ~isempty(hObj) & ishandle(hObj)  %#ok for Matlab 6 compatibility
        try
            hObj = get(hObj,'Ancestor');
        catch
            % never mind...
        end
        try
            %if ~isa(handle(hObj),type)  % this is best but always returns 0 in Matlab 6!
            %if ~isprop(hObj,'type') | ~strcmpi(get(hObj,'type'),type)  % no isprop() in ML6!
            objType=''; try objType=get(hObj,'type'); catch, end  %#ok
            if ~strcmpi(objType,type)
                try
                    parent = get(handle(hObj),'parent');
                catch
                    parent = hObj.getParent;  % some objs have no 'Parent' prop, just this method...
                end
                if ~isempty(parent)  % empty parent means root ancestor, so exit
                    hObj = ancestor(parent,type);
                end
            end
        catch
            % never mind...
        end
    end
%end  % ancestor  %#ok for Matlab 6 compatibility

%% Get position of an HG object in specified units
function pos = getPos(hObj,units)
    % Matlab 6 did not have hgconvertunits so use the old way...
    oldUnits = get(hObj,'units');
    if strcmpi(oldUnits,units)  % don't modify units unless we must!
        pos = get(hObj,'pos');
    else
        set(hObj,'units',units);
        pos = get(hObj,'pos');
        set(hObj,'units',oldUnits);
    end
%end  % getPos  %#ok for Matlab 6 compatibility

%% Get pixel position of an HG object - for Matlab 6 compatibility
function pos = getPixelPos(hObj)
    try
        % getpixelposition is unvectorized unfortunately! 
        pos = getpixelposition(hObj);
    catch
        % Matlab 6 did not have getpixelposition nor hgconvertunits so use the old way...
        pos = getPos(hObj,'pixels');
    end
%end  % getPixelPos  %#ok for Matlab 6 compatibility

%% Set pixel position of an HG object - for Matlab 6 compatibility
function setPixelPos(hObj,pos)
    try
        % getpixelposition is unvectorized unfortunately! 
        setpixelposition(hObj,pos);
    catch
        % Matlab 6 did not have setpixelposition nor hgconvertunits so use the old way...
        old_u = get(hObj,'Units');
        set(hObj,'Units','pixels');
        set(hObj,'Position',pos);
        set(hObj,'Units',old_u);
    end
%end  % setPixelPos  %#ok for Matlab 6 compatibility

%% Transform parent=>child normalized coordinates
function normalizedChildCoords = transformParentChildCoords(normalizedParentCoords,normalizedChildCoords)
    normalizedChildCoords(1:2) = normalizedParentCoords(1:2) + normalizedParentCoords(3:4) .* normalizedChildCoords(1:2);
    normalizedChildCoords(3:4) = normalizedParentCoords(3:4) .* normalizedChildCoords(3:4);
%end  % transformParentChildCoords  %#ok for Matlab 6 compatibility

%% Store the container & component's handles in the component
function storeHandles(hcomp,jcomp,hcontainer)
    try
        % Matlab HG container handle
        sp(1) = schema.prop(jcomp,'MatlabHGContainer','mxArray');
        %sp(2) = schema.prop(hcomp,'MatlabHGContainer','mxArray');  % HG2: addprop(h,propName)
        %set([hcomp,jcomp],'MatlabHGContainer',hcontainer);
        set(jcomp,'MatlabHGContainer',hcontainer);
        try
            linkprops(hcomp,jcomp,'DividerHandle','MatlabHGContainer');
        catch
            % probably HG2...
        end

        % Java component handle (no need to store within jcomp - only in hcomp...)
        try
            sp(end+1) = schema.prop(hcomp,'JavaComponent','mxArray');
            set(hcomp,'JavaComponent',jcomp);
        catch
            % HG2 - R2014b+
            %setappdata(hcomp,'JavaComponent',jcomp);
            hp = addprop(hcomp,'JavaComponent');
            set(hcomp,'JavaComponent',jcomp);
            hp.SetAccess = 'private';
        end

        % Store the handle in the container's UserData
        % Note: javacomponent placed the jcomp classname in here, but the correct place is
        % ^^^^  really in the Tag property, and use UserData to store the handle reference
        set(hcontainer,'UserData',hcomp);

        % Disable public set of these handles - read only
        set(sp,'AccessFlags.PublicSet','off');
    catch
        % never mind...
        disp(lasterr);
    end
%end  % storeHandles  %#ok for Matlab 6 compatibility

%% Add special properties to the hDivider handle
function addSpecialProps(hDivider, h1, h2, paramsStruct, hParent)
    try
        hhDivider = handle(hDivider);

        % Read-only props: handles & Orientation
        addNewProp(hhDivider,'Orientation',            paramsStruct.orientation,1);
        addNewProp(hhDivider,'LeftOrBottomPaneHandle', h1,1);
        addNewProp(hhDivider,'RightOrTopPaneHandle',   h2, 1);
        addNewProp(hhDivider,'DividerHandle',          double(hDivider),1);
        addNewProp(hhDivider,'ContainerParentHandle',  hParent,1);  % necesary for ML6 which requires uicontrols to have figure parent
        addNewProp(hhDivider,'ContainerParentVarName', paramsStruct.parentName,1);

        % Read/write divider props:
        addNewProp(hhDivider,'DividerColor',           paramsStruct.dividercolor);
        addNewProp(hhDivider,'DividerWidth',           paramsStruct.dividerwidth);
        addNewProp(hhDivider,'DividerLocation',        paramsStruct.dividerlocation);
        addNewProp(hhDivider,'DividerMinLocation',     paramsStruct.dividerminlocation);
        addNewProp(hhDivider,'DividerMaxLocation',     paramsStruct.dividermaxlocation);

        % Note: setting the property's GetFunction is much cleaner but doesn't work in Matlab 6...
    catch
        % Never mind...
        disp(lasterr)
    end
%end  % addSpecialProps  %#ok for Matlab 6 compatibility

%% Add new property to supplied handle
function addNewProp(hndl,propName,initialValue,readOnlyFlag,getFunc,setFunc)
    try
        % UDD in HG1 - R2014a or earlier
        sp = schema.prop(hndl,propName,'mxArray');
        set(hndl,propName,initialValue);
        if nargin>3 & ~isempty(readOnlyFlag) & readOnlyFlag  %#ok for Matlab 6 compatibility
            set(sp,'AccessFlags.PublicSet','off');  % default='on'
        end
        if nargin>4 & ~isempty(getFunc)  %#ok for Matlab 6 compatibility
            set(sp,'GetFunction',getFunc);  % unsupported in Matlab 6
        end
        if nargin>5 & ~isempty(setFunc)  %#ok for Matlab 6 compatibility
            set(sp,'SetFunction',setFunc);  % unsupported in Matlab 6
        end
    catch
        % Probably HG2 - R2014b or newer
        %setappdata(hndl, propName, initialValue)
        sp = addprop(hndl,propName);
        set(hndl,propName,initialValue);
        if nargin>3 & ~isempty(readOnlyFlag) & readOnlyFlag  %#ok for Matlab 6 compatibility
            sp.SetAccess = 'private';
        end
        if nargin>4 & ~isempty(getFunc)  %#ok for Matlab 6 compatibility
            sp.GetMethod = getFunc;
        end
        if nargin>5 & ~isempty(setFunc)  %#ok for Matlab 6 compatibility
            sp.SetMethod = setFunc;
        end
    end
%end  % addNewProp  %#ok for Matlab 6 compatibility

%% Add divider property listeners
function listeners = addPropListeners(hFig, hDivider, h1, h2, propNames)
    hhDivider = handle(hDivider);  % ensure a handle obj
    listeners = handle([]);
    for propIdx = 1 : length(propNames)
        prop = findprop(hhDivider, propNames{propIdx});
        try
            % Cell arrays are not accepted by SetMethod property of a DynamicProperty
            callback = @(prop,value)dividerPropChangedCallback(prop, value, hFig, hDivider, h1, h2, propNames{propIdx});  %TODO
            prop.SetMethod = callback;  % HG2 - R2014b+
        catch
            try  % HG1
                callback = {@dividerPropChangedCallback, hFig, hDivider, h1, h2, propNames{propIdx}};  %TODO
                set(prop, 'SetFunction', callback);  % Fails in Matlab 6 so we don't have sanity checks revert in ML6
            catch
                listeners(propIdx) = handle.listener(hhDivider, prop, 'PropertyPreSet', callback);  %#ok mlint - preallocate
            end
        end
    end
    try
        listeners(end+1) = handle.listener(hhDivider, findprop(hhDivider,'Extent'), 'PropertyPostSet', @dividerResizedCallback);
    catch
        % Probably HG2 - no Extent property, while Position property has SetObservable=false so it is not listen-able...
        return;
    end
%end  % addPropListeners  %#ok for Matlab 6 compatibility

%% Link property fields
function linkprops(handle1,handle2,propName,h2PropName)
    if nargin < 3,  h2PropName = propName;  end
    msp = findprop(handle1,propName);
    msp.GetFunction = {@localGetData,handle2,h2PropName};
    msp.SetFunction = {@localSetData,handle2,h2PropName};
%end  % linkprop  %#ok for Matlab 6 compatibility

%% Get the relevant property value from jcomp
function propValue = localGetData(object,propValue,jcomp,propName)  %#ok
    propValue = get(jcomp,propName);
%end  % localGetData  %#ok for Matlab 6 compatibility

%% Set the relevant property value in jcomp
function propValue = localSetData(object,propValue,jcomp,propName)  %#ok
    set(jcomp,propName,propValue);
%end  % localSetData  %#ok for Matlab 6 compatibility

%% Setup the mouse-click callback
function mouseDownSetup(hParent)
    % Matlab 6 has several bugs/problems/limitations with buttonDownFcn, so use figure callback
    try
        v = version;
        if v(1)<='6'
            axisComponent = getAxisComponent(hParent);
            if ~isempty(axisComponent)
                winDownFcn = get(axisComponent,'MouseClickedCallback');
            else
                winDownFcn = get(hParent,'WindowButtonDownFcn');
            end
            if isempty(winDownFcn) | (~isequal(winDownFcn,@mouseDownCallback) & (~iscell(winDownFcn) | ~isequal(winDownFcn{1},@mouseDownCallback)))  %#ok for Matlab 6 compatibility
                % Set the ButtonDownFcn callbacks
                if ~isempty(winDownFcn)
                    setappdata(hParent, 'uisplitpane_oldButtonUpFcn',winDownFcn);
                    setappdata(hParent, 'uisplitpane_oldButtonUpObj',axisComponent);
                end
                if ~isempty(axisComponent)
                    set(axisComponent, 'MouseClickedCallback',{@mouseDownCallback,hParent});
                    addNewProp(axisComponent,'Ancestor',hParent,1);  % remember ancestor HG handle...
                else
                    set(hParent, 'WindowButtonDownFcn',@mouseDownCallback);
                end
            end
            % TODO: chain winDownFcn
        end
    catch
        disp(lasterr);
    end
%end  % mouseDownSetup  %#ok ML6

%% Mouse click down callback function
function mouseDownCallback(varargin)
    try
        % Modify the cursor shape (close hand)
        hFig = gcbf;  %varargin{3};
        if isempty(hFig) & ~isempty(varargin)  %#ok for Matlab 6 compatibility
            hFig = ancestor(varargin{1},'figure');
        end
        if isempty(hFig) | ~ishandle(hFig),  return;  end  %#ok just in case..
        setappdata(hFig, 'uisplitpane_mouseUpPointer',getptr(hFig));
        newPtr = getappdata(hFig, 'uisplitpane_mouseDownPointer');
        if ~isempty(newPtr)
            setptr(hFig, newPtr);
        end

        % Determine the clicked divider
        hDivider = getCurrentDivider(hFig);
        if isempty(hDivider),  return;  end

        % Store divider handle for later use (mouse move/up)
        setappdata(hFig, 'uisplitpane_clickedDivider', hDivider);
    catch
        % Never mind...
        disp(lasterr);
    end
%end  % mouseDownCallback  %#ok for Matlab 6 compatibility

%% Mouse movement callback function
function mouseMoveCallback(hFig, varargin)  % varargin used for debug only
    try
        % Get the figure's current cursor location & check if it's over any divider
        %hFig = gcbf;
        if isempty(hFig) | ~ishandle(hFig),  return;  end  %#ok just in case..

        % Exit if already in progress - don't want to mess everything...
        if isappdata(hFig,'uisplitpane_inProgress'),  return;  end

        % Fix case of Mode Managers (pan, zoom, ...)
        try
            modeMgr = get(hFig,'ModeManager');
            hMode = modeMgr.CurrentMode;
            set(hMode,'ButtonDownFilter',@shouldModeBeInactiveFcn);
        catch
            % Never mind - either an old Matlab (no mode managers) or no mode currently active
        end

        % If in drag mode, mode the divider to the new cursor's position
        inDragMode = isappdata(hFig, 'uisplitpane_clickedDivider');
        %disp({hDivider,inDragMode})
        if inDragMode
            hDivider = getappdata(hFig, 'uisplitpane_clickedDivider');
            event.AffectedObject = hDivider;
            event.getID = java.awt.event.MouseEvent.MOUSE_DRAGGED;
            cp = get(hFig,'CurrentPoint');  % TODO: convert from pixels => norm
            orientation = get(hDivider, 'orientation');
            pixelPos = getPixelPos(hDivider);
            if lower(orientation(1))=='h'  % horizontal
                event.getX = cp(1,1) - pixelPos(1);  % x location
                event.getY = 0;
            else  % vertical
                event.getX = 0;
                event.getY = pixelPos(2) - cp(1,2);  % y location (negative value to simulate Java behavior)
            end
            if (event.getX == 0) & (event.getY == 0)  %#ok ML6
                return;
            elseif dividerResizedCallback([],event)
                mouseUpCallback([],[],hFig);
            end
            
        else  % regular (non-drag) mouse movement
            
            % If mouse pointer is not currently over any divider
            hDivider = getCurrentDivider(hFig);
            if isempty(hDivider) %& ~inDragMode  %#ok for Matlab 6 compatibility
                % Perform cleanup
                mouseOutsideDivider(hFig,inDragMode,hDivider);
            else
                % From this moment on, don't allow any interruptions
                setappdata(hFig,'uisplitpane_inProgress',1);
                mouseOverDivider(hFig,inDragMode,hDivider);
            end
        end
%}
        % Try to chain the original WindowButtonMotionFcn (if available)
        try
%            hgfeval(getappdata(hFig, 'uisplitpane_oldButtonMotionFcn'));
        catch
            % Never mind...
        end
    catch
        % Never mind...
        disp(lasterr);
    end
    rmappdataIfExists(hFig,'uisplitpane_inProgress');

    % Restore original warnings (if available/possible)
    try
%        warning(oldWarn);
    catch
        % never mind...
    end
%end  % mouseMoveCallback  %#ok for Matlab 6 compatibility

%% Mouse click up callback function
function mouseUpCallback(varargin)
    try
        % Restore the previous (pre-click) cursor shape
        hFig = gcbf;  %varargin{3};
        if isempty(hFig) & ~isempty(varargin)  %#ok for Matlab 6 compatibility
            hFig = varargin{3};
            if isempty(hFig)
                hFig = ancestor(varargin{1},'figure');
            end
        end
        if isempty(hFig) | ~ishandle(hFig),  return;  end  %#ok just in case..
        if isappdata(hFig, 'uisplitpane_mouseUpPointer')
            mouseUpPointer = getappdata(hFig, 'uisplitpane_mouseUpPointer');
            set(hFig,mouseUpPointer{:});
            rmappdata(hFig, 'uisplitpane_mouseUpPointer');
        end

        % Cleanup data no longer needed
        rmappdataIfExists(hFig, 'uisplitpane_clickedDivider');

        % Try to chain the original WindowButtonUpFcn (if available)
        oldFcn = getappdata(hFig, 'uisplitpane_oldButtonUpFcn');
        if ~isempty(oldFcn) & ~isequal(oldFcn,@mouseUpCallback) & (~iscell(oldFcn) | ~isequal(oldFcn{1},@mouseUpCallback))  %#ok for Matlab 6 compatibility
            hgfeval(oldFcn);
        end
    catch
        % Never mind...
        disp(lasterr);
    end
%end  % mouseUpCallback  %#ok for Matlab 6 compatibility

%% Mouse movement outside the divider area
function mouseOutsideDivider(hFig,inDragMode,hDivider)  %#ok hDivider is unused
    try
        % Restore the original figure pointer (probably 'arrow', but not necessarily)
        % On second thought, it should always be 'arrow' since zoom/pan etc. are disabled within hDivider
        %if ~isempty(hDivider)
            % Only modify this within hDivider (outside the patch area) - not in other axes - TODO!!!
            oldPointer = get(hFig,'Pointer');
            if ~isequal(oldPointer,'arrow')
                set(hFig, 'Pointer','arrow');
                drawnow;
            end
        %end
        oldPointer = getappdata(hFig, 'uisplitpane_oldPointer');
        if ~isempty(oldPointer)
            %set(hFig, oldPointer{:});  % see comment above
            drawnow;
            rmappdataIfExists(hFig, 'uisplitpane_oldPointer');
            if isappdata(hFig, 'uisplitpane_mouseUpPointer')
                setappdata(hFig, 'uisplitpane_mouseUpPointer',oldPointer);
            end
        end

        % Restore the original ButtonUpFcn callback
        if isappdata(hFig, 'uisplitpane_oldButtonUpFcn')
            oldButtonUpFcn = getappdata(hFig, 'uisplitpane_oldButtonUpFcn');
            axisComponent  = getappdata(hFig, 'uisplitpane_oldButtonUpObj');
            if ~isempty(axisComponent)
                set(axisComponent, 'MouseReleasedCallback',oldButtonUpFcn);
            else
                set(hFig, 'WindowButtonUpFcn',oldButtonUpFcn);
            end
            rmappdataIfExists(hFig, 'uisplitpane_oldButtonUpFcn');
        end

        % Additional cleanup
        rmappdataIfExists(hFig, 'uisplitpane_mouseDownPointer');
    catch
        % never mind...
        disp(lasterr);
    end
%end  % mouseOutsideDivider  %#ok for Matlab 6 compatibility

%% Mouse movement within the divider area
function mouseOverDivider(hFig,inDragMode,hDivider)
    try
        % Separate actions for H/V
        orientation = getProp(hDivider, 'Orientation');
        if lower(orientation(1))=='h'  % horizontal
            shapeStr = 'lrdrag';
        else  % vertical
            shapeStr = 'uddrag';
        end

        % If we have entered the divider area for the first time
        axisComponent = getAxisComponent(hFig);
        if ~isempty(axisComponent)
            winUpFcn = get(axisComponent,'MouseReleasedCallback');
        else
            winUpFcn = get(hFig,'WindowButtonUpFcn');
        end
        if isempty(winUpFcn) | (~isequal(winUpFcn,@mouseUpCallback) & (~iscell(winUpFcn) | ~isequal(winUpFcn{1},@mouseUpCallback)))  %#ok for Matlab 6 compatibility

            % Set the ButtonUpFcn callbacks
            if ~isempty(winUpFcn)
                setappdata(hFig, 'uisplitpane_oldButtonUpFcn',winUpFcn);
                setappdata(hFig, 'uisplitpane_oldButtonUpObj',axisComponent);
            end
            if ~isempty(axisComponent)
                set(axisComponent, 'MouseReleasedCallback',{@mouseUpCallback,hFig});
            else
                set(hFig, 'WindowButtonUpFcn',@mouseUpCallback);
            end

            % Clear up potential junk that might confuse us later
            rmappdataIfExists(hFig, 'uisplitpane_clickedBarIdx');
        end

        % If this is a drag movement (i.e., mouse button is clicked)
        if inDragMode

            % Act according to the dragged object
            dvLimits = get(hDivider, {'dividerMinLocation','dividerMinLocation'});
            cp = get(hFig,'CurrentPoint');  % TODO: convert from pixels => norm
            if strcmpi(orientation,'horizontal')
                dvLocation = cp(1,1);  % x location
            else  % vertical
                dvLocation = cp(1,2);  % y location
            end
            dvLocation = min(max(dvLocation,dvLimits{1}),dvLimits{2});
            set(hDivider,'DividerLocation',dvLocation);

            % Mode managers (zoom/pan etc.) modify the cursor shape, so we need to force ours...
            newPtr = getappdata(hFig, 'uisplitpane_mouseDownPointer');
            if ~isempty(newPtr)
                setptr(hFig, newPtr);
            end

        else  % Normal mouse movement (no drag)

            % Modify the cursor shape
            oldPointer = getappdata(hFig, 'uisplitpane_oldPointer');
            if isempty(oldPointer)
                % Preserve original pointer shape for future use
                setappdata(hFig, 'uisplitpane_oldPointer',getptr(hFig));
            end
            setptr(hFig, shapeStr);
            setappdata(hFig, 'uisplitpane_mouseDownPointer',shapeStr);
        end
        drawnow;
    catch
        % never mind...
        disp(lasterr);
    end
%end  % mouseOverDivider  %#ok for Matlab 6 compatibility

%% Remove appdata if available
function rmappdataIfExists(handle, name)
    if isappdata(handle, name)
        rmappdata(handle, name)
    end
%end  % rmappdataIfExists  %#ok for Matlab 6 compatibility

%% Get the figure's java axis component
function axisComponent = getAxisComponent(hFig)
    try
        if isappdata(hFig, 'uisplitpane_axisComponent')
            axisComponent = getappdata(hFig, 'uisplitpane_axisComponent');
        else
            axisComponent = [];
            oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            javaFrame = get(handle(hFig),'JavaFrame');
            warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
            axisComponent = get(javaFrame,'AxisComponent');
            axisComponent = handle(axisComponent, 'CallbackProperties');
            if ~isprop(axisComponent,'MouseReleasedCallback')
                axisComponent = [];  % wrong axisComponent...
            else
                setappdata(hFig, 'uisplitpane_axisComponent',axisComponent);
            end
        end
    catch
        % never mind...
    end
%end  % getAxisComponent  %#ok for Matlab 6 compatibility

%% Get the divider (if any) that the mouse is currently over
function hDivider = getCurrentDivider(hFig)
    try
        hDivider = handle([]);
        hDividers = getappdata(gcf,'uisplitpane_dividers');
        if isempty(hDividers)
            hDividers = findall(hFig, 'tag','uisplitpane divider');
        end
        hDividers = hDividers(ishandle(hDividers));
        if isempty(hDividers),  return;  end  % should never happen...
        for dvIdx = 1 : length(hDividers)
            dvPos(dvIdx,:) = getPixelPos(hDividers(dvIdx));  %#ok mlint - preallocate
        end
        cp = get(hFig, 'CurrentPoint');  % in Matlab pixels
        inXTest = (dvPos(:,1) <= cp(1)) & (cp(1) <= dvPos(:,1)+dvPos(:,3));
        inYTest = (dvPos(:,2) <= cp(2)) & (cp(2) <= dvPos(:,2)+dvPos(:,4));
        hDivider = hDividers(inXTest & inYTest);
        hDivider = hDivider(min(1:end));  % ensure we return no more than a single hDivider!
        hDivider = handle(hDivider);  % transform into a handle object
    catch
        % never mind...
        disp(lasterr);
    end
%end  % getCurrentDivider  %#ok for Matlab 6 compatibility

%% Determine whether a current mode manager should be active or not (filtered)
function shouldModeBeInactive = shouldModeBeInactiveFcn(hObj, eventData)  %#ok - eventData is unused
    try
        shouldModeBeInactive = 0;
        hFig = ancestor(hObj,'figure');
        hDivider = getCurrentDivider(hFig);
        shouldModeBeInactive = ~isempty(hDivider);
    catch
        % never mind...
        disp(lasterr);
    end
%end  % shouldModeBeActiveFcn  %#ok for Matlab 6 compatibility

%% hgfeval replacement for Matlab 6 compatibility
function hgfeval(fcn,varargin)
    if isempty(fcn),  return;  end
    if iscell(fcn)
        feval(fcn{1},varargin{:},fcn{2:end});
    elseif ischar(fcn)
        evalin('base', fcn);
    else
        feval(fcn,varargin{:});
    end
%end  % hgfeval  %#ok for Matlab 6 compatibility

%% Get/set property value for both HG1, HG2 hand;es
function value = getProp(hndl,propName)
    try
        try
            value = hndl.(propName);
        catch
            value = get(hndl,propName);
        end
    catch
        value = getappdata(hndl,propName);
    end
%end  % getProp

function setProp(hndl,propName,value)
    try
        try
            hndl.(propName) = value;
        catch
            set(hndl,propName,value);
        end
    catch
        setappdata(hndl,propName,value);
    end
%end  % setProp
