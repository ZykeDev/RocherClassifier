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

% For every image, compute a set of descriptors
lbp = [];
for n = 1 : nimages
    im = imread(['Dataset/' images{n}]);
    lbp = [lbp; compute_lbp(im)];
end

% Save images and descriptors
save("data.mat", "images", "labels", "lbp");
