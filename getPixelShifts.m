function pixShifts = getPixelShifts(imSet, usfac)
% imSet - cell array of images in order
% usfac - upsampling factor
% uses cross corelation on all images to obtain
% shifts of every image i to image i-1.

pixShifts.hor = {};
pixShifts.ver = {};

pixShifts.hor{1} = 0;
pixShifts.ver{1} = 0;

for i = 2:length(imSet)
    prevImage = rgb2gray(imSet{i-1});
    currImage = rgb2gray(imSet{i});
    [output, Greg] = dftregistration(fft2(prevImage),fft2(currImage),usfac);
    pixShifts.hor{i} = output(4);
    pixShifts.ver{i} = output(3);
end

end