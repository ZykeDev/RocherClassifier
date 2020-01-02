function out = compute_lbp(im)
%COMPUTE_DEX Computes the LBP of an image.
    [w, h, c] = size(im);
    if c == 3
        im = rgb2gray(im);
    end

	out = extractLBPFeatures(im, 'NumNeighbors', 8, 'Radius', 1, 'Upright', true);
end

