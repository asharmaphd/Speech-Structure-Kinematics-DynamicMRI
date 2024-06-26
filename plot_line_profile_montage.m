function []=plot_line_profile_montage(fignum,opfolder,opsubfolder,brightfactor,...
            allhorzline,allhorzline_2,allhorzline_3,...
            allvertline,allvertline_2,allvertline_3)

    figure(fignum+6); colormap("gray");clim([0 1]);
    hold on;
    %flipud to correct the up-down swap which happens due to the difference
    %in origin when reading an image/y-axis
    montage([flipud(allhorzline_2),flipud(allhorzline),flipud(allhorzline_3)]);
    brighten(brightfactor);
    title('Montage All Vert')
    hold off;
    axis tight
    saveas(gcf,strcat(opfolder,opsubfolder,'/','Montage_AllVert'));

    figure(fignum+7); colormap("gray");clim([0 1]);
    hold on;
    %flipud to correct the up-down swap which happens due to the difference
    %in origin when reading an image/y-axis
    montage([flipud(allvertline_2),flipud(allvertline),flipud(allvertline_3)]);
    brighten(brightfactor);
    title('Montage All Horz')
    hold off;
    axis tight

    saveas(gcf,strcat(opfolder,opsubfolder,'/','Montage_AllHorz'));

end