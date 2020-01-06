function [ output ] = CreateImage( images, translations, startImageIndex, endImageIndex )
%CREATEIMAGE 1 <= startImageIndex <= endImageIndex <= images.count

% if output is a single image
if startImageIndex == endImageIndex
    output = images{startImageIndex};
    return;
end

if startImageIndex > endImageIndex
    tempStartImageIndex = startImageIndex;
    startImageIndex = endImageIndex;
    endImageIndex = tempStartImageIndex;
    images = flip(images);
    translations.hor = flip(translations.hor);
    translations.ver = flip(translations.ver);
end

% first image
mixVector = (size(images{startImageIndex},2) + translations.hor{startImageIndex + 1}) / 2 ;

for i = startImageIndex + 1 : endImageIndex - 1
        
    % find relations between images 2 to n-1
    mixVector = [ mixVector , ...
        (size(images{i},2) + translations.hor{i}) / 2 + ...
        (size(images{i},2) + translations.hor{i + 1}) / 2 ];
    
end

% last image
mixVector = [ mixVector , ...
    (size(images{endImageIndex},2) + translations.hor{endImageIndex}) / 2 ];

% take only relevant shifts (for subset of images)
subPixShift.hor = translations.hor(startImageIndex:endImageIndex);
subPixShift.ver = translations.ver(startImageIndex:endImageIndex);

% create canvas and aquire vertical offset for first image
[canvas, firstImRowsOffset] = createCanvas(subPixShift, size(images{1}));
sizeOfOutput = size(canvas);

% init first vertical offset
subPixShift.ver{1} = firstImRowsOffset;

% init first and last horizontal offset
subPixShift.hor{endImageIndex - startImageIndex + 2} = 0;
subPixShift.hor{1} = 0;

% vector of strip widths
stripVector = (mixVector/sum(mixVector)) * sizeOfOutput(2);

output = zeros(ceil(sizeOfOutput));

currColumn = 1;
verOffset = 0;
horOffset = 0;
    
for i = startImageIndex : endImageIndex
    verOffset = verOffset + subPixShift.ver{i - startImageIndex + 1};
    
    % rounding strip size   
    stripWidth = round(stripVector(i - startImageIndex + 1));
    
    % making sure strip is in boundries
    stripWidth = round( min([stripWidth , ...
        sizeOfOutput(2)-currColumn, ...
        size(images{i},2) + horOffset - (currColumn+stripWidth) ]) );
    
    stripWidth = max(stripWidth, 0);
    
    % col inside a single image
    subImCol = round(currColumn-horOffset);
    
    % inserting strip in output
    output((round(verOffset)+1):(round(verOffset)+size(images{i},1)) , currColumn:(currColumn+stripWidth - 1) , :) =...
        images{i}(: , subImCol:(subImCol+stripWidth - 1) , :);
    

    currColumn = currColumn + stripWidth;
    horOffset = horOffset + subPixShift.hor{i - startImageIndex + 1};
    
end

end