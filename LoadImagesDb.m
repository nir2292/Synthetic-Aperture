function [ db ] = LoadImagesDb( dirPath )
%LOADIMAGESDB given a directory path to an images database, loads the
% images and returns them in a cell array
display('loading db...');

db = {};
ImageFiles = dir([dirPath '/*.*']);
dbIndex = 1;
for Index = 1:length(ImageFiles)
    baseFileName = ImageFiles(Index).name;
    [folder, name, extension] = fileparts(baseFileName);
    extension = upper(extension);
    switch lower(extension)
    case {'.png', '.bmp', '.jpg', '.tif', '.avi'}
    % Allow only PNG, TIF, JPG, or BMP images
    fullpath = strcat(dirPath, baseFileName);
    db{dbIndex} = im2double((imread(fullpath)));
    dbIndex = dbIndex + 1;
    end
end

end