function im = quantize_colors(im)
%QUANTIZE_COLORS Summary of this function goes here
%   Detailed explanation goes here

    colorLimit = 7;
    threshRGB = multithresh(im, colorLimit);
    threshForPlanes = zeros(3, colorLimit);			
    for i = 1:3
        threshForPlanes(i,:) = multithresh(im(:,:,i), colorLimit);
    end
    value = [0 threshRGB(2:end) 255]; 
    quantRGB = imquantize(im, threshRGB, value);
    im = medfilt3(quantRGB);
    im = medfilt3(im);

end

