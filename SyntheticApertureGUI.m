function [] = SyntheticApertureGUI( dir )
%SYNTHETICAPERTUREGUI a GUI that lets the user control the parameters of
% the synthetic aperture. There are two modes: viewpoints and refocus.
% Orientation is defined as: 
% [firstImage, firstColumnInFirstImage, lastImage, lastColumnInLastImage]

figure_handle = figure('MenuBar','none','Name','Synthetic Aperture', ...
    'NumberTitle','off','Position',[200,200,800,600]);

handles = guihandles(figure_handle);

% radio buttons for choosing refocusing / changing viewpoint
handles.refocusRadio = uicontrol('Style','RadioButton','String','refocus' ...
    ,'Position',[10,540,80,20], 'CallBack', @refocusSetup);

handles.viewpointsRadio = uicontrol('Style','RadioButton','String','viewpoints', ...
    'Position', [10,570,80,20], 'CallBack', @viewpointsSetup, 'Value', 1);

% --- LOAD IMAGES FOLDER ---
handles.imagesFolderButton = uicontrol('Style','Edit','String','enter images path here...', ...
    'Position',[600,570,140,20], 'CallBack', @updateImagesFolder);

handles.imagesText = uicontrol('Style','Text','String','images: 0', ...
    'Position',[600,540,80,20]);

% --- VIEWPOINTS STUFF BELOW ---
handles.forwardButton = uicontrol('Style','PushButton','String','Forward', ...
    'Position',[100,570,70,20], 'CallBack', @Forward);

handles.backwardButton = uicontrol('Style','PushButton','String','Backward', ...
    'Position',[180,570,70,20], 'CallBack', @Backward);

handles.leftButton = uicontrol('Style','PushButton','String','Left', ...
    'Position',[260,570,70,20], 'CallBack', @Left);

handles.rightButton = uicontrol('Style','PushButton','String','Right', ...
    'Position',[340,570,70,20], 'CallBack', @Right);

handles.furthestButton = uicontrol('Style','PushButton','String','Furthest', ...
    'Position',[420,570,70,20], 'CallBack', @Furthest);

handles.firstImage = uicontrol('Style','Text','String','', ...
    'Position',[100,540,80,20]);

handles.firstColumn = uicontrol('Style','Text','String','', ...
    'Position',[190,540,80,20]);

handles.lastImage = uicontrol('Style','Text','String','', ...
    'Position',[280,540,80,20]);

handles.lastColumn = uicontrol('Style','Text','String','', ...
    'Position',[370,540,80,20]);

% --- REFOCUS STUFF BELOW ---
handles.distance = 0;

handles.refocusSlider = uicontrol('Style', 'slider',...
        'Min',0,'Max',3,'Value',0, 'Position', [100,570,70,20], ...
        'Callback', @refocus, 'Visible', 'Off'); 
    
handles.closestRefocusButton = uicontrol('Style','PushButton','String','Closest', ...
    'Position',[180,570,70,20], 'CallBack', @ClosestRefocus, 'Visible', 'Off');

handles.centerRefocusButton = uicontrol('Style','PushButton','String','Center', ...
    'Position',[260,570,70,20], 'CallBack', @CenterRefocus, 'Visible', 'Off');

handles.furthestRefocusButton = uicontrol('Style','PushButton','String','Furthest', ...
    'Position',[340,570,70,20], 'CallBack', @FurthestRefocus, 'Visible', 'Off');


handles.numOfImages = 0;

guidata(figure_handle, handles);
    
end

% --- REFOCUS FUNCTIONS ---
function [] = refocus(hObject, eventdata, handles)
handles = guidata(gcbo);

handles.distance = get(handles.refocusSlider, 'value');
UpdateRefocus(handles);

guidata(gcbo, handles);

end

function [] = CenterRefocus(hObject, eventdata, handles)
handles = guidata(gcbo);

handles.distance = 1; % temporary value
set(handles.refocusSlider, 'value', 1);

UpdateRefocus(handles);

guidata(gcbo, handles);

end

function [] = ClosestRefocus(hObject, eventdata, handles)
handles = guidata(gcbo);

handles.distance = 3; % temporary value
set(handles.refocusSlider, 'value', 3);

UpdateRefocus(handles);

guidata(gcbo, handles);

end

function [] = FurthestRefocus(hObject, eventdata, handles)
handles = guidata(gcbo);

handles.distance = 0; % temporary value
set(handles.refocusSlider, 'value', 0);

UpdateRefocus(handles);

guidata(gcbo, handles);

end

function [] = UpdateRefocus(handles)

handles.currImage = Refocus(handles.images, handles.distance);
imshow(handles.currImage);

end

% --- GUI FUNCTIONS BELOW ----
function [] = updateImagesFolder(hObject, eventdata, handles)
handles = guidata(gcbo);

path = get(handles.imagesFolderButton, 'String');
handles.images = LoadImagesDb(path);
handles.numOfImages = size(handles.images, 2);

