function [number, centers, radii] = find_rochers(im, box)
%FIND_ROCHERS Summary of this function goes here

    radiusDifference = 0.75;
    
    %% Find the circles around the rochers
    if box.type == "SQUARE"    
        maxRadius = ceil(box.majax / box.expectedNumber * 2); 
        minRadius = floor(maxRadius * radiusDifference);

    elseif box.type == "RECT"
        maxRadius = ceil(box.majax / box.expectedNumber * 2);  
        minRadius = floor(maxRadius * radiusDifference);
    end
    
    sensitivity = 0.97;
    [centers, radii] = imfindcircles(im, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
    
    if isempty(centers)
        centers = [];
        radii = [];
        number = 0;
        return
    end
    
    %% Remove overlapping circles
    rocheOverlapFactor = 0.15;
    [centers, radii] = remove_overlaps(centers, radii, rocheOverlapFactor, box);
    number = length(radii);
end

