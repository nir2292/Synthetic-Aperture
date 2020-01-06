function [ output ] = Refocus( images, distance )
%REFOCUS digital refocus of an image using a light field (array of images
% that were shot form a camera moving horizontally), the focus is
% determined by the given distance

dims = size(images{1});
numOfImgs = size(images, 2);
isFirst = true;

for i = 1:numOfImgs 
    currImage = images{i};

    % determine shift
    firstCol = (numOfImgs - i) * distance + 1;
    lastCol = dims(2) - (i - 1) * distance;
    
    % interpolate
    firstCol = lastCol - floor(lastCol - firstCol);
    alpha = firstCol - floor(firstCol);
    left = currImage(:,floor(firstCol):floor(lastCol),:);
    right = currImage(:,ceil(firstCol):ceil(lastCol),:);
    imageToAdd = (1 - alpha) .* left + alpha .* right;
    
    if isFirst
        output = imageToAdd ./ numOfImgs;
        isFirst = false;
    else
        output = output + (imageToAdd ./ numOfImgs);
    end  
end

end