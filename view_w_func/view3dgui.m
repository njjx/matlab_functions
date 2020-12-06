function varargout = view3dgui(varargin)
%
% view3dgui(img3d,[dx dy dz])
% view3dgui(img3d,dicom_info_structure)
% view3dgui(img3d,...,mask)
% view3dgui(img3d,...,'mask',mask)
% view3dgui(img3d,...,'mvx',mvx,'mvy',mvx,'mvz',mvz)
% view3dgui(img3d,...,'dvf_grid_size',[dx dy dz])
%
% Programmed by Deshan Yang, Washington University, 2007
% Email: dyang@radonc.wustl.edu
%{
Copyrighted by:

Deshan Yang, dyang@radonc.wustl.edu
10/10/2007
Department of radiation oncology
Washington University in Saint Louis
%}

persistent input_var_name;
if ~ischar(varargin{1}) && ~isa(varargin{1},'timer')
	for n = 1:nargin
		if ~ischar(varargin{n})
			input_var_name = [input_var_name '-' inputname(n)];
		end
	end
end

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view3dgui_OpeningFcn, ...
                   'gui_OutputFcn',  @view3dgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if isa(varargin{1},'timer')
	Timer_Callback_UpdateDisplay(varargin{:});
else
	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else
		gui_mainfcn(gui_State, varargin{:});
	end
	% End initialization code - DO NOT EDIT

	if ~isempty(gcbf) && ~isempty(input_var_name)
		set(gcbf,'Name',['View3D - ' input_var_name]);
		input_var_name = [];
    end
    
    
    
end
% --- Executes just before view3dgui is made visible.
function view3dgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view3dgui (see VARARGIN)

% Choose default command line output for view3dgui
handles.output = hObject;
handles.displaymode=1;


% This sets up the initial plot - only do when we are invisible
% so window can get raised using view3dgui.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

%set(handles.figure1,'color','black');

% UIWAIT makes view3dgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.figure1,'CurrentAxes',handles.mainaxes);
%set(handles.mainaxes,'nextPlot','Add')
handles.mask = [];
handles.structure_names = [];
handles.aspects = [1 1 1];
handles.interpolation = 0;
handles.landmarks = [];
handles.reference_landmarks = [];
handles.slicenos = [1 1 1];
handles.display_pixel_info = 0;
handles.flipX = 0;
handles.flipY = 1;
handles.flipZ = 0;
handles.rotation=0;
handles.showDVF = 0;

handles.zoom_factors = [1 1 1];
handles.zoom_centers = [0 0;0 0;0 0];
handles.rgb_image = 0;
handles.motion_grid_size = [6 6 4];
handles.mvx = [];
handles.mvy = [];
handles.mvz = [];
handles.max = 2000;
handles.is4d = 0;
handles.image4dnum = 1;
handles.NumImages = 1;

handles.Process_Stones_Callback=[];

if( ~isempty(varargin) )
	handles.image =  varargin{1};
	%handles.image = handles.image/max(handles.image(:));
	handles.min = min(handles.image(:));
	handles.max = max(handles.image(:));
	set(handles.viewpopupmenu,'Enable','On');
	set(handles.slicenoslider,'Enable','On');
	set(handles.slicenoinput,'Enable','On');
	set(handles.maxtext,'Enable','On');
	set(handles.mintext,'Enable','On');

	dim = mysize(handles.image);
	if length(dim) == 4
		if dim(3) == 3
			handles.rgb_image = 1;
			dim = [dim(1) dim(2) dim(4)];
		else
			handles.is4d = 1;
			handles.NumImages = dim(4);
			handles.image4dnum = 1;
			handles.image4d = handles.image;
			handles.image = handles.image4d(:,:,:,handles.image4dnum);
			dim = dim(1:3);
			set(gcbf,'Name','View3D - Image #1');
		end
	end
	handles.dim = dim;
	handles.zoom_centers = [dim(2)/2 dim(3)/2;dim(1)/2 dim(3)/2;dim(2)/2 dim(1)/2];
	handles.slicenos = round(dim/2);

	if( length(varargin) > 1 )
		for n = 2:length(varargin)
			if ischar(varargin{n})
				switch lower(varargin{n})
					case {'displaymode','display','mode'}
						if ~ischar(varargin{n+1})
							handles.displaymode = varargin{n+1};
						else
							switch lower(varargin{n+1})
								case 'transverse'
									handles.displaymode = 3;
								case 'sagittal'
									handles.displaymode = 2;
								case 'coronal'
									handles.displaymode = 1;
							end
						end
					case {'ratio','ratios'}
						handles.aspects = varargin{n+1};
						if length(handles.aspects) == 1
							handles.aspects = [1 1 handles.aspects];
						end
					case {'mask','contour'}
						handles.mask = varargin{n+1};
					case {'structurenames','names'}
						handles.structure_names = varargin{n+1};
					case {'interpolation'}
						handles.interpolation = 1;
					case {'transverse','axial'}
						handles.displaymode = 3;
					case 'sagittal'
						handles.displaymode = 2;
					case 'coronal'
						handles.displaymode = 1;
					case 'mvx'
						handles.mvx = varargin{n+1};
					case 'mvy'
						handles.mvy = varargin{n+1};
					case 'mvz'
						handles.mvz = varargin{n+1};
					case 'dvf_grid_size'
						handles.motion_grid_size = varargin{n+1};
                    case 'flipz'
                        handles.flipZ=varargin{n+1};
					otherwise
						if isfield(handles,varargin{n})
							handles.(varargin{n}) = varargin{n+1};
						end
				end
			elseif isstruct(varargin{n}) && isfield(varargin{n},'SliceThickness')	% A dicom info struct
				info = varargin{n};
% 				if sum(abs(abs(info.ImageOrientationPatient)-[1;0;0;0;1;0])) < 0.01
% 					% this is transverse image
% 					handles.aspects = [info.PixelSpacing ; info.SliceThickness];
% 					handles.aspects = handles.aspects / min(handles.aspects);
% 				elseif sum(abs(abs(info.ImageOrientationPatient)-[1;0;0;0;0;1])) < 0.01
% 					% this is coronal image
% 					handles.aspects = [info.PixelSpacing(1) ; info.SliceThickness; info.PixelSpacing(2)];
% 					handles.aspects = handles.aspects / min(handles.aspects);
% 				elseif sum(abs(abs(info.ImageOrientationPatient)-[0;1;0;0;0;1])) < 0.01
% 					% this is sagittal image
% 					handles.aspects = [info.SliceThickness; info.PixelSpacing];
% 					handles.aspects = handles.aspects / min(handles.aspects);
% 				else
					% oblique position
% 					orientation = 'obl';
					handles.aspects = [info.PixelSpacing ; info.SliceThickness];
					handles.aspects = handles.aspects / min(handles.aspects);
% 				end
% 				handles.aspects = 1./handles.aspects;
				
			elseif ischar(varargin{n-1})
				continue;
			else
				if isequal(size(varargin{n}),handles.dim)
					handles.mask = single(varargin{n});
				elseif iscell(varargin{n}) && ~isempty(varargin{n}) && isequal(size(varargin{n}{1}),size(varargin{1}))
					handles.mask = varargin{n};
				elseif numel(varargin{n}) == 3
					handles.aspects = varargin{n};
				elseif numel(varargin{n}) == 1
					handles.aspects = [1 1 varargin{n}];
				end
			end
		end
	end

	if dim(3) == 1
		handles.displaymode = 3;
	end
	set(handles.viewpopupmenu,'value',handles.displaymode);
	
	handles = init_window_controls(handles);
	guidata(hObject, handles);
	ConfigureSlider(handles);
	guidata(handles.figure1,handles);
	UpdateDisplay(handles);
else
	img = zeros(10,10);
	imagesc(img),colormap('gray');
	axis off;
end


% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = view3dgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
%varargout{1} = handles.output;
varargout{1} = handles.output;
varargout{2} = handles.figure1;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1
        plot(rand(5));
    case 2
        plot(sin(1:0.01:25.99));
    case 3
        bar(1:.5:10);
    case 4
        plot(membrane);
    case 5
        surf(peaks);
end


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});



% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.mat'}, 'Load 3D imag');	% Load a 3D image in MATLAB *.mat file
if( filename ~= 0 )
	handles.filename = [pathname,filename];
	img=load(handles.filename);
	fname = fieldnames(img);
	handles.image = getfield(img,fname{:});
	%handles.image = handles.image / max(handles.image(:));
	handles.min = min(handles.image(:));
	handles.max = max(handles.image(:));
	guidata(handles.figure1,handles);

	set(handles.viewpopupmenu,'Enable','On');
	set(handles.slicenoslider,'Enable','On');
	set(handles.slicenoinput,'Enable','On');
	set(handles.maxtext,'Enable','On');
	set(handles.mintext,'Enable','On');
	
	ConfigureSlider(handles);
	handles = init_window_controls(handles);
	guidata(handles.figure1,handles);
	UpdateDisplay(handles);
end


% --- Executes on selection change in viewpopupmenu.
function viewpopupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to viewpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns viewpopupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from viewpopupmenu

displaymode = get(handles.viewpopupmenu,'Value');
if( handles.displaymode ~= displaymode )
	handles.displaymode = displaymode;
	ConfigureSlider(handles);
end

function ConfigureSlider(handles)
if( handles.displaymode <= 3 )
	maxv = handles.dim(handles.displaymode);
else
	maxv = 256;
end

if maxv == 1
	slider_step = [1 1];
else
	slider_step = 1/(maxv-1);slider_step(2) = 5/(maxv-1);
end
set(handles.slicenoslider,'sliderstep',slider_step);
% set(handles.slicenoslider,'max',maxv,'Value',round(maxv/2));
sliceno = handles.slicenos(handles.displaymode);
set(handles.slicenoslider,'max',max(maxv,2),'Value',sliceno);
set(handles.maxtext,'String',num2str(maxv));
set(handles.slicenoinput,'String',num2str(sliceno));

guidata(handles.figure1,handles);
UpdateDisplay(handles);



% --- Executes during object creation, after setting all properties.
function viewpopupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viewpopupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slicenoslider_Callback(hObject, eventdata, handles)
% hObject    handle to slicenoslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

