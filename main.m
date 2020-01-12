% Main script
close all;
clear all;
clc;

% Comput the descriptors for all images (only once)
%compute_image_dexs();

% Load the results
load("data.mat");

% Create the Cross-validation data partiton (80/20)
cvp = cvpartition(labels, 'Holdout', 0.2);

% Test this classifier
out = test_classifier([lbp, nos, bxt], labels, cvp);

% Display the results
disp(out.test_perf.accuracy);
disp(out.test_perf.cm);








