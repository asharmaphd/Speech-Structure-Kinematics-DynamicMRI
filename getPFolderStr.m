function [PFolderStr]=getPFolderStr(PName)
    if (PName=="P083122")
        PFolderStr="P083122/CartesianDicom/AllCartesianDicoms";
    elseif (strcmp(PName,"P012423")==1 || strcmp(PName,"P020323")==1 || strcmp(PName,"P021423")==1 || strcmp(PName,"P021623")==1|| strcmp(PName,"P022423")==1)
        PFolderStr=strcat(PName,'/CartesianDicoms/DicomData');
    else
        PFolderStr=strcat(PName,'/CartesianDicoms');
    end
end