sliceno = round(get(hObject,'Value'));
handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoinput,'String',num2str(sliceno));
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function slicenoslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicenoslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%=====================================================
% Display function
%=====================================================
function UpdateDisplay(handles,export,interpolate)

if ~exist('export','var')
	export = 0;
end

if ~exist('interpolate','var')
	interpolate = 0;
end

if handles.interpolation == 0
	interpolate = 0;
end

% if handles.rgb_image == 1
% 	% Doesn't support interpolation for color image
% 	interpolate = 0;
% end

sliceno = round(get(handles.slicenoslider,'Value'));
dim = handles.dim;
sliceno = max(sliceno,1);

if export ~= 1
	if interpolate == 1
		%set(0,'CurrentFigure',handles.figure1);
		figure(handles.figure1);
	end
	set(handles.figure1,'CurrentAxes',handles.mainaxes);
	axes(handles.mainaxes);
	HA = handles.mainaxes;
else
	figure;
	HA = gca;
end

windowcenter = str2num(get(handles.windowcenterinput,'String'));
windowwidth = str2num(get(handles.windowwidthinput,'String'));

% minv = max((windowcenter - windowwidth/2),handles.min);
% maxv = min((windowcenter + windowwidth/2),handles.max);
minv = (windowcenter - windowwidth/2);
maxv = (windowcenter + windowwidth/2);

if maxv<= minv
	minv = handles.min;
	maxv = handles.max;
end


if( handles.displaymode < 4 & sliceno > dim(handles.displaymode) )
	sliceno = round(dim(handles.displaymode)/2);
	set(handles.slicenoslider,'Value',sliceno);
end

if Check_MenuItem(handles.Options_Show_In_Color_Menu_Item,0) == 0
	map = gray(64);
else
	map = jet(64);
end

show_contour = Check_MenuItem(handles.Options_Show_Contours_Menu_Item,0);
if isempty(handles.mask)
	show_contour = 0;
end

%hold off;

oldfcn = get(handles.mainaxes,'buttonDownFcn');
H = [];

if interpolate == 1
	%drawnow;
	ratios = get(handles.mainaxes,'DataAspectRatio');
	[img2d,xs,ys] = GetInterpolated2DImage(handles,sliceno);
	%H=imagesc(xs,ys,img2d,[minv maxv]);
	if handles.rgb_image == 0
		if export == 1
			H = imagesc(xs,ys,img2d,[minv maxv]);colormap gray;
			daspect(ratios);
		else
			H = image(xs,ys,img2d,'Parent',handles.mainaxes,'CDataMapping','scaled');
			set(handles.mainaxes,'CLim',[minv maxv]);
			daspect(handles.mainaxes,ratios);
		end
	else
		if export == 1
			H = image(xs,ys,img2d);
			daspect(ratios);
		else
			H = image(xs,ys,img2d,'Parent',handles.mainaxes);
% 			set(handles.mainaxes,'CLim',[minv maxv]);
			daspect(handles.mainaxes,ratios);
		end
	end
% 	SetZoomArea(handles,handles.mainaxes);
end

switch handles.displaymode
	case 1	% Coronal
		if interpolate == 0
			if handles.rgb_image == 0
				img = reshape(handles.image(sliceno,:,:),dim(2),dim(3));
				img = img';
				H = image(img,'Parent',HA,'CDataMapping','scaled');
			else
				img = reshape(handles.image(sliceno,:,:,:),[dim(2),3,dim(3)]);
				img = permute(img,[3 1 2]);

				if handles.max <= 1 
					H = image(img,'Parent',HA);
				elseif handles.max <= 255
					H = image(uint8(img),'Parent',HA);
				else
					H = image(img/handles.max,'Parent',HA);
				end
			end
			SetZoomArea(handles,HA,[handles.aspects(1) handles.aspects(3)]);
		end
		
		if show_contour
			strnums = DrawContours(handles,sliceno,HA);
		end
		daspect(HA,[1/handles.aspects(1) 1/handles.aspects(3) 1]);
		aspect2d = [handles.aspects(1) handles.aspects(3)];
		
		if handles.flipX == 1
			set(gca,'XDir','reverse');
		else
			set(gca,'XDir','normal');
		end
		if handles.flipZ == 1
			set(gca,'YDir','reverse');
		else
			set(gca,'YDir','normal');
		end

%    		set(HA,'NextPlot','Add');
% 		for k=2:dim(3)/16
% 			HL = line([0.5 dim(2)+0.5],0.5+[(k-1)*16 (k-1)*16]);
% 			set(HL,'color',[0.5 0.5 0.5],'LineStyle','--','LineWidth',3,'hittest','off');
% 		end
%    		set(HA,'NextPlot','Replace');
% 		
% 		
	case 2	% Sagittal
		if interpolate == 0
			if handles.rgb_image == 0
				img = reshape(handles.image(:,sliceno,:),dim(1),dim(3));
				img = img';
				H = image(img,'Parent',HA,'CDataMapping','scaled');
			else
				img = reshape(handles.image(:,sliceno,:,:),[dim(1),3,dim(3)]);
				img = permute(img,[3 1 2]);
				if handles.max <= 1 
					H = image(img,'Parent',HA);
				elseif handles.max <= 255
					H = image(uint8(img),'Parent',HA);
				else
					H = image(img/handles.max,'Parent',HA);
				end
			end
			SetZoomArea(handles,HA,[handles.aspects(2) handles.aspects(3)]);
		end

		if show_contour
			strnums = DrawContours(handles,sliceno,HA);
		end
		
		daspect(HA,[1/handles.aspects(2) 1/handles.aspects(3) 1]);
		aspect2d = [handles.aspects(2) handles.aspects(3)];
		
		if handles.flipY == 1
			set(gca,'XDir','reverse');
		else
			set(gca,'XDir','normal');
		end
		if handles.flipZ == 1
			set(gca,'YDir','reverse');
		else
			set(gca,'YDir','normal');
		end
		
	case 3	% Transverse
		if interpolate == 0
			if handles.rgb_image == 0
				img = reshape(handles.image(:,:,sliceno),dim(1),dim(2));
				H = image(img,'Parent',HA,'CDataMapping','scaled');
			else
				img = reshape(handles.image(:,:,:,sliceno),[dim(1),dim(2),3]);
				if handles.max <= 1 
					H = image(img,'Parent',HA);
				elseif handles.max <= 255
					H = image(uint8(img),'Parent',HA);
				else
					H = image(img/handles.max,'Parent',HA);
				end
			end
			SetZoomArea(handles,HA,[handles.aspects(1) handles.aspects(2)]);
		end

		if show_contour
			strnums = DrawContours(handles,sliceno,HA);
		end
		
		daspect(HA,[1/handles.aspects(1) 1/handles.aspects(2) 1]);
		aspect2d = [handles.aspects(1) handles.aspects(2)];

		if handles.flipX == 1
			set(gca,'XDir','reverse');
		else
			set(gca,'XDir','normal');
		end
		if handles.flipY == 1
			set(gca,'YDir','reverse');
		else
			set(gca,'YDir','normal');
		end
		
	case 4	% 3D isosurface
		view3d(handles.image,sliceno/256);
		daspect(HA,[1/handles.aspects(1) 1/handles.aspects(2) 1/handles.aspects(3)]);
end


if show_contour && ~isempty(strnums)
	if ~isempty(handles.structure_names)
		legend(HA,handles.structure_names(strnums));
	else
% 		legend(HA,'Prostate 1','Rectum 1','Bladder 1','Prostate 2','Rectum 2','Bladder 2','Prostate 3','Rectum 3','Bladder 3');
		% legend(HA,'Prostate 1','Bladder 1','Prostate 2','Bladder 2','Prostate 3','Bladder 3');
		% legend(HA,'Prostate','Rectum','Bladder');
		% legend(HA,'Prostate','Bladder');
	end
end

if export ~= 1
	set(handles.figure1,'colormap',map);
else
	colormap(map);
end

if minv ~= maxv
	set(HA,'CLim',[minv maxv]);
end

if interpolate == 0
	if handles.interpolation == 1 && handles.displaymode < 4
		if ~isfield(handles,'timer')
			handles.timer = timer('TimerFcn',@view3dgui,'StartDelay',1,'Period',15,'ExecutionMode','singleShot','UserData',handles.figure1,'Tag','View3dgui_timer');
			guidata(handles.figure1,handles);
		end
	
		stop(handles.timer);
		start(handles.timer);
	end
end


if ishandle(H) && export == 0
% 	if Check_MenuItem(handles.Options_Show_Pixel_Info_Menu_Item,0) == 1
	if handles.display_pixel_info == 1
		impixelinfo(H);
	end
	set(H,'hittest','off');
end

% Draw land marks
draw_land_marks = Check_MenuItem(handles.Options_Show_Land_Mark_Menu_Item,0);
if draw_land_marks == 1 && ~isempty(handles.landmarks)
	points = handles.landmarks(:,2:4);
	for k = 1:size(points,1)
		switch handles.displaymode
			case 1	% coronal
				if abs(sliceno-points(k,1)) <= 0.5
					drawcross(handles,points(k,2),points(k,3),handles.landmarks(k,1),aspect2d);
				end
			case 2	% sagittal
				if abs(sliceno-points(k,2)) <= 0.5
					drawcross(handles,points(k,1),points(k,3),handles.landmarks(k,1),aspect2d);
				end
			case 3	% transverse
				if abs(sliceno-points(k,3)) <= 0.5
					drawcross(handles,points(k,2),points(k,1),handles.landmarks(k,1),aspect2d);
				end
		end
	end
end

if draw_land_marks == 1 && ~isempty(handles.reference_landmarks)
	points = handles.reference_landmarks(:,2:4);
	for k = 1:size(points,1)
		switch handles.displaymode
			case 1	% coronal
				if abs(sliceno-points(k,1)) <= 1.5
					drawblock(handles,points(k,2),points(k,3),handles.reference_landmarks(k,1),aspect2d);
				end
			case 2	% sagittal
				if abs(sliceno-points(k,2)) <= 1.5
					drawblock(handles,points(k,1),points(k,3),handles.reference_landmarks(k,1),aspect2d);
				end
			case 3	% transverse
				if abs(sliceno-points(k,3)) <= 1.5
					drawblock(handles,points(k,2),points(k,1),handles.reference_landmarks(k,1),aspect2d);
				end
		end
	end
