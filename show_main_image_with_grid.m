function []= show_main_image_with_grid(fignum,opfolder,opsubfolder,...
    allframes,slicenum,sm_2d,brightfactor,...
    horzline,horzline_2,horzline_3,...
    vertline,vertline_2,vertline_3)

    figure(fignum+4); colormap("gray")
    %slicecrop=imcrop(slice,[manual_x-linelen manual_y-linelen...
    %     2*linelen 2*linelen]);
    % image(slice,'AlphaData',0.8,'CDataMapping','scaled');
    slice  = imgaussfilt(squeeze(allframes(:,:,slicenum)),sm_2d);
    imshow(slice,[]);
    hold on;
    title('Line profiles tracked along time');
    plot(vertline(1,:)',vertline(2,:)','red','LineWidth',1,'LineStyle','--');
    plot(vertline_2(1,:)',vertline_2(2,:)','yellow','LineWidth',1,'LineStyle','--');
    plot(vertline_3(1,:)',vertline_3(2,:)','green','LineWidth',1,'LineStyle','--');
    plot(horzline(1,:)',horzline(2,:)','red','LineWidth',1,'LineStyle','-');
    plot(horzline_2(1,:)',horzline_2(2,:)','yellow','LineWidth',1,'LineStyle','-');
    plot(horzline_3(1,:)',horzline_3(2,:)','green','LineWidth',1,'LineStyle','-');
    
    brighten(brightfactor);
    hold off;
    
    saveas(gcf,strcat(opfolder,opsubfolder,'/',"MainImage_WithLines_rev3.fig"));
    %saveas(gcf,strcat(opfolder,opsubfolder,'/',"MainImage_WithLines_rev3.png"));
    
end