handles.tempGrayImages = {};
for i = 1:handles.numOfImages
    handles.tempGrayImages{i} = rgb2gray(handles.images{i});
end

imagesText = sprintf('%s %s', 'images:', num2str(size(handles.images, 2)));
set(handles.imagesText, 'String', imagesText);

% calculate canvas size and get shifts
handles.pixelShifts = getPixelShifts(handles.images, 100);
[handles.canvas, handles.firstImRowsOffset] = ...
    createCanvas(handles.pixelShifts, size(handles.images{1}));

% set column step size
handles.columnStepSize = ...
    floor(size(handles.images{1},2) / handles.numOfImages);

% set default orientation
handles.currOrientation = ...
    [1, 1 ,handles.numOfImages, size(handles.images{1},2)];

if get(handles.viewpointsRadio, 'value') == 1
    UpdateOrientation(handles);
    UpdateImage(handles);
end

guidata(gcbo, handles);

end

% change gui to refocus mode
function [] = refocusSetup(hObject, eventdata, handles)
handles = guidata(gcbo);

set(handles.refocusRadio,'value',1)
set(handles.viewpointsRadio,'value',0)

% hide viewpoints buttions
set(handles.forwardButton, 'Visible','Off');
set(handles.backwardButton, 'Visible','Off');
set(handles.leftButton, 'Visible','Off');
set(handles.rightButton, 'Visible','Off');
set(handles.furthestButton, 'Visible','Off');
set(handles.firstImage, 'Visible','Off');
set(handles.firstColumn, 'Visible','Off');
set(handles.lastImage, 'Visible','Off');
set(handles.lastColumn, 'Visible','Off');

% show refocus buttons
set(handles.refocusSlider, 'Visible','On');
set(handles.closestRefocusButton, 'Visible','On');
set(handles.centerRefocusButton, 'Visible','On');
set(handles.furthestRefocusButton, 'Visible','On');

if handles.numOfImages > 0
    handles.distance = 0;
    UpdateRefocus(handles);
end

guidata(gcbo, handles);

end

% change gui to viewpoints mode
function [] = viewpointsSetup(hObject, eventdata, handles)
handles = guidata(gcbo);

set(handles.refocusRadio,'value',0)
set(handles.viewpointsRadio,'value',1)

% hide refocus buttons
set(handles.refocusSlider, 'Visible','Off');
set(handles.closestRefocusButton, 'Visible','Off');
set(handles.centerRefocusButton, 'Visible','Off');
set(handles.furthestRefocusButton, 'Visible','Off');

% show viewpoints buttions
set(handles.forwardButton, 'Visible','On');
set(handles.backwardButton, 'Visible','On');
set(handles.leftButton, 'Visible','On');
set(handles.rightButton, 'Visible','On');
set(handles.furthestButton, 'Visible','On');
set(handles.firstImage, 'Visible','On');
set(handles.firstColumn, 'Visible','On');
set(handles.lastImage, 'Visible','On');
set(handles.lastColumn, 'Visible','On');

if handles.numOfImages > 0
    % set default orientation
    handles.currOrientation = ...
        [1, 1 ,handles.numOfImages, size(handles.images{1},2)];

    UpdateOrientation(handles);
    UpdateImage(handles);
end

guidata(gcbo, handles);

end

% --- VIEWPOINTS FUNCTIONS ---
function [] = Furthest(hObject, eventdata, handles)
handles = guidata(gcbo);

handles.currOrientation = ...
    [1, 1 ,handles.numOfImages, size(handles.images{1},2)];

UpdateOrientation(handles);
UpdateImage(handles);

guidata(gcbo, handles);

end

function [] = Forward(hObject, eventdata, handles)
handles = guidata(gcbo);

if handles.currOrientation(2) > 1 
    handles.currOrientation(2) = handles.currOrientation(2) ...
        - handles.columnStepSize;
elseif handles.currOrientation(1) < handles.numOfImages
    handles.currOrientation(1) = handles.currOrientation(1) + 1;
end

if handles.currOrientation(4) < size(handles.images{1},2)
    handles.currOrientation(4) = handles.currOrientation(4) ...
        + handles.columnStepSize;
elseif handles.currOrientation(3) > 1 
    handles.currOrientation(3) = handles.currOrientation(3) - 1;
end

% polar switch
if handles.currOrientation(4) < handles.currOrientation(2)
    newFirstImage = handles.currOrientation(3);
    newFirstColumn = handles.currOrientation(4);
    newLastImage = handles.currOrientation(1);
    newLastColumn = handles.currOrientation(2);
    handles.currOrientation(1) = newFirstImage;
    handles.currOrientation(2) = newFirstColumn;
    handles.currOrientation(3) = newLastImage;
    handles.currOrientation(4) = newLastColumn;
end

UpdateOrientation(handles);
UpdateImage(handles);

guidata(gcbo, handles);

end

function [] = Backward(hObject, eventdata, handles)
handles = guidata(gcbo);

if handles.currOrientation(1) > 1 
    handles.currOrientation(1) = handles.currOrientation(1) - 1;
