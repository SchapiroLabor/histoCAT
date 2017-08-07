
function RegressionLine_ScatterPlot(hObject, eventdata, handles)
% REGRESSIONLINE_SCATTERPLOT: Produces scatterplot with linear regressionline 
% and correlation coefficient in GUI. Only for one gate at the time and 2 dimensional plots.
%
% hObject: handle to scatter_plot (see GCBO)
% eventdata: reserved - to be defined in a future version of MATLAB
% handles: structure with handles and user data (see GUIDATA)
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Call scatter plot function
scatter_plot_Callback;

%Retrieve x and y values saved by scatterplot function
vX = retr('vX');
vY = retr('vY');

%Get GUI handles
handles = gethand;

%Get index of currently selected channels
selectedChannels = get(handles.list_channels,'Value');

%If more than 2 channels are selected (3 dimensional plot), no regressionline is displayed
if length(selectedChannels)>2
    msgbox('Regression line is only displayed for 2D plots.');
    return;
end

%Get index of selected gates
selectedGates = retr('selected_gates_plotted');

%If more than one gate is selected, no regressionline is displayed
if length(selectedGates)>1
    msgbox('Regression line is only displayed for one gate at the time.');
    return;
end

%calculate person's correlation coefficient and p-values
[R,P] = corrcoef(vX,vY);

%adding R-value and LS line to plot 
intercept = (sum(vY)*sum(vX.^2)-sum(vX)*sum(vX.*vY))/(length(vX)*sum(vX.^2)-(sum(vX)^2));
slope = (length(vX)*sum(vX.*vY)-sum(vX)*sum(vY))/(length(vX)*sum(vX.^2)-(sum(vX)^2));
refline(slope,intercept); %is exactly the same as lsline

%Define position of R-value on plot
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
xval = 0.8*(xlim(2));
yval = 0.8*(ylim(2));
text(xval,yval,['R=' num2str(R(1,2))]);

end