end

% Display motion field
display_motion_field = Check_MenuItem(handles.Options_Show_DVF_Menu_Item,0);
if isempty(handles.mvx)
	display_motion_field = 0;
end
if display_motion_field == 1
	dim = mysize(handles.mvx);
	gridsize0 = handles.motion_grid_size;
	gridsize0 = [8 8 4];
	if length(gridsize0) == 1
		gridsize0 = gridsize0*ones(dim);
	elseif length(gridsize0) > length(dim)
		gridsize0 = gridsize0(1:length(dim));
	elseif length(gridsize0) < length(dim)
		gridsize0 = [gridsize0 gridsize0(end)];
	end

	gridsize = round(min(gridsize0,dim/2));
	if ~isequal(gridsize0,gridsize)
		handles.motion_grid_size = gridsize;
		guidata(handles.figure1,handles);
	end

	s = round(gridsize/2);

	y0 = s(1):gridsize(1):dim(1);
	x0 = s(2):gridsize(2):dim(2);
	z0 = s(3):gridsize(3):dim(3);

	y02 = y0;
	x02 = x0;
	z02 = z0;

	switch handles.displaymode
		case 1
			mv2 = squeeze(handles.mvz(sliceno,x0,z0));
			mv1 = squeeze(handles.mvx(sliceno,x0,z0));
			mv2 = mv2';
			mv1 = mv1';
			[vv1,vv2] = meshgrid(x02,z02);
		case 2
			mv2 = squeeze(handles.mvz(y0,sliceno,z0));
			mv1 = squeeze(handles.mvy(y0,sliceno,z0));
			mv2 = mv2';
			mv1 = mv1';
			[vv1,vv2] = meshgrid(y02,z02);
		case 3
			mv1 = squeeze(handles.mvx(y0,x0,sliceno));
			mv2 = squeeze(handles.mvy(y0,x0,sliceno));
			[vv1,vv2] = meshgrid(x02,y02);
	end

	hold on;
	linew = 3;
% 	linew = 1;
	motionvectorcolor = 'y';

% 	if motion_field_selection <= 4
		% display the motion field
		idxes = ~isnan(mv1) & ~isnan(mv2);
		vv1=vv1(idxes);
		vv2=vv2(idxes);
		mv1=mv1(idxes);
		mv2=mv2(idxes);

		mh = quiver(vv1-mv1,vv2-mv2,mv1,mv2,0,'Color',motionvectorcolor,'LineWidth',linew);
		set(mh,'hittest','off');
% 	elseif motion_field_selection == 7
% 		% display the deformation grid
% 		[MY,MX]=size(mv1);
% 		for M = 1:MY
% 			X = vv1(M,:)-mv1(M,:);
% 			Y = vv2(M,:)-mv2(M,:);
% 			L=line(X,Y);
% 			%set(L,'Color',motionvectorcolor,'Marker','*','LineStyle','-');
% 			set(L,'Color',motionvectorcolor);
% 			set(L,'hittest','off');
% 		end
% 
% 		for M=1:MX
% 			X = vv1(:,M)-mv1(:,M);
% 			Y = vv2(:,M)-mv2(:,M);
% 			L=line(X,Y);
% 			set(L,'Color',motionvectorcolor);
% 			set(L,'hittest','off');
% 		end
% 	end
end

if export == 1
	axis off;
end
if export == 2 && handles.displaymode >= 1 && handles.displaymode <= 3
	% Save image into an image file
	maxv = max(handles.image(:));
	filename = write_image(img,'Save image into a file');
	if filename ~= 0
		disp(['Image is saved into ' filename]);
	end
end

if export ~= 1
	if Check_MenuItem(handles.Options_Show_Colorbar_Menu_Item,0) == 0
		colorbar('off','peer',handles.mainaxes);
	else
		%H=colorbar('East');
		HB=colorbar('EastOutside','peer',handles.mainaxes);
		%set(H,'Y	Color','white');
		set(HB,'FontSize',30);
	end
else
	if Check_MenuItem(handles.Options_Show_Colorbar_Menu_Item,0) == 0
		colorbar('off');
	else
		HB=colorbar('EastOutside');
		set(HB,'FontSize',30,'LineWidth',3);
	end
end



children = get(handles.mainaxes,'Children');
for k = 1:length(children)
	set(children(k),'hittest','off');
end
set(handles.mainaxes,'buttonDownFcn',oldfcn);
set(HA,'box', 'off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[]);
%daspect([1 1 1]);

%axis off;
return;
%
% --------------------------------------------
function strnums = DrawContours(handles,sliceno,HA)
%
dim = handles.dim;
linecolormap = lines(64);
linetypes = {'-','-.','--'};
% linetype = ':';
% linewidth = 5;
linewidth = 1;

strnums = [];

if iscell(handles.mask)
	set(HA,'NextPlot','Add');
	for k = 1:length(handles.mask)
		mask = handles.mask{k};
		switch handles.displaymode
			case 1
				mask = reshape(mask(sliceno,:,:),dim(2),dim(3))';
			case 2
				mask = reshape(mask(:,sliceno,:),dim(1),dim(3))';

			case 3
				mask = reshape(mask(:,:,sliceno),dim(1),dim(2));
		end
		
		if max(mask(:)) > 0
			strnums = [strnums k];
			cs = contourd(double(mask),[1 1]);
			plot_contourd(HA,cs,'LineStyle',linetypes{mod(k-1,3)+1},'Color',linecolormap(k,:),'LineWidth',linewidth);
			% 						plot_contourd(HA,cs,'LineStyle',linetypes{mod(k-1,3)+1},'Color',linecolormap(ceil(k/3),:),'LineWidth',linewidth);
			% 		    			contour(HA,maskbit,[1 1],linetype,'Color',linecolormap(k,:),'LineWidth',linewidth);
		end
	end
	set(HA,'NextPlot','Replace');
else
	switch handles.displaymode
		case 1	% coronal
			mask = reshape(handles.mask(sliceno,:,:),dim(2),dim(3))';
		case 2	% sagittal
			mask = reshape(handles.mask(:,sliceno,:),dim(1),dim(3))';
		case 3	% transverse
			mask = reshape(handles.mask(:,:,sliceno),dim(1),dim(2));
	end
	strnums = DrawContourFunction1(HA,mask,linecolormap,linetypes,linewidth);
end
return;

% --------------------------------------------
function strnums = DrawContourFunction1(HA,mask,linecolormap,linetypes,linewidth)
strnums = [];
if max(mask(:)) > 0
	set(HA,'NextPlot','Add');
	NC = floor(log2(double(max(mask(:)))))+1;
	for k = 1:NC
		maskbit = bitget(uint32(mask),k);
		if max(maskbit(:)) > 0
			strnums = [strnums k];
			cs = contourd(double(maskbit),[1 1]);
			plot_contourd(HA,cs,'LineStyle',linetypes{mod(k-1,3)+1},'Color',linecolormap(k,:),'LineWidth',linewidth);
			% 						plot_contourd(HA,cs,'LineStyle',linetypes{mod(k-1,3)+1},'Color',linecolormap(ceil(k/3),:),'LineWidth',linewidth);
			% 		    			contour(HA,maskbit,[1 1],linetype,'Color',linecolormap(k,:),'LineWidth',linewidth);
		end
	end
	set(HA,'NextPlot','Replace');
end
return;

% --------------------------------------------
function SetZoomArea(handles,haxis,ratios)
xlims = get(haxis,'XLim');
ylims = get(haxis,'YLim');

xlims0 = xlims;
ylims0 = ylims;

posf = get(handles.figure1,'Position');
posa = get(haxis,'Position');
posap = normalized2pixel(posa,handles.figure1);	% The maximal axis size in the figure
maxw = posap(3);
maxh = posap(4);

xrange = (xlims(2)-xlims(1))/handles.zoom_factors(handles.displaymode);
yrange = (ylims(2)-ylims(1))/handles.zoom_factors(handles.displaymode);

w = xrange*ratios(1);
h = yrange*ratios(2);

r = min(maxw/w,maxh/h);

width = w*r;	% The width and height that the image will be displayed
height = h*r;

% if maxw/w > maxh/h
if maxw > width
	% There are more room on L-R, so we can extend the xrange
	xrange = xrange*maxw/width;
else
	% There are more room on Up-Down, so we can extend the yrange
	yrange = yrange*maxh/height;
end

xlims = handles.zoom_centers(handles.displaymode,1) + [-xrange/2 xrange/2];
ylims = handles.zoom_centers(handles.displaymode,2) + [-yrange/2 yrange/2];
xlims = max(xlims,min(xlims0)); xlims = min(xlims,max(xlims0));
ylims = max(ylims,min(ylims0)); ylims = min(ylims,max(ylims0));
set(haxis,'xlim',xlims);
set(haxis,'ylim',ylims);

return;
	
function [img2d,xs,ys]=GetInterpolated2DImage(handles,sliceno)
dim = handles.dim;
if handles.rgb_image == 0
	switch handles.displaymode
		case 1	% Coronal
			img = reshape(handles.image(sliceno,:,:),dim(2),dim(3));
			img = img';
			x0 = 1:dim(2); xr = handles.aspects(2);
			y0 = 1:dim(3); yr = handles.aspects(3);
		case 2	% Sagittal
			img = reshape(handles.image(:,sliceno,:),dim(1),dim(3));
			img = img';
			x0 = 1:dim(1); xr = handles.aspects(1);
			y0 = 1:dim(3); yr = handles.aspects(3);
		case 3	% Transverse
			img = reshape(handles.image(:,:,sliceno),dim(1),dim(2));
			x0 = 1:dim(2); xr = handles.aspects(1);
			y0 = 1:dim(1); yr = handles.aspects(1);
	end
else
	switch handles.displaymode
		case 1	% Coronal
			img = squeeze(handles.image(sliceno,:,:,:));
			img = permute(img,[3 1 2]);
			x0 = 1:dim(2); xr = handles.aspects(2);
			y0 = 1:dim(3); yr = handles.aspects(3);
		case 2	% Sagittal
			img = squeeze(handles.image(:,sliceno,:,:));
			img = permute(img,[3 1 2]);
			x0 = 1:dim(1); xr = handles.aspects(1);
			y0 = 1:dim(3); yr = handles.aspects(3);
		case 3	% Transverse
			img = squeeze(handles.image(:,:,:,sliceno));
			x0 = 1:dim(2); xr = handles.aspects(1);
			y0 = 1:dim(1); yr = handles.aspects(1);
	end
end
posa = get(handles.mainaxes,'Position');
ratios = get(handles.mainaxes,'DataAspectRatio');
xlims = get(handles.mainaxes,'XLim');
ylims = get(handles.mainaxes,'YLim');

posa = normalized2pixel(posa,handles.figure1);
width = posa(3);
height = posa(4);

w = (xlims(end)-xlims(1))/ratios(1);
h = (ylims(end)-ylims(1))/ratios(2);

r = min(width/w,height/h);

width = w*r;
height = h*r;

% dx = (x0(end)-x0(1))/width;
% dy = (y0(end)-y0(1))/height;
% xs = x0(1):dx:x0(end);
% ys = y0(1):dy:y0(end);

dx = (xlims(end)-xlims(1))/width;
dy = (ylims(end)-ylims(1))/height;
xs = xlims(1):dx:xlims(end);
ys = ylims(1):dy:ylims(end);

[xx,yy]=meshgrid(xs,ys);
%img2d = interp2(img,xx,yy,'linear');
%img2d = interp2(img,xx,yy,'cubic');
if handles.rgb_image == 0
	try
		img2d = interp2(single(img),xx,yy,'spline');
	catch
		try
			img2d = interp2(single(img),xx,yy,'cubic');
		catch
			try
				img2d = interp2(single(img),xx,yy,'linear');
			catch
			end
		end
	end
else
	for k = 1:3
		try
			img2d(:,:,k) = interp2(single(img(:,:,k)),xx,yy,'spline');
		catch
			try
				img2d(:,:,k) = interp2(single(img(:,:,k)),xx,yy,'cubic');
			catch
				try
					img2d(:,:,k) = interp2(single(img(:,:,k)),xx,yy,'linear');
				catch
				end
			end
		end
	end
	img2d = max(img2d,0);
	img2d = min(img2d,1);
end
img2d = cast(img2d,class(img));

return;



function slicenoinput_Callback(hObject, eventdata, handles)
% hObject    handle to slicenoinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slicenoinput as text
%        str2double(get(hObject,'String')) returns contents of slicenoinput as a double

sliceno = str2num(get(hObject,'String'));
handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoslider,'Value',sliceno);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function slicenoinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicenoinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function windowcenterslider_Callback(hObject, eventdata, handles)
% hObject    handle to windowcenterslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function windowcenterslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowcenterslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function windowcenterinput_Callback(hObject, eventdata, handles)
% hObject    handle to windowcenterinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowcenterinput as text
%        str2double(get(hObject,'String')) returns contents of windowcenterinput as a double

