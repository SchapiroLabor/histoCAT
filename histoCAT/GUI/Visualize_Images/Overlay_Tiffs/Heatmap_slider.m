function Heatmap_slider(labelimg)
% HEATMAP_SLIDER: Enables slider for the user to adjust the percentile
% cut-off for the heatmap_images_overlay.
%
% Input:
% labelimg --> selected channel for which the slider will adjust the
% intensities
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get previous slider value to initialize the current slider value
%(since the variable is global it will be applied even if you switch to a different
%image)
global currentsliderValue;

%Get GUI handles
handles = gethand;

%Delete any existing java wrapper
delete(handles.figure1.Children.findobj('Units','pixels'))

%Create slider component
sliderJava = javax.swing.JSlider;
[~, sliderContainer] = javacomponent(sliderJava,[300,30,50,270],handles.figure1);
set(sliderContainer,'Units','normalized','position',[0.2206642066420664,0.020143884892086333,0.1719557195571956,0.07625899280575539]); 

%Set major/ minor ticks and min/ max value and initialize to previous
%settings
if ~(isempty(currentsliderValue) == 1)
    set(sliderJava, 'Value',currentsliderValue, 'Orientation',sliderJava.HORIZONTAL,'MinorTickSpacing',2.5,'MajorTickSpacing',10, 'PaintLabels',true,'PaintTicks',true);
else
    set(sliderJava, 'Value',100, 'Orientation',sliderJava.HORIZONTAL,'MinorTickSpacing',2.5,'MajorTickSpacing',10, 'PaintLabels',true,'PaintTicks',true);
end

sliderJava.setMinimum(0)
sliderJava.setMaximum(100);
sliderJava.setPaintLabels(true);
set(sliderContainer,'Visible','on');

%Set up slider callback
cmpsliderJava = handle(sliderJava, 'CallbackProperties');
set(cmpsliderJava, 'StateChangedCallback', {@sliderChangedCallbackHeatmap,labelimg});

end



function sliderChangedCallbackHeatmap(src,~, Arg1)
% SLIDERCHANGECALLBACKHEATMAP: Gets called whenever the slider value is
% changed by the user. In order for the cut-off to be applied to the image, the
% 'Visualize' button has to be pressed.
    
    %Store the value of the slider in a global variable so the
    %heatmap_images_overlay function can access it for any image that is
    %displayed
    global currentsliderValue;
    handles = gethand;
    currentsliderValue = src.getValue;
    
    %Set textbox to display clearly at what value the slider currently is
    sliderValue = num2str(currentsliderValue);
    store_valtext = strcat('cut-off is at',{' '},sliderValue,'%');
    txtbox = uicontrol('Style','text',...
    'Units','normalized','Position',[0.38671586715867157,0.06330935251798561,0.07011070110701106,0.021582733812949645],...
    'String',store_valtext,'Parent',handles.figure1);

end


