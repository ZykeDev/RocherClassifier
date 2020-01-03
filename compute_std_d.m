function out = compute_std_d(image)
%COMPUTE_STD_D Summary of this function goes here
[h, w, c] = size(image);

if c == 3
    sdR = std(image(:, :, 1));
    sdG = std(image(:, :, 2));
    sdB = std(image(:, :, 3));
    
    

    out = [sdR, sdG, sdB];
elseif c == 1
    out = std(image);
    
end

