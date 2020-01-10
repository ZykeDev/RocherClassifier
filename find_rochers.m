function [centers, radii] = find_rochers(im, box)
%FIND_ROCHERS Summary of this function goes here
    
    %% Find the circles around the rochers
    if box.type == "SQUARE"    
        maxRadius = ceil(box.majax / (box.numberOfRochers / 2)); 
        minRadius = floor(maxRadius * 0.75);

    elseif box.type == "RECT"
        maxRadius = ceil(box.majax / (box.numberOfRochers / 2));  
        minRadius = floor(maxRadius * 0.75);
    end
    
    sensitivity = 0.97;

    [centers, radii] = imfindcircles(im, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
    oc = centers;   % Original centers
    or = radii;     % Original radii
    
    %% Remove overlapping circles
    if ~isempty(centers)
        rocheOverlapFactor = 0.25;
        [centers, radii] = remove_overlaps(centers, radii, rocheOverlapFactor);    
    end
    
end

