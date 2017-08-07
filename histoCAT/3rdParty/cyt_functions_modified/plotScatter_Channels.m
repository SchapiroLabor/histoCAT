function hPlot=plotScatter_Channels
% HPLOT This will plot 2D or 3D plots Colored by channel or Diff of two channels
%
% This function is modified from CYT (Dana Pe'er Lab)
% https://www.c2b2.columbia.edu/danapeerlab/html/cyt-download.html
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

handles      = gethand;
channelNames = retr('list_channels');
sessionData  = retr('sessionData');
gates        = retr('gates');
gateContext  = retr('gateContext');

%Get only those gates which have single cell data
selected_gates_unfiltered = get(handles.list_samples,'Value');
get_tiffgates = find(cellfun('isempty',gates(selected_gates_unfiltered,2)));
if isempty(get_tiffgates) == 1
    selected_gates = selected_gates_unfiltered;
else
    selected_gates = selected_gates_unfiltered(find(~ismember(selected_gates_unfiltered,selected_gates_unfiltered(get_tiffgates))));
end

lightup_sample = retr('lightup_sample');
channels = get(handles.list_channels,'Value');
commonlight = retr('commonlight');
put('meanslist',[]);
put('xv_polygon',[]);
delete(handles.panel_plots.Children);
if numel(channels) > 1 && numel(channels)<4
    selected_channels(1) = channels(1);
    selected_channels(2) = channels(2);
    
    
    try
        selected_channels(3) = channels(3);
    catch
        
    end
else
    return;
end

delete(handles.panel_plots.Children);
%To clear earlier plots from view channels
put('hplots',[]);
put('hplots_gates',[])
put('hist_plot',[])


%Clear plots befor highlighting
if isempty(lightup_sample) ~= 1
    
    delete([lightup_sample{:}]);
end

if isempty(commonlight) ~= 1
    put('commonlight',[]);
    delete(commonlight);
end

put('neighbr_scatter_plotcells',[]);
put('neighbr_scatter',[]);
put('selection_scatter',{});
put('lightup_sample',[]);



try
    if ~(selected_channels(3) > 1)
        selected_channels(3) = [];
    end
catch
    
    %keep empty
end

nSelChannels     = numel(selected_channels);


% if no channel selected => select all channels
if (numel(selected_gates)==0 || nSelChannels==0)
    selected_gates = 1:size(gates, 1);
end



if (isempty(gateContext) || isempty(selected_channels))
    msgbox('selected sample does not have fcs');
    return;
end


nCH1 = selected_channels(1);
nCH2 = selected_channels(2);
nCH3 = 0;
[~,selchannels1] = ismember(channelNames{nCH1},gates{selected_gates(1),3});
[~,selchannels2] = ismember(channelNames{nCH2},gates{selected_gates(1),3});
selchannels3 = 0;

if (nSelChannels == 3)
    nCH3 = selected_channels(3);
    [~,selchannels3] = ismember(channelNames{nCH3},gates{selected_gates(1),3});
end

nChColors = get(handles.list_heatmap,'Value') - 1; %axiscolorby
handles.panel_plots;
%colormap(jet);
%colorbar('delete');

nplots = numel(nChColors);
nrows = floor(nplots/3)+1;
ncols = ceil(nplots/nrows);


for i=1:nplots
    nChColorb = nChColors(i);
    [~,nChColor] = ismember(channelNames{nChColorb},gates{selected_gates(1),3});
    %handles.panel_plots;
    hplots(i) = subplot(nrows, ncols,i,'Parent',handles.panel_plots);
    
    % color by gate
    % scatter all selected gates and color by a channel
    if (numel(selected_gates) >= 1) || nSelChannels ==3
        vX = sessionData(gateContext, selchannels1);
        vY = sessionData(gateContext, selchannels2);
        vColor_without_cutoff = sessionData(gateContext, nChColor);
        %get perc value from slider
        global currentsliderValue_tSNE;
        perc = currentsliderValue_tSNE;
        if ~(isempty(perc) == 1)
            vColor = percentile_cutoff_tSNE(vColor_without_cutoff,handles, perc );
        else
            vColor = vColor_without_cutoff;
        end
        
        
        
        if nplots == 1
            drawnow;
            hplots(i).Position = [0.0750 0.0900 0.91 0.86];
        end
        %unqValues = unique(vColor);
        %if (numel(unqValues) > 10)
        
        g = colormap(hplots(i),jet(numel(linspace(prctile(vColor, 0.3),prctile(vColor, 99.7)))));
        colorbar(hplots(i));%gateContext
        freezeColors;
        clim = [prctile(vColor, 0.3)  prctile(vColor, 99.7)];
        
        if (nSelChannels == 3)
            vZ = sessionData(gateContext, nCH3);
        else
            vZ = rand(1, numel(vX))*(clim(2)-clim(1))+clim(1);
        end
        
        myplotclr(vX, vY, vZ, vColor, '.', g, clim, nSelChannels == 3,hplots(i));
        
        colorbar(hplots(i));
        grid off;
        
        %freezeColors;
        caxis(clim)
    end
    
    xlabel(channelNames{nCH1}, 'Interpreter', 'none');
    ylabel(channelNames{nCH2}, 'Interpreter', 'none');
    
    if nChColor > 0
        [~,chn] = ismember(gates{selected_gates(1),3}(nChColor),channelNames);
        title(channelNames{chn},'Interpreter', 'none');
    elseif nplots > 1
        title('Color by gates','Interpreter', 'none');
    end
    
    if (nSelChannels == 3)
        zlabel(channelNames{nCH3});
        view(3);
    end
    
end %end of for loop

%used in area selection plot(to retain the plotted gates selection and
%many other function to keep a track of what was plotted..(even if user
%chooses other options(like hight sample, merge etc)
selected_gates_plotted = selected_gates;
put('selected_gates_plotted',selected_gates_plotted);

%Store the scatterchannels plot.
put('hplots',hplots);
put('vX',vX);
put('vY',vY);
put('nCH1',selchannels1);
put('nCH2',selchannels2);
if nCH3 ~= 0
    put('nCH3',selchannels3);
end
end

