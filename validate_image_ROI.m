function []=validate_image_ROI(fignum,opfolder,opsubfolder,...
        slice,manual_x,manual_y,linelen,margin,shiftfact,brightfactor)

    sanitycheck_crop=imcrop(slice,[manual_x-linelen-margin manual_y-linelen-margin ...
         (2*linelen)+(2*margin) (2*linelen)+(2*margin)]);
    [cw ch]=size(sanitycheck_crop)
    crop_center_x=uint16(floor(cw/2)) 
    crop_center_y=uint16(floor(ch/2))

    %draw lines on 'cropped ROI+with padded 'margin'
    %total size of cropped+padded ROI: linelen+linelen+1+margin+margin
    % calculated based on cropped+padded image size
    crop_vertline=uint16([crop_center_x crop_center_x ; crop_center_y-linelen crop_center_y+linelen]);
    crop_vertline_2=uint16([crop_center_x-shiftfact crop_center_x-shiftfact ; crop_center_y-linelen crop_center_y+linelen]);
    crop_vertline_3=uint16([crop_center_x+shiftfact crop_center_x+shiftfact ; crop_center_y-linelen crop_center_y+linelen]);
    
    crop_horzline=uint16([crop_center_x-linelen crop_center_x+linelen ; crop_center_y crop_center_y]);
    crop_horzline_2=uint16([crop_center_x-linelen crop_center_x+linelen ; crop_center_y-shiftfact crop_center_y-shiftfact]);
    crop_horzline_3=uint16([crop_center_x-linelen crop_center_x+linelen ; crop_center_y+shiftfact crop_center_y+shiftfact]);
    
    %         slice=imgaussfilt(slice,sm_2d);
    %         % image(slice,'AlphaData',0.8,'CDataMapping','scaled');

    figure(fignum+1); colormap("gray")
    imshow(sanitycheck_crop,[]);brighten(brightfactor);
    hold on;
    
    plot(crop_vertline(1,:)',crop_vertline(2,:)','red','LineWidth',1,'LineStyle','--');
    plot(crop_vertline_2(1,:)',crop_vertline_2(2,:)','yellow','LineWidth',1,'LineStyle','--');
    plot(crop_vertline_3(1,:)',crop_vertline_3(2,:)','green','LineWidth',1,'LineStyle','--');
    plot(crop_horzline(1,:)',crop_horzline(2,:)','red','LineWidth',1);
    plot(crop_horzline_2(1,:)',crop_horzline_2(2,:)','yellow','LineWidth',1);
    plot(crop_horzline_3(1,:)',crop_horzline_3(2,:)','green','LineWidth',1);
    title('Selected line profiles for tracking');
    hold off;
    
    saveas(gcf,strcat(opfolder,opsubfolder,'/',"CroppedROI_with_lines_rev3.fig"));

end