UpdateDisplay(handles);
return;


% --- Executes during object creation, after setting all properties.
function windowcenterinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowcenterinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function windowwidthslider_Callback(hObject, eventdata, handles)
% hObject    handle to windowwidthslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function windowwidthslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowwidthslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function windowwidthinput_Callback(hObject, eventdata, handles)
% hObject    handle to windowwidthinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of windowwidthinput as text
%        str2double(get(hObject,'String')) returns contents of windowwidthinput as a double
UpdateDisplay(handles);
return;


% --- Executes during object creation, after setting all properties.
function windowwidthinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowwidthinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%----------------------------------------------------
function handles = init_window_controls(handles)
	img = handles.image;
	minv = min(img(:));
	maxv = max(img(:));
	
	handles.windowcenter = ((maxv+minv)/2);
	handles.windowcenter = round(handles.windowcenter*10)/10;
	handles.windowwidth = (maxv-minv);
	handles.windowwidth = round(handles.windowwidth*10)/10;
	
	set(handles.windowcenterinput,'string',sprintf('%.1f',handles.windowcenter));
	set(handles.windowwidthinput,'string',sprintf('%.1f',handles.windowwidth));
	
return;


% --- Executes on button press in modifybutton.
function modifybutton_Callback(hObject, eventdata, handles)
% hObject    handle to modifybutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(hObject,'Value') == 1
	r=7;
	ps = zeros(16)*NaN;
	for i=1:2*r+1
		for j=1:2*r+1
			if( round(sqrt((i-r-1)^2+(j-r-1)^2)) == r )
				ps(i,j)=2;
			end
		end
	end
	
	ps(5:11,8)=1;ps(8,5:11)=1;
	
	set(handles.figure1,'Pointer','custom','PointerShapeCData',ps,'PointerShapeHotSpot',[r+1 r+1]);
	set(handles.mainaxes, 'hittest', 'on');
	set(handles.mainaxes, 'buttonDownFcn', 'view3dgui(''mainaxes_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
	children = get(handles.mainaxes,'Children');
	for k = 1:length(children)
		set(children(k),'hittest','off');
	end
else
	set(handles.mainaxes, 'hittest', 'off');
	set(handles.mainaxes, 'buttonDownFcn', '');
	set(handles.figure1,'Pointer','arrow');
end


% --- Executes on button press in savepushbutton.
function savepushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to savepushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

modified_mask = handles.mask;
save modified_mask.mat modified_mask;
disp('Modified mask has been saved');
set(handles.savepushbutton,'Enable','off');

return;


function mainaxes_WindowButtonUpFcn_Callback(hObject, eventdata, handles)
set(handles.figure1, 'WindowButtonUpFcn', handles.WindowButtonUpFcn_save);
set(handles.figure1, 'WindowButtonMotionFcn', handles.WindowButtonMotionFcn_save);
handles = Handle_MouseMotion(handles);
handles = Finish_Mouse_Motion(handles);
guidata(handles.figure1,handles);
set(handles.viewpopupmenu,'Enable','on');

return;

function mainaxes_WindowButtonMotionFcn_Callback(hObject, eventdata, handles)
handles = Handle_MouseMotion(handles);
guidata(handles.figure1,handles);
return;


% --- Executes on mouse press over axes background.
function mainaxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mainaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.viewpopupmenu,'Enable','off');

handles.WindowButtonUpFcn_save = get(handles.figure1,'WindowButtonUpFcn');
handles.WindowButtonMotionFcn_save = get(handles.figure1,'WindowButtonMotionFcn');

handles.mouse_points=[];
handles = Handle_MouseMotion(handles);

sliceno = round(get(handles.slicenoslider,'Value'));
if ~isempty(handles.mouse_points)
	x = handles.mouse_points(1,1);
	y = handles.mouse_points(1,2);
	switch handles.displaymode
		case 1	% Coronal
			handles.mouse_val = handles.mask(sliceno,x,y);
		case 2	% Sagittal
			handles.mouse_val = handles.mask(x,sliceno,y);
		case 3	% Transverse
			handles.mouse_val = handles.mask(y,x,sliceno);
	end
else
	handles.mouse_val = handles.mask(1,1,1);
end

%disp(sprintf('(%d,%d) = %d',x,y,handles.mouse_val));

guidata(handles.figure1,handles);

set(handles.figure1, 'WindowButtonUpFcn', 'view3dgui(''mainaxes_WindowButtonUpFcn_Callback'',gcbo,[],guidata(gcbo))');
set(handles.figure1, 'WindowButtonMotionFcn', 'view3dgui(''mainaxes_WindowButtonMotionFcn_Callback'',gcbo,[],guidata(gcbo))');

return;


function handles = Handle_MouseMotion(handles)
dim = handles.dim;
cP = round(get(handles.mainaxes, 'currentPoint'));
x = cP(1,1); if x < 1 return; end
y = cP(1,2); if y < 1 return; end

check_x = [ 2 1 2 ];
check_y = [ 3 3 1 ];
if( x > dim(check_x(handles.displaymode)) )	return; end
if( y > dim(check_y(handles.displaymode)) )  return; end

if( isfield(handles,'mouse_points') & ~isempty(handles.mouse_points) )
	x1 = handles.mouse_points(end,1);
	y1 = handles.mouse_points(end,2);
% 	if( sqrt((x1-x)^2+(y1-y)^2) >= 1 )
		handles.mouse_points(end+1,:) = [x y];
% 	else
% 		return;
% 	end
else
	handles.mouse_points(1,:) = [x y];
end


r = str2num(get(handles.radiusinput,'String'));
r = round(r); r = max(r,2);
theta = 0:10:360;
xp = cos(theta/360*2*pi)*r+x;
yp = sin(theta/360*2*pi)*r+y;
set(handles.figure1,'CurrentAxes',handles.mainaxes);
hold on;
HL = line(xp,yp);
hold off;
set(HL,'hittest','off');
set(HL,'Color','red');
return;


function handles = Finish_Mouse_Motion(handles)
if( ~isfield(handles,'mouse_points') ) return; end
points = handles.mouse_points;
if (size(points,1) == 0) return; end

r = str2num(get(handles.radiusinput,'String'));
r = round(r); r = max(r,2);

edit3d = get(handles.edit3dcheckbox,'Value');

dim = handles.dim;
sliceno = round(get(handles.slicenoslider,'Value'));

