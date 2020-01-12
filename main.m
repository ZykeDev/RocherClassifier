% Main script
close all;
clear all;
clc;

% Comput the descriptors for all images (only once)
compute_image_dexs();

% What descriptors do i need?
% depending on the box we have different data, so describe it 
% need to find if a box has all 24 rochers, so number of rochers
% need to find all 24 sticekrs, so number of stickers
% I assume there is no sticker without rocher, so just the stickers number is necessary.
% We also have 3 types of rocher, so save them as well as a list (ideally 24 elements)

% Ideally we'd like to memorize the coordinates of each rocher, but they
% are not needed in the classification, only in the error location.


% Descriptors at therefore:
% bxt   box type (0 = SQUARE or 1 = RECT)
% nos   number of stickers
% rsh   rochers types (list of CLASSIC = 0, WHITE = 1, BLACK = 2)




% Load the results
load("data.mat");

% Create the Cross-validation data partiton (80/20)
cvp = cvpartition(labels, 'Holdout', 0.2);

% Test this classifier
out = test_classifier([bxt, nos, rsh], labels, cvp);

% Display the results
disp(out.test_perf.accuracy);
disp(out.test_perf.cm);








