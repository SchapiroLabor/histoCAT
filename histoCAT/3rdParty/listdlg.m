function [selection,value] = listdlg(varargin)
%LISTDLG  List selection dialog box.
%   [SELECTION,OK] = LISTDLG('ListString',S) creates a modal dialog box 
%   which allows you to select a string or multiple strings from a list.
%   SELECTION is a vector of indices of the selected strings (length 1
%   in the single selection mode).  Can be [] on the Mac, and will be []
%   when OK is 0.
%   OK is 1 if you push the OK button, or 0 if you push the Cancel 
%   button or close the figure.
%   Double-clicking on an item or pressing <CR> when multiple items are
%   selected has the same effect as clicking the OK button.
%
%   Inputs are in parameter,value pairs:
%
%   Parameter       Description
%   'ListString'    cell array of strings for the list box.
%   'SelectionMode' string; can be 'single' or 'multiple'; defaults to
%                   'multiple'.
%   'ListSize'      [width height] of listbox in pixels; defaults
%                   to [160 300].
%   'InitialValue'  vector of indices of which items of the list box
%                   are initially selected; defaults to the first item.
%   'Name'          String for the figure's title. Defaults to ''.
%   'PromptString'  string matrix or cell array of strings which appears 
%                   as text above the list box.  Defaults to {}.
%   'OKString'      string for the OK button; defaults to 'OK'.
%   'CancelString'  string for the Cancel button; defaults to 'Cancel'.
%   'uh'            uicontrol button height, in pixels; default = 18.
%   'fus'           frame/uicontrol spacing, in pixels; default = 8.
%   'ffs'           frame/figure spacing, in pixels; default = 8.
%
%   A 'Select all' button is provided in the multiple selection case.
%
%   Example:
%     d = dir;
%     str = {d.name};
%     [s,v] = listdlg('PromptString','Select a file:',...
%                     'SelectionMode','single',...
%                     'ListString',str)
 
%   T. Krauss, 12/7/95, P.N. Secakusuma, 6/10/97
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 1997/11/21 23:48:53 $

% if first input is an integer, dispatch to callbacks:
% listdlg(0) - OK button callback
% listdlg(1) - cancel button callback
% listdlg(2) - select all button callback
% listdlg(4) - double-click to choose the entry  (Addition by PNS)

if isstr(varargin{1})
    figname = '';
    smode = 2;   % (multiple)
    promptstring = {};
    listsize = [160 300];
    initialvalue = [];
    okstring = 'Ok';
    cancelstring = 'Cancel';
    fus = 8;
    ffs = 8;
    uh = 18;
    
    for i=1:2:length(varargin)

        switch lower(varargin{i})
        case 'name'
            figname = varargin{i+1};
        case 'promptstring'
            promptstring = varargin{i+1};
        case 'selectionmode'
            switch lower(varargin{i+1})
            case 'single'
                smode = 1;
            case 'multiple'
                smode = 2;
            end
        case 'listsize'
            listsize = varargin{i+1};
        case 'liststring'
            liststring = varargin{i+1};
        case 'initialvalue'
            initialvalue = varargin{i+1};
        case 'uh'
            uh = varargin{i+1};
        case 'fus'
            fus = varargin{i+1};
        case 'ffs'
            ffs = varargin{i+1};
        case 'okstring'
            okstring = varargin{i+1};
        case 'cancelstring'
            cancelstring = varargin{i+1};
        end
    end

    if isstr(promptstring)
        promptstring = cellstr(promptstring); 
    end

    if isempty(initialvalue)
        initialvalue = 1;
    end

    ex = get(0,'defaultuicontrolfontsize')*1.5;  % height extent per line of
          % uicontrol text, in pixels (approximate)

    fp = get(0,'defaultfigureposition');
    w = 2*(fus+ffs)+listsize(1);
    h = 2*ffs+6*fus+ex*length(promptstring)+listsize(2)+uh+(smode==2)*(fus+uh);
    fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

    fig_props = { ...
       'name'                   figname ...
       'resize'                 'off' ...
       'numbertitle'            'off' ...
       'windowstyle'            'modal' ...
       'createfcn'              ''    ...
       'position'               fp   ...
       'closerequestfcn'        'set(gcf,''userdata'',''cancel'')' ...
       };

    fig = figure(fig_props{:});

    uicontrol('style','frame',...
         'position',[0 0 fp([3 4])])
    uicontrol('style','frame',...
         'position',[ffs ffs 2*fus+listsize(1) 2*fus+uh])
    uicontrol('style','frame',...
         'position',[ffs ffs+3*fus+uh 2*fus+listsize(1) ...
            listsize(2)+3*fus+ex*length(promptstring)+(uh+fus)*(smode==2)])
    
    if length(promptstring)>0
        prompt_text = uicontrol('style','text','string',promptstring,...
           'horizontalalignment','left','units','pixels',...
           'position',[ffs+fus fp(4)-(ffs+fus+ex*length(promptstring)) ...
                          listsize(1) ex*length(promptstring)]);
    end

    btn_wid = (fp(3)-2*(ffs+fus)-fus)/2;
    ok_btn = uicontrol('style','pushbutton',...
      'string',okstring,...
      'position',[ffs+fus ffs+fus btn_wid uh],...
      'callback','listdlg(0)');
    cancel_btn = uicontrol('style','pushbutton',...
      'string',cancelstring,...
      'position',[ffs+2*fus+btn_wid ffs+fus btn_wid uh],...
      'callback','listdlg(1)');
   
    listbox = uicontrol('style','listbox',...
      'position',[ffs+fus ffs+uh+4*fus+(smode==2)*(fus+uh) listsize],...
      'string',liststring,...
      'backgroundcolor','w',...
      'max',smode,...
      'tag','listbox',...
      'value',initialvalue, ...
      'callback', 'listdlg(4)');

  
  %Commented part for histoCAT
%     if smode == 2
%         selectall_btn = uicontrol('style','pushbutton',...
%           'string','Select all',...
%           'position',[ffs+fus 4*fus+ffs+uh listsize(1) uh],...
%           'tag','selectall_btn',...
%           'callback','listdlg(2)');
% 
%         if length(initialvalue) == length(liststring)
%            set(selectall_btn,'enable','off')
%         end
%         set(listbox,'callback',['listdlg(3); listdlg(4)'])
%     end

    waitfor(fig,'userdata')

    switch get(fig,'userdata')
   
    case 'ok'
        value = 1;
        selection = get(listbox,'value');
    case 'cancel'
        value = 0;
        selection = [];
    end

    delete(fig)

else

    switch varargin{1}

    case 0  % OK button callback
       set(gcf,'userdata','ok')

    case 1  % cancel button callback
       set(gcf,'userdata','cancel')

    case 2  % select all button callback
       listbox = findobj(gcf,'tag','listbox');
       selectall_btn = findobj(gcf,'tag','selectall_btn');
       set(selectall_btn,'enable','off')
       s = get(listbox,'string');
       set(listbox,'value',1:length(s));

    case 3  % listbox callback
       listbox = findobj(gcf,'tag','listbox');
       selectall_btn = findobj(gcf,'tag','selectall_btn');
       v = get(listbox,'value');
       s = get(listbox,'string');
       if length(s)==length(v)
           set(selectall_btn,'enable','off')
       else
           set(selectall_btn,'enable','on')
       end
       
    case 4  % Double-click to choose
       stype = get(gcf, 'SelectionType');
       if (strcmp(stype, 'open')),
          set(gcf, 'userdata', 'ok');   
       end;
       
    end

end