elseif handles.currOrientation(2) < size(handles.images{1},2)
    handles.currOrientation(2) = handles.currOrientation(2) ...
        + handles.columnStepSize;
end

if handles.currOrientation(3) < handles.numOfImages
    handles.currOrientation(3) = handles.currOrientation(3) + 1;
elseif handles.currOrientation(4) > 1
    handles.currOrientation(4) = handles.currOrientation(4) ...
        - handles.columnStepSize;
end

% polar switch
if handles.currOrientation(4) < handles.currOrientation(2)
    newFirstImage = handles.currOrientation(3);
    newFirstColumn = handles.currOrientation(4);
    newLastImage = handles.currOrientation(1);
    newLastColumn = handles.currOrientation(2);
    handles.currOrientation(1) = newFirstImage;
    handles.currOrientation(2) = newFirstColumn;
    handles.currOrientation(3) = newLastImage;
    handles.currOrientation(4) = newLastColumn;
end

UpdateOrientation(handles);
UpdateImage(handles);

guidata(gcbo, handles);

end

function [] = Right(hObject, eventdata, handles)
handles = guidata(gcbo);

% positive slope of space-time volume cut
if handles.currOrientation(1) <= handles.currOrientation(3)
    if handles.currOrientation(3) < handles.numOfImages
        handles.currOrientation(3) = handles.currOrientation(3) + 1;
    elseif handles.currOrientation(4) > 1
        handles.currOrientation(4) = handles.currOrientation(4) ... 
            - handles.columnStepSize;
    end

    if handles.currOrientation(2) > 1
        handles.currOrientation(2) =  handles.currOrientation(2) - 1;
    elseif handles.currOrientation(1) < handles.numOfImages
        handles.currOrientation(1) = handles.currOrientation(1) + 1;
    end
else
    % negative slope of space-time volume cut
    if handles.currOrientation(1) < handles.numOfImages
        handles.currOrientation(1) = handles.currOrientation(1) + 1;
    elseif handles.currOrientation(2) < size(handles.images{1},2)
        handles.currOrientation(2) = handles.currOrientation(2) ...
            + handles.columnStepSize;
    end

    if handles.currOrientation(4) < size(handles.images{1},2)
        handles.currOrientation(4) = handles.currOrientation(4) ...
            + handles.columnStepSize;
    elseif handles.currOrientation(3) < handles.numOfImages
        handles.currOrientation(3) = handles.currOrientation(3) + 1;
    end
end

UpdateOrientation(handles);
UpdateImage(handles);

guidata(gcbo, handles);

end

function [] = Left(hObject, eventdata, handles)
handles = guidata(gcbo);

% positive slope of space-time volume cut
if handles.currOrientation(1) <= handles.currOrientation(3)
    if handles.currOrientation(1) > 1
        handles.currOrientation(1) = handles.currOrientation(1) - 1;
    elseif handles.currOrientation(2) < size(handles.images{1},2)
        handles.currOrientation(2) = handles.currOrientation(2) ...
            + handles.columnStepSize;    
    end

    if handles.currOrientation(4) < size(handles.images{1},2)
        handles.currOrientation(4) = handles.currOrientation(4) ...
            + handles.columnStepSize;
    elseif handles.currOrientation(3) > 1
        handles.currOrientation(3) = handles.currOrientation(3) - 1;
    end
else
    % negative slope of space-time volume cut
    if handles.currOrientation(2) > 1
        handles.currOrientation(2) = handles.currOrientation(2) ...
            - handles.columnStepSize;
    elseif handles.currOrientation(1) > 1
        handles.currOrientation(1) = handles.currOrientation(1) - 1;
    end

    if handles.currOrientation(3) > 1
        handles.currOrientation(3) = handles.currOrientation(3) - 1;
    elseif handles.currOrientation(4) > 1
        handles.currOrientation(4) = handles.currOrientation(4) ...
            - handles.columnStepSize;
    end
end

UpdateImage(handles);
UpdateOrientation(handles);

guidata(gcbo, handles);

end

function [] = UpdateOrientation(handles)

firstImageText = sprintf('first image: %d', handles.currOrientation(1));
set(handles.firstImage, 'String', firstImageText);

firstColumnText = sprintf('first column: %d', handles.currOrientation(2));
set(handles.firstColumn, 'String', firstColumnText);

lastImageText = sprintf('last image: %d', handles.currOrientation(3));
set(handles.lastImage, 'String', lastImageText);

lastColumnText = sprintf('last column: %d', handles.currOrientation(4));
set(handles.lastColumn, 'String', lastColumnText);

end

function [] = UpdateImage(handles)

currImage = CreateImage(handles.tempGrayImages, handles.pixelShifts, ...
    handles.currOrientation(1), handles.currOrientation(3)); 
handles.currImage = compilePanorama(handles.canvas, currImage, ...
    handles.pixelShifts, handles.currOrientation(1), handles.firstImRowsOffset);

imshow(handles.currImage);

end