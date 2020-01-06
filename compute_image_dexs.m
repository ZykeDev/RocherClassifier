function [] = compute_image_dexs()
%COMPUTE_IMAGE_DEXS

    % Read the image names and respective labels from the 2 .list files
    f = fopen('images.list');
    z = textscan(f, '%s');
    fclose(f);
    images = z{:}; 

    f = fopen('labels.list');
    l = textscan(f, '%s');
    labels = l{:};
    fclose(f);

    % Get the number of images
    nimages = numel(images);

    [im, map] = imread(['Dataset/' images{2}]);
    im = im2double(im);
    [r, c, ch] = size(im);
    
    % Preprocessing TODO
    gray = rgb2gray(im);
    im = imgaussfilt(im, 0.5);
    
    
    % Correct Nonuniform Illumination
    se = strel('disk', 80); % TODO eval size
    bg = imopen(gray, se);
    new = im - bg .* 2;
    
    img_labels = compute_labels(new);
    masked = clean_labels(img_labels);
    masked = padarray(masked, [8, 6]); % TODO fix
    masked = masked(2:end, :);
    
    % Mask the original using the BW image
    maskedImg = bsxfun(@times, new, cast(masked, 'like', new));   
    
    
    equalized = histeq(maskedImg);
    
    % Compute the edge using Canny's method
    minT = 0.1;
    maxT = 0.4;
    E = edge(rgb2gray(equalized), "Canny", [minT, maxT]);
    imshow(E);
    
    
    
    
    
    
    %E = imclose(E, strel("disk", 4));
    %E = bwmorph(E, 'skel', 4);
    %imshow(E);
    % Compute the dexs for the number of Stickers
   
    %L = bwlabel(E);
    % Prune small CCs
    %for k = 1 : 2781
    %    n = numel(L(L == k));
    %    if n < 80
    %        L(L == k) = 0;
    %    end
    %end
    %imshow(L);
    
    %[sn, spos] = compute_stickers(E);
    
    %disp(sn);
    %disp(spos);
    
    
    % For every image, compute a set of descriptors
    %bw = imbinarize(im, 'adaptive', 'ForegroundPolarity', 'bright', 'Sensitivity', 0.5);
    %disp("Computing Descriptors...");
    %lbp = [];
    %for n = 1 : nimages
        %im = imread(['Dataset/' images{n}]);
        %lbp = [lbp; compute_lbp(im)];
    %end

    % Save images and descriptors
    %save("data.mat", "images", "labels", "lbp");
    %disp("Descriptors Saved");

end

