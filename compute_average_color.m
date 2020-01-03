function avg = compute_average_color(image)
%COMPUTE_AVERAGE_COLOR Calculates the average RGB color of an image
[h, w, c] = size(image);

if c == 3
    mR = mean(mean(image(:, :, 1)));
    mG = mean(mean(image(:, :, 2)));
    mB = mean(mean(image(:, :, 3)));

    avg = [mR, mG, mB];
elseif c == 1
    avg = mean(mean(image));

end