for p = 1:size(points,1)
	switch handles.displaymode
		case 1	% coronal
			y0 = sliceno;
			x0 = points(p,1);
			z0 = points(p,2);
			
			ys = y0 + [-r:r]*edit3d;
			xs = x0 + [-r:r];
			zs = z0 + [-r:r];
		case 2	% Sagittal
			y0 = points(p,1);
			x0 = sliceno;
			z0 = points(p,2);
			
			ys = y0 + [-r:r];
			xs = x0 + [-r:r]*edit3d;
			zs = z0 + [-r:r];
		case 3	% tranverse
			y0 = points(p,2);
			x0 = points(p,1);
			z0 = sliceno;
			
			ys = y0 + [-r:r];
			xs = x0 + [-r:r];
			zs = z0 + [-r:r]*edit3d;
	end

	ys = max(ys,1); ys = min(ys,dim(1)); ys = unique(ys);
	xs = max(xs,1); xs = min(xs,dim(2)); xs = unique(xs);
	zs = max(zs,1); zs = min(zs,dim(3)); zs = unique(zs);

	for k = 1:length(ys)
		for m = 1:length(xs)
			for n = 1:length(zs)
				if( sqrt((xs(m)-x0).^2+(ys(k)-y0).^2 + (zs(n)-z0).^2) <= r )
					handles.mask(ys(k),xs(m),zs(n)) = handles.mouse_val;
				end
			end
		end
	end
end

handles.mouse_points=[];
guidata(handles.figure1,handles);
UpdateDisplay(handles);
set(handles.savepushbutton,'Enable','on');

return;




function radiusinput_Callback(hObject, eventdata, handles)
% hObject    handle to radiusinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radiusinput as text
%        str2double(get(hObject,'String')) returns contents of radiusinput as a double


% --- Executes during object creation, after setting all properties.
function radiusinput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiusinput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in edit3dcheckbox.
function edit3dcheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to edit3dcheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of edit3dcheckbox



% --- Executes on button press in export_image_pushbutton.
function export_image_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to export_image_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateDisplay(handles,2);
return;



% --- Executes on button press in figurewindowpushbutton.
function figurewindowpushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to figurewindowpushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

UpdateDisplay(handles,1);
return;


% --------------------------------------------------------------------
function Context_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Context_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Display_Options_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Display_Options_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Content_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Content_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if( ~isempty(handles.mask) )
	set(handles.Options_Show_Contours_Menu_Item,'Enable','on');
else
	set(handles.Options_Show_Contours_Menu_Item,'Enable','off');
end

if handles.interpolation == 1
	set(handles.Options_Interpolation_Menu_Item,'checked','on');
else
	set(handles.Options_Interpolation_Menu_Item,'checked','off');
end

if ~isempty(handles.mvx)
	set(handles.Options_Show_DVF_Menu_Item,'Enable','on');
else
	set(handles.Options_Show_DVF_Menu_Item,'Enable','off');
end

% --------------------------------------------------------------------
function Options_Show_Colorbar_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_Colorbar_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
UpdateDisplay(handles);

% --------------------------------------------------------------------
function Options_Show_In_Color_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_In_Color_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function Options_Show_Contours_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_Contours_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function Options_Interpolation_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Interpolation_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.interpolation = Check_MenuItem(hObject,1);
guidata(handles.figure1,handles);
UpdateDisplay(handles);
return;

% --------------------------------------------------------------------
function Options_Show_Land_Mark_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_Land_Mark_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function Land_Mark_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Land_Mark_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.landmarks)
	set(handles.Save_Land_Mark_Data_Menu_Item,'Enable','off');
	set(handles.Delete_Land_Mark_Menu_Item,'Enable','off');
	set(handles.Reassign_Landmark_ID_Menu_Item,'Enable','off');
	set(handles.Find_Landmark_ID_Menu_Item,'Enable','off');
else
	if isempty(FindLandMarkByPoint(handles))
		set(handles.Delete_Land_Mark_Menu_Item,'Enable','off');
		set(handles.Reassign_Landmark_ID_Menu_Item,'Enable','off');
	else
		set(handles.Delete_Land_Mark_Menu_Item,'Enable','on');
		set(handles.Reassign_Landmark_ID_Menu_Item,'Enable','on');
	end
	set(handles.Save_Land_Mark_Data_Menu_Item,'Enable','on');
	set(handles.Find_Landmark_ID_Menu_Item,'Enable','on');
end

return;

% --------------------------------------------------------------------
function idx = FindLandMarkByPoint(handles,p)
if ~exist('p','var')
	p = get(gca,'CurrentPoint');
end

sliceno = round(get(handles.slicenoslider,'Value'));

switch handles.displaymode
	case 1	% coronal
		x = p(1); y = sliceno; z = p(3);
	case 2	% sagittal
		x = sliceno; y = p(1); z = p(3);
	case 3	% transverse
		x = p(1); y = p(3); z = sliceno;
end

len = size(handles.landmarks,1);
for idx = 1:len
	dx = x-handles.landmarks(idx,3);
	dy = y-handles.landmarks(idx,2);
	dz = z-handles.landmarks(idx,4);
	if sqrt(dx*dx+dy*dy+dz*dz) < 2
		return;
	end
end
idx = [];
return;

% --------------------------------------------------------------------
function Add_Land_Mark_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Land_Mark_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(gca,'CurrentPoint');
sliceno = round(get(handles.slicenoslider,'Value'));

if ~isfield(handles,'landmarks') || isempty(handles.landmarks)
	num = 1;
else
	num = max(handles.landmarks(:,1))+1;
end
switch handles.displaymode
	case 1	% coronal
		handles.landmarks = [handles.landmarks; num sliceno p(1) p(3)];
	case 2	% sagittal
		handles.landmarks = [handles.landmarks; num p(1) sliceno p(3)];
	case 3	% transverse
		handles.landmarks = [handles.landmarks; num p(3) p(1) sliceno];
end


guidata(handles.figure1,handles);
UpdateDisplay(handles,0,1);
return;


% --------------------------------------------------------------------
function Add_Land_Mark_At_Number_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Land_Mark_At_Number_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p = get(gca,'CurrentPoint');
sliceno = round(get(handles.slicenoslider,'Value'));

switch handles.displaymode
	case 1	% coronal
		yxz = [sliceno p(1) p(3)];
	case 2	% sagittal
		yxz = [p(1) sliceno p(3)];
	case 3	% transverse
		yxz = [p(3) p(1) sliceno];
end

if ~isfield(handles,'landmarks') || isempty(handles.landmarks)
	curnum = 0;
else
	curnum = max(handles.landmarks(:,1));
end

dlgTitle='Add a landmark by ID number';
prompt={'Enter the landmark ID number:'};
def={num2str(curnum+1)};
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);

if( isempty(answer) )
	newnum = curnum_1;
else
	newnum = str2num(answer{1});
end

if ~isfield(handles,'landmarks') || isempty(handles.landmarks)
	existing_idx = [];
else
	existing_idx = find(handles.landmarks(:,1)==newnum,1,'first');
end

if isempty(existing_idx)
	handles.landmarks(end+1,:) = [newnum yxz];
else
	% warning here
	handles.landmarks(existing_idx,2:4) = yxz;
end

guidata(handles.figure1,handles);
UpdateDisplay(handles,0,1);

return;



% --------------------------------------------------------------------
function Reassign_Landmark_ID_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Reassign_Landmark_ID_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = FindLandMarkByPoint(handles);
if ~isempty(idx) && idx > 0 && idx <= size(handles.landmarks,1)
	dlgTitle='Reassign the landmark ID number';
	prompt={'Enter new landmark ID number:'};
	def={num2str(handles.landmarks(idx,1))};
	lineNo=1;
	answer=inputdlg(prompt,dlgTitle,lineNo,def);

	if( ~isempty(answer) )
		newnum = str2num(answer{1});
		if newnum ~= handles.landmarks(idx,1)
			existing_idx = find(handles.landmarks(:,1)==newnum,1,'first');
			if isempty(existing_idx)
				handles.landmarks(idx,1) = newnum;
			else
				% Overwrite the existing idx
				% warning the user here
				handles.landmarks(existing_idx,2:4) = handles.landmarks(idx,2:4);
				handles.landmarks = Delete_Land_Mark_At(handles.landmarks,idx);
			end
			guidata(handles.figure1,handles);
			UpdateDisplay(handles,0,1);
		end
	end
end

return;

	
% --------------------------------------------------------------------
function landmarks = Delete_Land_Mark_At(landmarks,idx)
	if idx == 1
		if size(landmarks,1) == 1
			landmarks = [];
		else
			landmarks = landmarks(2:end,:);
		end
	elseif idx == size(landmarks,1)
		landmarks = landmarks(1:end-1,:);
	else
		landmarks = landmarks([1:idx-1 idx+1:end],:);
	end
return;


% --------------------------------------------------------------------
function Find_Landmark_ID_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Find_Landmark_ID_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dlgTitle='Find a landmark by its ID number';
prompt={'Enter the landmark ID number:'};
def={'1'};
lineNo=1;
answer=inputdlg(prompt,dlgTitle,lineNo,def);

if( ~isempty(answer) )
	num = str2num(answer{1});
	
	idx = 0;
	for k = 1:size(handles.landmarks,1);
		if num == handles.landmarks(k,1)
			idx = k;
			break;
		end
	end
	
	if idx > 0
		% found
		switch handles.displaymode
			case 1	% coronal
				Goto_Slice_Number(handles,handles.landmarks(idx,2));
			case 2	% sagittal
				Goto_Slice_Number(handles,handles.landmarks(idx,3));
			case 3	% transverse
				Goto_Slice_Number(handles,handles.landmarks(idx,4));
		end
	else
		disp('Landmark not found');
	end
end

return;


function Goto_Slice_Number(handles,sliceno)
sliceno = round(sliceno);
handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoslider,'Value',sliceno);
set(handles.slicenoinput,'String',num2str(sliceno));
UpdateDisplay(handles);
return;

% --------------------------------------------------------------------
function List_Land_Marks_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to List_Land_Marks_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

N = size(handles.landmarks,1);
fprintf('Total %d landmarks: \n', N);
for k = 1:N
	fprintf('%d: %f, %f, %f\n',handles.landmarks(k,1),handles.landmarks(k,2),handles.landmarks(k,3),handles.landmarks(k,4));
end
fprintf('\n');

return;


% --------------------------------------------------------------------
function Delete_Land_Mark_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_Land_Mark_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx = FindLandMarkByPoint(handles);
if ~isempty(idx) && idx > 0 && idx <= size(handles.landmarks,1)
	handles.landmarks = Delete_Land_Mark_At(handles.landmarks,idx);
	guidata(handles.figure1,handles);
	UpdateDisplay(handles,0,1);
end
return;


