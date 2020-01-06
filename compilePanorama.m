function panorama = compilePanorama(canvas, image, pixShifts, imageIndex, firstOffset)
    
    panorama = canvas;
    verOffset = firstOffset;
    horOffset = 0;
    imageSize = size(image);
    
    for i = 2:imageIndex
        verOffset = verOffset + pixShifts.ver{i};
        horOffset = horOffset + pixShifts.hor{i};
    end
    
    panorama((1 + ceil(verOffset)):(ceil(verOffset)+imageSize(1)) , ...
             (1 + ceil(horOffset)):(ceil(horOffset)+imageSize(2))) = image;
    
end