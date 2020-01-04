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

    im = im2double(imread(['Dataset/' images{1}]));
    gray = rgb2gray(im);
    im = medfilt3(im);

    % Correct Nonuniform Illumination
    se = strel('disk', 100); % TODO eval size
    bg = imopen(gray, se);
    new = im - bg .* 2;

    img_labels = compute_labels(new);
    cleaned = clean_labels(img_labels);

    subplot(211), imshow(new);
    subplot(212), imshow(cleaned);





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

