function hLine = dplot(data, varargin)
% dplot(data, varargin)
% Produces up to 12 distinct line color/style combinations using ksdensity
% PARAMS
% @data: nx1 vector
% @kernelwidth: value in the range of 0.01 to 1, 'default' uses automatic
% selection by ksdensity function
% @linewidth: if no value or 'default' is entered, default is 2.
% @'colors', 'bluegrey': changes ColorOrder to Blue, Grey
% @'colors', 'fourcolors': Blue, cyan, magenta, green
% @'colors', colormatrix: enter n x 3 RGB colormatrix.

%defaults
linewidth = 2;


for i = 1:2:length(varargin)
    switch varargin{i}
        
        case 'kernelwidth'
            kernelwidth = varargin{i+1};
            
        case 'linewidth'
            linewidth = varargin{i+1};
            
        case 'colors'
            if strmatch(varargin{i+1}, 'bluegrey')
                colormat = [0 0 1; .5 .5 .5];
            elseif strmatch(varargin{i+1}, 'fourcolors')
                colormat = [0 0 1; 0 1 1; 1 0 1; 0 .8 .2];
            else
                colormat = varargin{i+1};
            end
            
            set(gcf, 'DefaultAxesColorOrder', colormat )
            freezeColors;
    end
end
            

if ~exist('linewidth','var') || strcmpi(linewidth,'default')
    linewidth = 2;
end
   
%set(gcf, 'DefaultAxesLineStyleOrder',{'-','--',':'})
%blue and grey:
%set(0, 'DefaultAxesColorOrder', [0 0 1; .5 .5 .5])
%blue, cyan, magenta, green:
hold all

if ~exist('kernelwidth','var') || strcmpi(kernelwidth,'default')
    [f,xi] = ksdensity(data,'npoints',200);
else
    [f,xi] = ksdensity(data,'npoints',200,'width',kernelwidth);
end
hLine = plot(xi,f,'LineWidth',linewidth);



% %code below uses kde from file exchange
% [~,f,xi,~] = kde(data);
% plot(xi,f,'LineWidth',linewidth)
% %following required for kde function which can result in Y lowerlimit < 0
% %YL = get(gca,'ylim');
% %set(gca, 'ylim',[0 YL(2)]);