% --------------------------------------------------------------------
function Save_Land_Mark_Data_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Land_Mark_Data_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile({'*.mat'}, 'Select a MATLAB file');
if filename == 0
	disp('Cancelled');
	return;
end
landmark_data = handles.landmarks;
save([pathname filename],'landmark_data');
fprintf('Land mark data has been saved into %s\n',filename);
return;

% --------------------------------------------------------------------
function Load_Land_Mark_Data_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Land_Mark_Data_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile({'*.mat'}, 'Select a MATLAB file');
if filename == 0
	disp('Cancelled');
	return;
end

load([pathname filename]);
handles.landmarks = landmark_data;
guidata(handles.figure1,handles);

return;



% --------------------------------------------------------------------
function Move_Land_Mark_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Move_Land_Mark_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles,'moveLandMark'))
    handles.moveLandMark = 0;
end

idx = FindLandMarkByPoint(handles);
if(~isempty(idx))
    handles.current_Landmark = idx;
    handles.moveLandMark = 1;
else
    fprintf('did not get the landmark\n');
end

[x y] = ginput(1);

p = get(gca,'CurrentPoint');
sliceno = round(get(handles.slicenoslider,'Value'));

switch handles.displaymode
    case 1	% coronal
        yxz = [sliceno p(1) p(3)];
    case 2	% sagittal
        yxz = [p(1) sliceno p(3)];
    case 3	% transverse
        yxz = [p(3) p(1) sliceno];
end

handles.landmarks(handles.current_Landmark,:) = [handles.current_Landmark yxz];

guidata(handles.figure1,handles);
UpdateDisplay(handles);

return



% --------------------------------------------------------------------
function Saggital_Land_Mark_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Saggital_Land_Mark_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.displaymode == 2)
    return;
end

idx = FindLandMarkByPoint(handles);
if(~isempty(idx))
    handles.current_Landmark = idx;
    handles.moveLandMark = 1;
else
    fprintf('did not get the landmark\n');
    return
end

p = handles.landmarks(idx,2:4);

handles.displaymode = 2;
ConfigureSlider(handles);

sliceno = round(p(2));
handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoslider,'Value',sliceno);

set(handles.viewpopupmenu,'Value',2)

handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoinput,'String',num2str(sliceno));
UpdateDisplay(handles);

return



% --------------------------------------------------------------------
function Coronoal_Land_Mark_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Coronoal_Land_Mark_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.displaymode == 1)
    return;
end

idx = FindLandMarkByPoint(handles);
if(~isempty(idx))
    handles.current_Landmark = idx;
    handles.moveLandMark = 1;
else
    fprintf('did not get the landmark\n');
    return
end

p = handles.landmarks(idx,2:4);
sliceno = round(p(1));

handles.displaymode = 1;
ConfigureSlider(handles);

handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoslider,'Value',sliceno);

set(handles.viewpopupmenu,'Value',2)

handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoinput,'String',num2str(sliceno));
UpdateDisplay(handles);

return


% --------------------------------------------------------------------
function Transverse_Land_Mark_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Transverse_Land_Mark_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(handles.displaymode == 3)
    return;
end

idx = FindLandMarkByPoint(handles);
if(~isempty(idx))
    handles.current_Landmark = idx;
    handles.moveLandMark = 1;
else
    fprintf('did not get the landmark\n');
    return
end

p = handles.landmarks(idx,2:4);

handles.displaymode = 3;
ConfigureSlider(handles);

sliceno = round(p(3));
handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoslider,'Value',sliceno);

set(handles.viewpopupmenu,'Value',handles.displaymode)

handles.slicenos(handles.displaymode) = sliceno;
guidata(handles.figure1,handles);
set(handles.slicenoinput,'String',num2str(sliceno));
UpdateDisplay(handles);

return


% --------------------------------------------------------------------
function Export_To_Figure_Window_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Export_To_Figure_Window_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateDisplay(handles,1,handles.interpolation);
return;



% --------------------------------------------------------------------
function Save_Into_File_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Into_File_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateDisplay(handles,2);
return;




% --------------------------------------------------------------------
function Options_Show_Pixel_Info_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_Pixel_Info_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.display_pixel_info = Check_MenuItem(hObject,1);
guidata(handles.figure1,handles);
UpdateDisplay(handles);
return;




% --------------------------------------------------------------------
function Window_Levels_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Levels_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Window_Level_Lung_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Lung_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.windowcenterinput,'String','450');
set(handles.windowwidthinput,'String','1000');
UpdateDisplay(handles);
return;

% --------------------------------------------------------------------
function Window_Level_Default_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Default_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if min(handles.image(:)) < 0
	maxv = max(abs(handles.image(:)));
	set(handles.windowcenterinput,'String','0');
	set(handles.windowwidthinput,'String',num2str(2*maxv));
else
	maxv = max(handles.image(:));
	set(handles.windowcenterinput,'String',num2str(maxv/2));
	set(handles.windowwidthinput,'String',num2str(maxv));
end	
UpdateDisplay(handles);
return;



% --------------------------------------------------------------------
function Window_Level_Abdominal_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_Abdominal_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maxv = max(handles.image(:));
set(handles.windowcenterinput,'String','40');
set(handles.windowwidthinput,'String','400');
UpdateDisplay(handles);
return;



% --------------------------------------------------------------------
function Window_Level_800_1600_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Window_Level_800_1600_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
maxv = max(handles.image(:));
set(handles.windowcenterinput,'String','800');
set(handles.windowwidthinput,'String','1600');
UpdateDisplay(handles);
return;


% --------------------------------------------------------------------
function drawcross(handles,x,y,num,aspect2d)
x = double(x);
y = double(y);

aspect = aspect2d(1)/aspect2d(2);

c = 'r';

x1=x-3;x2=x+3;y1=y-3*aspect;y2=y+3*aspect;
XX=[x1 x2];
YY=[y1 y2];
hl=line(XX,YY,'Color',c,'Parent',handles.mainaxes);
set(hl,'hittest','off');
XX=[x2 x1];
YY=[y1 y2];
hl=line(XX,YY,'Color',c,'Parent',handles.mainaxes);
set(hl,'hittest','off');
ht=text(round(x-2),round(y+6),num2str(num),'Parent',handles.mainaxes);
set(ht,'Color',c,'FontSize',10,'FontUnits','normalized');
set(ht,'hittest','off');
return;

function drawblock(handles,x,y,num,aspect2d)
x = double(x);
y = double(y);

aspect = aspect2d(1)/aspect2d(2);

c = 'y';

x1=x-4;x2=x+4;y1=y-4*aspect;y2=y+4*aspect;
XX=[x1 x2 x2 x1 x1];
YY=[y1 y1 y2 y2 y1];
hl=line(XX,YY,'Color',c,'Parent',handles.mainaxes);
set(hl,'hittest','off');
ht=text(round(x+5),round(y),num2str(num),'Parent',handles.mainaxes);
set(ht,'Color',c,'FontSize',10,'FontUnits','normalized');
set(ht,'hittest','off');
return;


% --------------------------------------------------------------------
function Timer_Callback_UpdateDisplay(timerobj, event)
handles = guidata(get(timerobj,'UserData'));
UpdateDisplay(handles,0,1);

return;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'timer')
	stop(handles.timer);
	delete(handles.timer);
end

return;


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

keyPressed = get(hObject, 'CurrentCharacter');
% keyValue = uint8(keyPressed);
keyname = get(hObject, 'currentKey');


switch upper(keyPressed)
	% options shortcut keys
	case 'C'	% show image in color
		Options_Show_In_Color_Menu_Item_Callback(handles.Options_Show_In_Color_Menu_Item,eventdata,handles);
	case 'S'	% contour
        
        Process_Stones_Callback(handles.Process_Stones_Callback, eventdata, handles);
        
    
        
        %Process_Stones_Callback(hObject, eventdata, handles)
        
		%Options_Show_Contours_Menu_Item_Callback(handles.Options_Show_Contours_Menu_Item,eventdata,handles);
        
	case 'B'	% colorbar
		Options_Show_Colorbar_Menu_Item_Callback(handles.Options_Show_Colorbar_Menu_Item,eventdata,handles);
	case 'I'	% interpolation
		Options_Interpolation_Menu_Item_Callback(handles.Options_Interpolation_Menu_Item,eventdata,handles);
	case 'P'	% show pixel info
		Options_Show_Pixel_Info_Menu_Item_Callback(handles.Options_Show_Pixel_Info_Menu_Item,eventdata,handles);
	case 'V'	% show DVF
		Options_Show_DVF_Menu_Item_Callback(handles.Options_Show_Pixel_Info_Menu_Item,eventdata,handles);
		
	% landmark shortcut keys
	case 'M'
		Options_Show_Land_Mark_Menu_Item_Callback(handles.Options_Show_Land_Mark_Menu_Item,eventdata,handles);
	case 'A'
		Add_Land_Mark_Menu_Item_Callback(handles.Add_Land_Mark_Menu_Item,eventdata,handles);
        
        %Process_Stones_Callback(handles.Process_Stones_Callback, eventdata, handles);
        
        
        
        
	case 'T'
		Add_Land_Mark_At_Number_Menu_Item_Callback(handles.Add_Land_Mark_At_Number_Menu_Item,eventdata,handles);
	case 'D'
		List_Land_Marks_Menu_Item_Callback(handles.List_Land_Marks_Menu_Item,eventdata,handles);
	case 'F'
		Find_Landmark_ID_Menu_Item_Callback(handles.Find_Landmark_ID_Menu_Item,eventdata,handles);
		
	% window level shortcut keys
	case 'L'
		Window_Level_Lung_Menu_Item_Callback(handles.Window_Level_Lung_Menu_Item,eventdata,handles);
	case 'R'
		Window_Level_Default_Menu_Item_Callback(handles.Window_Level_Default_Menu_Item,eventdata,handles);
	case 'O'
		Window_Level_Abdominal_Menu_Item_Callback(handles.Window_Level_Abdominal_Menu_Item,eventdata,handles);
	case '8'
		Window_Level_800_1600_Menu_Item_Callback(handles.Window_Level_Abdominal_Menu_Item,eventdata,handles);
		
	% Export
	case 'E'
		Export_To_Figure_Window_Menu_Item_Callback(handles.Export_To_Figure_Window_Menu_Item, eventdata, handles);
		
     
        
        
	% view direction
	case '1'	% coronal view
		set(handles.viewpopupmenu,'Value',1);
		viewpopupmenu_Callback(handles.viewpopupmenu, eventdata, handles);
	case '2'	% sagittal view
		set(handles.viewpopupmenu,'Value',2);
		viewpopupmenu_Callback(handles.viewpopupmenu, eventdata, handles);
	case '3'	% transverse view
		set(handles.viewpopupmenu,'Value',3);
		viewpopupmenu_Callback(handles.viewpopupmenu, eventdata, handles);
	case '+'	% zoom in
		Zoom_In_Menu_Item_Callback(handles.Zoom_In_Menu_Item,eventdata,handles);
	case '-'	% zoom out
		Zoom_Out_Menu_Item_Callback(handles.Zoom_Out_Menu_Item,eventdata,handles);
	case '*'	% zoom reset
		Zoom_Reset_Menu_Item_Callback(handles.Zoom_Reset_Menu_Item,eventdata,handles);
	otherwise
