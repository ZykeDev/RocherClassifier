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
% We can also use the relative positions of the stickers,assuming they are
% on a grid.

% Ideally we'd like to memorize the coordinates of each rocher, but they
% are not needed in the classification, only in the error location.


% Descriptors are therefore:
% bxt   box type (0 = SQUARE or 1 = RECT)
% nos   number of stickers
% rsh   rochers types (list of CLASSIC = 0, WHITE = 1, BLACK = 2)
% srp   stickers relative positions
% grd   Boolean matrix of the grid (1 = has a rocher, 0 = doesnt)

% Error Localization (only for images that have been labeled as "no")
% If in a row, the srd between 2 consecutive stickers is > majax/6, then
% there's a missing element in between. TODO use majax/6 as step (>1 holes)
% The result is a matrix where 1 = ok, 0 = miss, then a plotted grid.

% Load the results
load("data.mat");

% Create the Cross-validation data partiton (80/20)
cvp = cvpartition(labels, 'Holdout', 0.2);

% Test this classifier
out = test_classifier([bxt, grd, nos, rsh, srp], labels, cvp);

% Display the results
disp(out.test_perf.accuracy);
disp(out.test_perf.cm);








