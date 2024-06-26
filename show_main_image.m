function []=show_main_image(fignum,opfolder,opsubfolder,...
    allframes,slicenum,sm_2d,brightfactor)
        
    figure(fignum+3); colormap("gray")
    hold on;
    slice  = imgaussfilt(squeeze(allframes(:,:,slicenum)),sm_2d);
    imshow(slice,[]);
    title('A single slice from the dynamic MR stack');
    brighten(brightfactor);
    
    hold off;
    saveas(gcf,strcat(opfolder,opsubfolder,'/',"MainImage_Smoothed_rev3.fig"));
    %saveas(gcf,strcat(opfolder,opsubfolder,'/',"MainImage_Smoothed_rev3.png"));

end