% 		disp(keyname)
		slicemax = get(handles.slicenoslider,'max');
		slicestep = min(max(1,round(slicemax/10)),10);
		switch lower(keyname)
			case 'pagedown'
				sliceno = get(handles.slicenoslider,'Value');
				sliceno = min(sliceno + slicestep,slicemax);
				set(handles.slicenoslider,'Value',sliceno);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
			case {'pageup'}
				sliceno = get(handles.slicenoslider,'Value');
				sliceno = max(sliceno - slicestep,1);
				set(handles.slicenoslider,'Value',sliceno);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
			case {'downarrow'}
				sliceno = get(handles.slicenoslider,'Value');
				sliceno = min(sliceno + 1,slicemax);
				set(handles.slicenoslider,'Value',sliceno);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
			case {'rightarrow'}
				if handles.is4d == 0
					sliceno = get(handles.slicenoslider,'Value');
					sliceno = min(sliceno + 1,slicemax);
					set(handles.slicenoslider,'Value',sliceno);
					slicenoslider_Callback(handles.slicenoslider, [], handles);
				else
					if handles.image4dnum < handles.NumImages
						handles.image4dnum = handles.image4dnum + 1;
						handles.image = handles.image4d(:,:,:,handles.image4dnum);
						guidata(handles.figure1,handles);
						UpdateDisplay(handles);
						set(gcbf,'Name',sprintf('View3D - Image #%d',handles.image4dnum));
					end
				end
			case {'uparrow'}
				sliceno = get(handles.slicenoslider,'Value');
				sliceno = max(sliceno - 1,1);
				set(handles.slicenoslider,'Value',sliceno);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
			case {'leftarrow'}
				if handles.is4d == 0
					sliceno = get(handles.slicenoslider,'Value');
					sliceno = max(sliceno - 1,1);
					set(handles.slicenoslider,'Value',sliceno);
					slicenoslider_Callback(handles.slicenoslider, [], handles);
				else
					if handles.image4dnum > 1
						handles.image4dnum = handles.image4dnum - 1;
						handles.image = handles.image4d(:,:,:,handles.image4dnum);
						guidata(handles.figure1,handles);
						UpdateDisplay(handles);
						set(gcbf,'Name',sprintf('View3D - Image #%d',handles.image4dnum));
					end
				end
			case 'home'
				set(handles.slicenoslider,'Value',1);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
			case 'end'
				set(handles.slicenoslider,'Value',slicemax);
				slicenoslider_Callback(handles.slicenoslider, [], handles);				
		end
end


% --------------------------------------------------------------------
function Zoom_In_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_In_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

p = get(gca,'CurrentPoint');

if handles.zoom_factors(handles.displaymode) < 1
	handles.zoom_factors(handles.displaymode) = handles.zoom_factors(handles.displaymode) + 0.1;
else
	handles.zoom_factors(handles.displaymode) = handles.zoom_factors(handles.displaymode) + 0.2;
end
handles.zoom_centers(handles.displaymode,:) = [p(1) p(3)];

guidata(handles.figure1,handles);
UpdateDisplay(handles,0,0);

return;

% --------------------------------------------------------------------
function Zoom_Out_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_Out_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

p = get(gca,'CurrentPoint');

if handles.zoom_factors(handles.displaymode) <= 1
	handles.zoom_factors(handles.displaymode) = max(handles.zoom_factors(handles.displaymode) - 0.1,0.1);
else
	handles.zoom_factors(handles.displaymode) = handles.zoom_factors(handles.displaymode) - 0.2;
end
handles.zoom_centers(handles.displaymode,:) = [p(1) p(3)];

guidata(handles.figure1,handles);
UpdateDisplay(handles,0,0);

return;

% --------------------------------------------------------------------
function Zoom_Reset_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_Reset_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.zoom_factors(handles.displaymode);
dim = handles.dim;
default_zoom_centers = [dim(2)/2 dim(3)/2;dim(1)/2 dim(3)/2;dim(2)/2 dim(1)/2];
handles.zoom_factors(handles.displaymode) = 1;
handles.zoom_centers(handles.displaymode,:) = default_zoom_centers(handles.displaymode,:);
guidata(handles.figure1,handles);
UpdateDisplay(handles,0,0);

return;




% --------------------------------------------------------------------
function Zoom_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Zoom_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function value = Check_MenuItem(hObject,FlipItOver)
if ~exist('FlipItOver','var')
	FlipItOver = 0;
end

checked = get(hObject,'Checked');
switch checked
	case 'on'
		if FlipItOver == 0
			value = 1;
		else
			set(hObject,'Checked','off');
			value = 0;
		end
	case 'off'
		if FlipItOver == 0
			value = 0;
		else
			set(hObject,'Checked','on');
			value = 1;
		end
end

return;


function vecout=normalized2pixel(vec,H)
if ~exist('H','var')
	pos = get(gcf,'Position');
else
	pos = get(H,'Position');
end
vecout = vec;
vecout(1:2:end) = vecout(1:2:end)*pos(3);
vecout(2:2:end) = vecout(2:2:end)*pos(4);
return;



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% view3dgui('figure1_WindowButtonMotionFcn',gcbo,[],guidata(gcbo))
% view3dgui('figure1_WindowButtonUpFcn',gcbo,[],guidata(gcbo))
current_mouse_point = round(get(handles.mainaxes, 'currentPoint'));
xa = get(handles.mainaxes,'xlim');
ya = get(handles.mainaxes,'ylim');
if current_mouse_point(1,1) < xa(1) || current_mouse_point(1,1) > xa(2) ||  ...
	current_mouse_point(1,2) < ya(1) || current_mouse_point(1,2) > ya(2) 
	return;
end

handles.current_mouse_point = current_mouse_point;
handles.WindowButtonUpFcn_save = get(handles.figure1,'WindowButtonUpFcn');
handles.WindowButtonMotionFcn_save = get(handles.figure1,'WindowButtonMotionFcn');

set(handles.figure1, 'WindowButtonUpFcn', 'view3dgui(''figure1_WindowButtonUpFcn'',gcbo,[],guidata(gcbo))');
set(handles.figure1, 'WindowButtonMotionFcn', 'view3dgui(''figure1_WindowButtonMotionFcn'',gcbo,[],guidata(gcbo))');

guidata(handles.figure1,handles);

return;




% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(whos('global','view3dgui_mouse_in_motion'))
	global view3dgui_mouse_in_motion;
else
	global view3dgui_mouse_in_motion;
	view3dgui_mouse_in_motion = 0;
end

if view3dgui_mouse_in_motion > 0 
	return;
else
	view3dgui_mouse_in_motion = 1;
end


current_mouse_point = round(get(handles.mainaxes, 'currentPoint'));
x = current_mouse_point(1,1);
y = current_mouse_point(1,2);
x0 = handles.current_mouse_point(1,1);
y0 = handles.current_mouse_point(1,2);

handles.current_mouse_point = current_mouse_point;

% step = min(floor(double(handles.max) / 50),15);
if handles.max > 100
	step = 1;
else
	step = double(handles.max)/100;
end

windowcenter = str2num(get(handles.windowcenterinput,'String'));
windowcenter2 = windowcenter;
% if abs(x-x0) > 5
% 	windowcenter2 = windowcenter + sign(x-x0)*step;
	windowcenter2 = windowcenter + (x-x0)*step;
% end


windowwidth = str2num(get(handles.windowwidthinput,'String'));
windowwidth2 = windowwidth;
% if abs(y-y0)>5
% 	windowwidth2 = windowwidth+sign(y-y0)*step;
	windowwidth2 = windowwidth+(y-y0)*step;
% end
windowwidth2 = max(windowwidth2,0);

if windowcenter ~= windowcenter2 || windowwidth ~= windowwidth2
	set(handles.windowcenterinput,'String',num2str(windowcenter2));
	set(handles.windowwidthinput,'String',num2str(windowwidth2));
	guidata(handles.figure1,handles);
	minv = (windowcenter2 - windowwidth2/2);
	maxv = (windowcenter2 + windowwidth2/2);
	if minv == maxv
		maxv = max(maxv,minv+double(handles.max)/1000);
	end

	set(gca,'clim',[minv maxv]);
end

view3dgui_mouse_in_motion = 0;

return;


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.figure1, 'WindowButtonUpFcn', handles.WindowButtonUpFcn_save);
set(handles.figure1, 'WindowButtonMotionFcn', handles.WindowButtonMotionFcn_save);

return;



% --------------------------------------------------------------------
function Flip_X_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Flip_X_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.flipX = Check_MenuItem(hObject,1);
guidata(handles.figure1,handles);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function Flip_Y_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Flip_Y_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.flipY = Check_MenuItem(hObject,1);
guidata(handles.figure1,handles);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function Flip_Z_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Flip_Z_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.flipZ = Check_MenuItem(hObject,1);
guidata(handles.figure1,handles);
UpdateDisplay(handles);


