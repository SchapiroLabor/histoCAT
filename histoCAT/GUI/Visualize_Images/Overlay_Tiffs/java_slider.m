function java_slider(tiff_matrix)
% Java_SLIDER: Creates a java component slider to adjust the intensity of 
% specific colors in the RGBCMY image and creates a check box for each
% currently used color that can be adjusted.
%
% Input:
% tiff_matrix --> the tiff matrix of the channel(s) that is/are currently displayed
%
% Histology Topography Cytometry Analysis Toolbox (histoCAT)
% Denis Schapiro - Bodenmiller Group - UZH

%Get GUI handles
handles = gethand;

%Delete any existing java wrapper
delete(handles.figure1.Children.findobj('Units','pixels'))

%Create slider component
sliderJava = javax.swing.JSlider;
[~, sliderContainer] = javacomponent(sliderJava,[300,5,50,270],handles.figure1);
set(sliderContainer,'Units','normalized','position',[0.2206642066420664,0.020143884892086333,0.1719557195571956,0.07625899280575539]); 

%Set major/ minor ticks and min/ max value
set(sliderJava, 'Value',0, 'Orientation',sliderJava.HORIZONTAL,'MinorTickSpacing',2.5,'MajorTickSpacing',10, 'PaintLabels',true,'PaintTicks',true);
sliderJava.setMinimum(0)
sliderJava.setMaximum(100);
sliderJava.setPaintLabels(true);

%Create checkbox list
chklistJava = java.util.ArrayList;

%Assign string names based on how many colors/channels (individual tiffs) are
%overlayed
stringval = {'Red','Green','Blue','Cyan','Magenta','Yellow'};
for j=1:length(tiff_matrix{1,1})
    chklistJava.add(j-1,stringval{j});
end

%Prepare the CheckBoxList component within a scroll-pane
javaCBList = com.mathworks.mwswing.checkboxlist.CheckBoxList(chklistJava);
javaScrollPane = com.mathworks.mwswing.MJScrollPane(javaCBList);

%Place scroll-pane within a Matlab container
[~,chkboxContainer] = javacomponent(javaScrollPane,[200,2,80,65],handles.figure1);
set(chkboxContainer,'Units','normalized','position',[0.14686346863468636,0.01330935251798561,0.05011070110701106,0.081582733812949645]);

%Set up the remove noise checkbox
noise_checkbox = uicontrol('Style','checkbox','String','Remove noise','FontSize',8,...
                       'Value',0,'Parent',handles.figure1,'Units','normalized','Position',...
                       [0.01845018450184502,0.04205607476635514,0.07011070110701108,0.021806853582554513]);

%Set up slider callback
cmpsliderJava = handle(sliderJava, 'CallbackProperties');
set(cmpsliderJava, 'StateChangedCallback', {@sliderChangedCallback,javaCBList,tiff_matrix,noise_checkbox});
  
end

%Callback for slider changes
function sliderChangedCallback(src,~,arg1,arg2,arg3)

    %Get GUI handles
    handles = gethand;
    
    %Store the value of the slider
    currentsliderRed = src.getValue;
    
    %Get the value of the checkbox for noise cancellation
    noise_checkbox = arg3;
    
    %Store which color's intensity is being altered
    currentColorselected = arg1.getCheckedIndicies;

    %If no color was selected and slider was operated, return
    if isempty(currentColorselected) == 1 %|| numel(currentColorselected) > 1
        return;
    else
        
        %Store the current tiff-matrices
        Alltiffsmat = arg2;
        
        %Store the color indices from the checkbox
        RGBColourChkboxindex = currentColorselected + 1;
        x = arg1.getCheckedValues;
        put('x',x)
        f = cell(x.toArray)';

        %Set a textbox to display by how much the color is intensified
        store_valtext = sprintf(strcat(num2str(repmat('%s ',1,numel(currentColorselected))),' multiplied by %d'),f{:},currentsliderRed);
        txtbox = uicontrol('Style','text',...
        'Units','normalized','Position',[0.38671586715867157,0.06330935251798561,0.07011070110701106,0.021582733812949645],...
        'String',store_valtext,'Parent',handles.figure1);
        
        %Function call to scaling the images based on slider value
        ScaleTiff_Intensity( Alltiffsmat,currentsliderRed,RGBColourChkboxindex,noise_checkbox );
        
    end
    
end
