function Heatmap_slider_tSNE()
% HEATMAP_SLIDER_TSNE: Enables slider for percentile cut-off of heatmap
% overlays on analysis side of GUI and updates it.
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get previous slider value and set the bar of the slider to it
global currentsliderValue_tSNE;

%Get GUI handles
handles = gethand;

%Delete any existing java wrapper
delete(handles.figure1.Children.findobj('Units','pixels'));

%Create slider component and place it
sliderJava = javax.swing.JSlider;
[~, sliderContainer] = javacomponent(sliderJava,[300,30,50,270],handles.figure1);
set(sliderContainer,'Units','normalized','position',[0.7616236162361624,0.025899280575539568,0.12398523985239851,0.05323741007194244]); 

%Set major and minor ticks and initialize to previous slider value
if ~(isempty(currentsliderValue_tSNE) == 1)
    set(sliderJava, 'Value',currentsliderValue_tSNE, 'Orientation',sliderJava.HORIZONTAL,'MinorTickSpacing',2.5,'MajorTickSpacing',10, 'PaintLabels',true,'PaintTicks',true);
else
    set(sliderJava, 'Value',0, 'Orientation',sliderJava.HORIZONTAL,'MinorTickSpacing',2.5,'MajorTickSpacing',10, 'PaintLabels',true,'PaintTicks',true);
end

%Set min and max values, labels and make visible
sliderJava.setMinimum(0)
sliderJava.setMaximum(100);
sliderJava.setPaintLabels(true);
set(sliderContainer,'Visible','on');

%Set slider callback
cmpsliderJava = handle(sliderJava, 'CallbackProperties');
set(cmpsliderJava, 'StateChangedCallback', {@sliderChangedCallbackHeatmap_tSNE});

 
end


%For slider changes
%After changing value of slider in GUI, click on Visualize-Button again in
%order for change to be visible on the image
function sliderChangedCallbackHeatmap_tSNE(src,~, Arg1)
    
    %Store the value of the slider in a global variable so the
    %any function can access it
    global currentsliderValue_tSNE;
    handles = gethand;
    currentsliderValue_tSNE = src.getValue;
    
    %Textbox displaying at what value the slider currently is
    sliderValue = num2str(currentsliderValue_tSNE);
    store_valtext = strcat('cut-off is at',{' '},sliderValue,'%');
    txtbox = uicontrol('Style','text',...
    'Units','normalized','Position',[0.897,0.043,0.049,0.033],...
    'String',store_valtext,'Parent',handles.figure1);
end