% --------------------------------------------------------------------
function SetRotation(handles,degree)
if handles.rotation ~= degree
	handles.rotation=degree;
	set(handles.Rotate_0_Menu_Item,'checked','off');
	set(handles.Rotate_90_Menu_Item,'checked','off');
	set(handles.Rotate_180_Menu_Item,'checked','off');
	set(handles.Rotate_270_Menu_Item,'checked','off');
	switch degree
		case 0
			set(handles.Rotate_0_Menu_Item,'checked','on');
		case 90
			set(handles.Rotate_90_Menu_Item,'checked','on');
		case 180
			set(handles.Rotate_180_Menu_Item,'checked','on');
		case 270
			set(handles.Rotate_270_Menu_Item,'checked','on');
	end
	guidata(handles.figure1,handles);
	UpdateDisplay(handles);
end
return;

% --------------------------------------------------------------------
function Rotate_0_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_0_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetRotation(handles,0);

% --------------------------------------------------------------------
function Rotate_90_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_90_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetRotation(handles,90);

% --------------------------------------------------------------------
function Rotate_180_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_180_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetRotation(handles,180);

% --------------------------------------------------------------------
function Rotate_270_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Rotate_270_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SetRotation(handles,270);


% --------------------------------------------------------------------
function Options_Show_DVF_Menu_Item_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Show_DVF_Menu_Item (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Check_MenuItem(hObject,1);
UpdateDisplay(handles);




% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[x,y]=ginput(3);




% --------------------------------------------------------------------
function Process_Stones_Callback(hObject, eventdata, handles)
% hObject    handle to Process_Stones (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


pixelsize=[200/512 200/512];


stepsize=0.8;

kidney=handles.image;

landmark_data=round(handles.landmarks);

number_of_landmarks=size(handles.landmarks,1);
% stone=speed(kidney,landmark_data(1,2:4));


[stone,kidney_5cm,all_images]=semi_auto_stone_selector(kidney,landmark_data(number_of_landmarks,2:4),pixelsize,stepsize);



Object=stone;


view3dgui(stone);

%view3dgui(kidney_5cm);
% %Object=handles.image;
% 
% 
% 
% 
% % ONLY A TEST for INTERPOLATION
% %_______________________________________________________________
% [l,n,m] = size(stone);
% N = floor((10^6/l/m/n)^(1/3));% 4 times interp
% if N<1
%     N = 1;
% end
% [x,y,z] = meshgrid(0:n-1,0:l-1,0:m-1);
% [X,Y,Z] = meshgrid(0:N*n-N,0:N*l-N,0:N*m-N);
% X = X/N;
% Y = Y/N;
% Z = Z/N;
% Object = interp3(x,y,z,stone,X,Y,Z);
% 
% %_______________________________________________________________






[l,q,m] = size(Object);


steps=[-1024, min(Object(:)):1:max(Object(:))];


volumes=zeros(length(steps),1);



for n=1:length(steps)
    
    ROI=Object>steps(n);
    
    %______connected ROI____________
    
%     Connected_ROI=bwconncomp(ROI);
% 
%     LabeledConnections=labelmatrix(Connected_ROI);
% 
%     indices=find(LabeledConnections==LabeledConnections(ceil(l/2),ceil(q/2),ceil(m/2)));
% 
% 
%     Conn_ROI=zeros(size(ROI));
%     
%     Conn_ROI(indices)=ROI(indices);
    
    %_____________________________________
    
%    view3dgui(ROI);
%    
%    pause();
   
   volumes(n)=sum(ROI(:));
   
end



Volume_derivative=diff(volumes);


 
figure();

subplot(1,3,1);

plot(steps,volumes)

subplot(1,3,2);






filterorder = 31;


completion_before=ones((filterorder-1)/2,1)*Volume_derivative(1);

completion_After=ones((filterorder-1)/2,1)*Volume_derivative(end);




filter_coeff = ones(1, filterorder)/filterorder;


Filtered_Diff_volume = conv([completion_before; Volume_derivative; completion_After],filter_coeff,'valid');


plot(steps(2:end),Volume_derivative);

hold on



[Min_diff_volume,minIDX]=min(Filtered_Diff_volume);

Bkg=steps(minIDX+1);
 
Max_Value=steps(end);




 
 plot(steps(2:end), Filtered_Diff_volume,'linewidth',2,'color','r')
 
 

 figure();
 
 
 Y=fft(Filtered_Diff_volume(minIDX:end)/sum(Filtered_Diff_volume(minIDX:end)));
 
 
 plot(abs(Y));
 
 figure();
 
 
 Y=fft(Volume_derivative(minIDX:end)/sum(Volume_derivative(minIDX:end)));
 
 
 plot(abs(Y),'color','g');
 
 %plot([Bkg Max_Value],[Min_diff_volume Volume_derivative(end)]);
 
 th=(Max_Value+Bkg)/2;
 
 x = fminbnd(@(x) myfun(x,steps(2:end),Filtered_Diff_volume),th,Max_Value);

 
 
 % th=(x+Bkg)/2;
 
 ROI=Object>th;
    
    %______connected ROI____________
    
    Connected_ROI=bwconncomp(ROI);

    LabeledConnections=labelmatrix(Connected_ROI);

    indices=find(LabeledConnections==LabeledConnections(ceil(l/2),ceil(q/2),ceil(m/2)));


    Conn_ROI=zeros(size(ROI));
    
    Conn_ROI(indices)=ROI(indices);
    
    %_____________________________________
    

   
   %Vol_Th=sum(Conn_ROI(:))*(0.8/N)*((200/512)/N)^2;
 
   Vol_Th=sum(Conn_ROI(:))*(stepsize)*(pixelsize(1)*pixelsize(2));
   
 
 
 title(['Bkg= ' num2str(Bkg) ', Max= ' num2str(Max_Value) ', Th= ' num2str(th,'%6.0f') ', Vol= ' num2str(Vol_Th,'%6.2f') ', x= ' num2str(x,'%6.0f')]);
 
 
  clipboard('copy', num2str(Vol_Th,'%6.2f'));
 
%  guidata(handles.figure1,handles);
%  UpdateDisplay(handles,0,1);




   %__ Calculate Object Binary Surface
ROI_a=Conn_ROI;
ROI_c=Conn_ROI;
ROI_s=Conn_ROI;

for n=1:size(ROI,3)
ROI_a(:,:,n)= bwmorph(ROI(:,:,n),'remove');
end

for n=1:size(ROI,1)
ROI_c(n,:,:)= bwmorph(squeeze(ROI(n,:,:)),'remove');
end

for n=1:size(ROI,2)
ROI_s(:,n,:)= bwmorph(squeeze(ROI(:,n,:)),'remove');
end

ROI=or(ROI_a,or(ROI_c,ROI_s));



%Singular Value Decomposition of object surface coordinates to 
%calculate size across main axes

ind = find(ROI);
[y,x,z] = ind2sub(size(ROI),ind);

%Zero_Reference = [mean(x),mean(y),mean(z)];

x=x-mean(x);
y=y-mean(y);
z=z-mean(z);

[~,~,V] = svd([x,y,z],0);

% disp(dot(V(:,1),V(:,2)));
% disp(dot(V(:,1),V(:,3)));
% disp(dot(V(:,2),V(:,3)));

Px = [x,y,z]*V(:,1);
Py = [x,y,z]*V(:,2);
Pz = [x,y,z]*V(:,3);


%___Dimesnsion in main axes
l = (max(Px)-min(Px))*pixelsize(1);
w = (max(Py)-min(Py))*pixelsize(2);
h = (max(Pz)-min(Pz))*stepsize;


%_____Maximum Object Diameter__________________________________

D = pdist([x y z],'euclidean');

Dist=squareform(D);

[~,idxMAX]=max(Dist(:));

[xIDX,yIDX] = ind2sub(size(Dist),idxMAX);


Max_Diameter= sqrt((abs(x(xIDX)-x(yIDX))*pixelsize(1))^2 ...
+(abs(y(xIDX)-y(yIDX))*pixelsize(2))^2+(abs(z(xIDX)-z(yIDX))*stepsize)^2);
%______________________________________________________________


% disp(['l: ',num2str(l','%6.2f'),' mm']);
% disp(['w: ',num2str(w,'%6.2f'),' mm']);
% disp(['h: ',num2str(h,'%6.2f'),' mm']);
% 
% disp(['Max: ',num2str(Max_Diameter,'%6.2f'),' mm']);


dimensions=sort([l,w,h],'descend');

l=dimensions(1);

w=dimensions(2);

h=dimensions(3);

clipboard('copy', [num2str(Vol_Th,'%6.2f'),' ',num2str(l,'%6.2f'),' ',num2str(w,'%6.2f'),' ',num2str(h,'%6.2f'),' ',num2str(Max_Diameter,'%6.2f')]);



return;

function f=myfun(x,steps,volume_profile)


if x<steps(1)
    
    f=volume_profile(1);
    
elseif x>steps(end)

    f=volume_profile(end);


else
   
    [~,IDX]=min(abs(steps-x));
    
     f=volume_profile(IDX);
    
end





% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

    current_slider_value = round(get(handles.slicenoslider, 'value'));
    
    
    current_slider_min = round(get(handles.slicenoslider, 'min'));
    
    current_slider_max = round(get(handles.slicenoslider, 'max'));
    
    
    scrolldelta = 1;
    
    if eventdata.VerticalScrollCount > 0
        
        if current_slider_value > current_slider_min
         set(handles.slicenoslider, 'value', current_slider_value - scrolldelta);
        
         sliceno = current_slider_value - scrolldelta;
         
         handles.slicenos(handles.displaymode) = sliceno;
         guidata(handles.figure1,handles);
         set(handles.slicenoinput,'String',num2str(sliceno));
         UpdateDisplay(handles);

         
         
        end
    else
        
        if current_slider_value < current_slider_max
        set(handles.slicenoslider, 'value', current_slider_value + scrolldelta);
        
        sliceno = current_slider_value + scrolldelta;
        
         handles.slicenos(handles.displaymode) = sliceno;
         guidata(handles.figure1,handles);
         set(handles.slicenoinput,'String',num2str(sliceno));
         UpdateDisplay(handles);

        
        end
    end

   
    
    
    
return


