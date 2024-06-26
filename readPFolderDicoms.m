function [dfoldername,opfolder,allfilestab]=readPFolderDicoms(PFolderStr,PName)

    % setting input and output folder paths
    dfoldername=strcat('./../InputVideos','/',PFolderStr,'/');
    opfolder=strcat('./../Output/',PName,'/AllCartesian_rev3/');
    
    if ~exist(opfolder, 'dir')
           mkdir(opfolder)
    end
    
    allfiles=dir(dfoldername);
    allfilestab=struct2table(allfiles)
    numrow=size(allfilestab,1)
    findex=[1:numrow]';
    allfilestab = addvars(allfilestab(:,1:2),findex);
    % head(allfilestab,5);
    save(strcat(opfolder,'allfilestable.mat'),'allfilestab')

end