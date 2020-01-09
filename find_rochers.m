function [centers, radii] = find_rochers(im)
%FIND_ROCHERS Summary of this function goes here
    
    %% Find the circles around the rochers
    % TODO change circle range to the ratio of box-length/number of rochers
    minRadius = 60;
    maxRadius = 87;
    sensitivity = 0.97;
    [centers, radii] = imfindcircles(im, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
    oc = centers;   % Original centers
    or = radii;     % Original radii

    %% Remove overlapping circles
    rocheOverlapFactor = 0.3;
    [centers, radii] = remove_overlaps(centers, radii, rocheOverlapFactor);    
end

