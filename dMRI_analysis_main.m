

function []=dMRI_analysis_main(PName,imgnum,flagvideo,flagSagMisc,flagcrosshair)%varargin)

%Initial cleanup
clc
close all

%% READING INPUT FILES
% get string for dicom folder path 
PFolderStr=getPFolderStr(PName)

%read dicom files
[dfoldername,opfolder,allfilestab]=readPFolderDicoms(PFolderStr,PName)


%% setting up variables 

% to support saving multiple anatomical options for Mid Sag images
strSagMisc='';
if (flagSagMisc==0)
    strSagMisc='';            %default flagSagMisc=0 (Larynx)
elseif (flagSagMisc==1)
    strSagMisc='Tongue';      %input flagSagMisc=1 
elseif (flagSagMisc==2)
    strSagMisc='SoftPalate';  %input flagSagMisc=2
end

% preset vars
brightfactor=0.6;   %factor by which to brighten displayed MRI images
scalefact=2;        %If image scaling due to interpoaltion is needed, currently not used
sm_3d=0.1;          %If 3D smoothing is required, currebtly not used
sm_2d=0.5;          %If 2D smoothing is required (spatial, single slice only)
slicenum=50;        %slice number picked from stack for drawing crosshair
linelen=40;         %half of length of crosshair grid lines (in pixels)
shiftfact=8;        %distance between middle and side crosshair lines (in pixels)
margin=5;           %used to pad cropped ROI image, for display
fignum=100;         %Starting figure initializer

temporalfootprint=65/1000;      %milliseconds, w.r.t MRI acquisition settings
pixelsize=0.78;                 %millimeters, w.r.t MRI acquisition settings

% disp("Number of input arguments: " + nargin)
% celldisp(varargin)
% 
% if (nargin==0)
%     flagvideo=1;
% else
%     varargin{1}
%     flagvideo=cell2mat(varargin{1})
% end


%% READ DICOM FILE, TAKE GRAPHICAL USER INPUT


