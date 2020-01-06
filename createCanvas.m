function [canvas, firstImRowsOffset] = createCanvas(pixShifts, imSize)

rowsAbove = 0;
rowsBelow = 0;
rows = imSize(1);
cols = imSize(2);
rowsCount = 0;
colsCount = 0;

for i = 2:length(pixShifts.hor)
    rowsCount = rowsCount + pixShifts.ver{i};
    colsCount = colsCount + pixShifts.hor{i};
    
    if rowsCount > 0
        if rowsCount > rowsBelow
            rowsBelow = rowsCount;
        end
    else
        if abs(rowsCount) > rowsAbove
            rowsAbove = abs(rowsCount);
        end
    end
        
    cols = cols + pixShifts.hor{i};
    
end

firstImRowsOffset = ceil(rowsAbove);

canvas = zeros(ceil(rows+rowsAbove+rowsBelow), ceil(cols));

end