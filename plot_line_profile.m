function []=plot_line_profile(linemat,titlestr,opfolder,opsubfolder,brightfactor,opstr,...
    x_ticks,x_units,y_ticks,y_units)


    figure(); colormap("gray");clim([0 1]);
    hold on;
    %flipud to correct the up-down swap which happens due to the difference
    %in origin when reading an image/y-axis
    imagesc(flipud(linemat));
    
    title(titlestr);
    %brighten(brightfactor);
    xlabel('Time (seconds)')
    ylabel('Displacement (mm)')
    % showing as ms and mm 
    xticks(x_ticks);
    xticklabels(cellstr(num2str(x_units')));
    yticks(y_ticks);
    yticklabels(cellstr(num2str(y_units')));
    %showing as # of pixel on right y-axis
    yyaxis right
    imagesc(flipud(linemat));
    brighten(brightfactor/3);
    yticks(round(y_ticks));
    ylabel('Number of pixels')
    hold off;
    axis tight

    saveas(gcf,strcat(opfolder,opsubfolder,'/',opstr));

    % % imagesc(imbilatfilt(allvertline));colorbar;
    % imagesc((allvertline_1));colorbar;title('Vertical Line 1(mid)');
    
    % allvertline_sm=imgaussfilt(allvertline_1,1);
    % image(allvertline_sm,"CDataMapping","scaled");colorbar;
    % title('smoothed')
    
    % figure();colormap("gray")
    % allvertline_resize=imresize(allvertline,2,'bilinear');
    % image(allvertline_resize,"CDataMapping","scaled")
    % title('scaled')
    
end