for fcount=imgnum:imgnum%numrow  

    %% Reading the selected dicom file (imgnum) in the folder

    %The first two subfolders are . and .. so skip them, or use the saved .mat
    %allfilestable to find the exact number in the fileindex column
    if (strcmp(table2array(allfilestab(fcount,1)),'.')==0 ...
            & strcmp(table2array(allfilestab(fcount,1)),'..')==0 ...
            & strcmp(table2array(allfilestab(fcount,1)),'ConnectedSentences')==0)        
        
        % Optional: table2array(allfilestab(fcount,5))==1 &... %isdir field in table
        
        dfname=cell2mat(table2array(allfilestab(fcount,1)))     %Name of subfolder field
        opsubfolder=dfname;
        
        %if not larynx (default), adding substring for tongue/SoftPalate regions
        if (flagSagMisc~=0)
            opsubfolder=strcat('/',opsubfolder,'_',strSagMisc,'/');
        end
    
        if ~exist(strcat(opfolder,opsubfolder), 'dir')
               mkdir(opfolder, opsubfolder)
        end
    
        % converting to matrix 
        allframesmat=dicomreadVolume(strcat(dfoldername,dfname));
        allframes=mat2gray(double(squeeze(allframesmat)));
        whos allframes
        %allframesmat=load("allframes.mat");
        % save allframes.mat allframes
    
        %% Get Crosshair Location from user input 
        
        [w h nf]=size(allframes);
        % allframes=interp3(double(allframesmat.allframes),1);
        %allframes=(double(allframesmat.allframes));
        % allframes=mat2gray(double(allframesmat.allframes));
        % whos allframes
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure(fignum); colormap("gray")
        %allframes=imgaussfilt3(allframes,sm_3d,"FilterDomain","spatial");
        slice  = allframes(:,:,slicenum);
        imshow(slice,[]);
        brighten(brightfactor)
        axis tight
    
        % Get crosshair click and save it
        if (flagcrosshair==1) 
            title('Click to mark the center of crosshair grid');
            [manual_x manual_y]=ginput(1);
            crosshair_center=[manual_x manual_y]
            save(strcat(opfolder,opsubfolder,'/','crosshair.mat'),'crosshair_center');
        % Use a previously saved crosshair click's location
        else
            crosshair=load(strcat(opfolder,opsubfolder,'/','crosshair.mat'));
            manual_x=crosshair.crosshair_center(1)
            manual_y=crosshair.crosshair_center(2)
        end
    
        manual_x=uint16(manual_x)
        manual_y=uint16(manual_y)
        saveas(gcf,strcat(opfolder,opsubfolder,'/',"MainImage_rev3.fig"));
    
        %% Validate ROI
        %Validate the region-of-interest of image based on crosshair location
        %and cropping based on grid lines
    
        validate_image_ROI(fignum,opfolder,opsubfolder,...
            slice,manual_x,manual_y,linelen,margin,shiftfact,brightfactor);
    
            
        %% Create grid lines for tracking
            
        % calculating grid line locations based on original image size
        vertline=uint16([manual_x manual_x ; manual_y-linelen manual_y+linelen]);
        vertline_2=uint16([manual_x-shiftfact manual_x-shiftfact ; manual_y-linelen manual_y+linelen]);
        vertline_3=uint16([manual_x+shiftfact manual_x+shiftfact ; manual_y-linelen manual_y+linelen]);
        
        horzline=uint16([manual_x-linelen manual_x+linelen ; manual_y manual_y]);
        horzline_2=uint16([manual_x-linelen manual_x+linelen ; manual_y-shiftfact manual_y-shiftfact]);
        horzline_3=uint16([manual_x-linelen manual_x+linelen ; manual_y+shiftfact manual_y+shiftfact]);
        
            
        %% For Temporal tracking of grid lines using line profiles
        %Initializations
        allvertline=zeros(2*linelen+1,nf);%*scalefact);
        allvertline_2=zeros(2*linelen+1,nf);%*scalefact);
        allvertline_3=zeros(2*linelen+1,nf);%*scalefact);
        allhorzline=zeros(2*linelen+1,nf);%*scalefact);
        allhorzline_2=zeros(2*linelen+1,nf);%*scalefact);
        allhorzline_3=zeros(2*linelen+1,nf);%*scalefact);
        
        % loop over all temporal video frames to collect data over time
        for k=1:nf%*scalefact
                
            % Get the next video frame
            currFrameorig = squeeze(allframes(:,:,k));
            %currFrame=imgaussfilt(currFrame,sm_2d);
            %currFrame=imguidedfilter(currFrameorig);
            currFrame=currFrameorig;
            
            currFrame_croporig=imcrop(currFrame,[manual_x-linelen manual_y-linelen...
            2*linelen 2*linelen]);
        
            currFrame_crop=imgaussfilt(currFrame_croporig,sm_2d);
            %currFrame_crop=imguidedfilter(currFrame_croporig);
            %currFrame_crop=imsharpen(imguidedfilter(currFrame_croporig),...
            %         "Threshold",0.85);
            %currFrame_crop=imsharpen(imsharpen(imguidedfilter(currFrame_croporig),...
            %         "Threshold",0.85),"Threshold",0.85);
            %currFrame_edge=edge(currFrame_crop,"canny",0.1,"nothinning");
                    
            if (k==slicenum) % sanity check with a selected image slice
                size(currFrame_crop)
                figure(fignum+2);colormap(gray);
                hold on;
                image(flipud(currFrame_crop),'AlphaData',0.9,'CDataMapping','scaled');
                plot([linelen+1;linelen+1],...
                    [1;2*linelen],'red','LineWidth',2);
                plot([1;2*linelen],...
                    [linelen+1;linelen+1],'red','LineWidth',2);
                title('CroppedROI ExactSize SanityCheck');
                axis tight
                hold off;
            end
            
            % the matlab filter/crop ops reads the image matrix x-first
            % while as image, it's read column first. So, vert and horz are
            % swapped
            allvertline(:,k)=squeeze(currFrame_crop(...
                linelen+1:linelen+1,1:2*linelen+1));
            allvertline_2(:,k)=squeeze(currFrame_crop(...
                linelen-shiftfact:linelen-shiftfact,1:2*linelen+1));
            allvertline_3(:,k)=squeeze(currFrame_crop(...
                linelen+shiftfact:linelen+shiftfact,1:2*linelen+1));
            allhorzline(:,k)=squeeze(currFrame_crop(...
                1:2*linelen+1,linelen+1:linelen+1));
            allhorzline_2(:,k)=squeeze(currFrame_crop(...
                1:2*linelen+1,linelen-shiftfact:linelen-shiftfact));
            allhorzline_3(:,k)=squeeze(currFrame_crop(...
                1:2*linelen+1,linelen+shiftfact:linelen+shiftfact));
            
        end
    
        saveas(gcf,strcat(opfolder,opsubfolder,'/',"CroppedROIExact_SanityCheck_rev3.fig"));
            
            
        
        %% final figures using original image size
        show_main_image(fignum,opfolder,opsubfolder,allframes,slicenum,sm_2d,brightfactor);
        show_main_image_with_grid(fignum,opfolder,opsubfolder,allframes,slicenum,sm_2d,brightfactor,...
            horzline,horzline_2,horzline_3,...
            vertline,vertline_2,vertline_3);
        
        %% Individual line profile plots for all grid lines
    
        %setting tick lables to encourage multiples of 5 mm and 5 sec
        %during display
        x_ticks=0:1*((1/temporalfootprint)):nf;
        x_units=x_ticks.*temporalfootprint;
        y_ticks=0:5*((1/pixelsize)):(2*linelen+1)
        y_units=y_ticks.*pixelsize
        
        % calling custom plotting function for each line
        plot_line_profile(allvertline,'Horizontal Line Profile (red)',...
            opfolder,opsubfolder,brightfactor,'LP_Horz_Red_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        plot_line_profile(allvertline_2,'Horizontal Line Profile (yellow)',...
            opfolder,opsubfolder,brightfactor,'LP_Horz_Yellow_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        plot_line_profile(allvertline_3,'Horizontal Line Profile (green)',...
            opfolder,opsubfolder,brightfactor,'LP_Horz_Green_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        
        
        plot_line_profile(allhorzline,'Vertical Line Profile (red)',...
            opfolder,opsubfolder,brightfactor,'LP_Vert_Red_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        plot_line_profile(allhorzline_2,'Vertical Line Profile (yellow)',...
            opfolder,opsubfolder,brightfactor,'LP_Vert_Yellow_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        plot_line_profile(allhorzline_3,'Vertical Line Profile (green)',...
            opfolder,opsubfolder,brightfactor,'LP_Vert_Green_rev3.fig',...
            x_ticks,x_units,y_ticks,y_units)
        
        %% montage of all vertical and all horizontal grid lines
        plot_line_profile_montage(fignum,opfolder,opsubfolder,brightfactor,...
            allhorzline,allhorzline_2,allhorzline_3,...
            allvertline,allvertline_2,allvertline_3);
        
    
        %flagdone=input("Analysis finished for this MRI image? (Yes:1/No:0)");
        
    end
end


end



