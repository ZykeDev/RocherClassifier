function masked = maskRGB(img, mask)
    R = img(:, :, 1);
    G = img(:, :, 2);
    B = img(:, :, 3);

    R(~mask) = 0;
    G(~mask) = 0;
    B(~mask) = 0;
    
    masked = cat(3, R, G, B);
end