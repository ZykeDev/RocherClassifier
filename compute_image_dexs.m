function out = compute_image_dexs()
%COMPUTE_IMAGE_DEXS Summary of this function goes here
%   Detailed explanation goes here

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

im = im2double(imread(['Dataset/' images{32}]));
gray = rgb2gray(im);
im = medfilt3(im);

% Correct Nonuniform Illumination
se = strel('disk', 100); % TODO check thresh
bg = imopen(gray, se);
new = im - bg;

subplot(211), imshow(im);
subplot(212), imshow(new);



%bw = imbinarize(im, 'adaptive', 'ForegroundPolarity', 'bright', 'Sensitivity', 0.5);
compute_labels(new);






% (Not ran for now)
% For every image, compute a set of descriptors
disp("Computing Descriptors...");
lbp = [];
for n = 1 : nimages
    %im = imread(['Dataset/' images{n}]);
    %lbp = [lbp; compute_lbp(im)];
end

% Save images and descriptors
save("data.mat", "images", "labels", "lbp");
disp("Descriptors Saved");

out = 0;
end

