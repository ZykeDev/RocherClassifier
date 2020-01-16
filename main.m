% Main script
close all;
clear all;
clc;

% Comput the descriptors for all images
if ~exist('data.mat', 'file')
    compute_image_dexs();
end

% Descriptors:
% bxt   box type (0 = SQUARE or 1 = RECT)
% nos   number of stickers found
% rsh   rochers types (list of CLASSIC = 0, WHITE = 1, BLACK = 2)
% srp   stickers relative positions

% Load the results
load("data.mat");

% Create the Cross-validation data partiton (80/20)
cvp = cvpartition(labels, 'Holdout', 0.2);

% Test this classifier
out = test_classifier([bxt, nos, rsh, srp], labels, cvp);

% Display the results
disp(out.test_perf.accuracy);
disp(out.test_perf.cm);








