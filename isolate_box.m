function [maskedBox, box] = isolate_box(im)
%ISOLATE_BOX Isolates the box and returns the masked image


    %% Set default box data
    maskedBox = im;
    
    [r, c, ch] = size(im);
    box.originalSize = [r, c];
    box.type = "SQUARE";
    box.expectedNumber = 24;

    %% Preprocess the image
    gray = rgb2gray(im);
    im = imgaussfilt(im, 0.5);

    %% Correct Nonuniform Illumination
    se = strel('disk', 80); % TODO eval SE size
    bg = imopen(gray, se);
    new = im - bg .* 2;
    
    % Use cc labeling to detect the box
    img_labels = compute_labels(new);
    masked = clean_labels(img_labels);
    masked = padarray(masked, [8, 6]); % TODO fix numbers
    masked = masked(2:end, :);

    %% Mask the original using the BW image
    imgmask = bsxfun(@times, new, cast(masked, 'like', new));   
    graymask = rgb2gray(imgmask);
    
    
    %% Detect box type (square or rect)
    bwo = imbinarize(graymask, 0.000001);
    bw = imerode(bwo, strel('disk', 15));
    bw = imdilate(bw, strel('disk', 25)); % TODO eval constants
    bw = imerode(bw, strel('disk', 29));
    bw = imdilate(bw, strel('disk', 47));
        
    % Compute regions data, only use the one with the largest area
    stats = regionprops(bw, "Area", "Centroid", "MajorAxisLength", "MinorAxisLength", "Orientation", "Extrema", "FilledImage");
    region = largestAreaRegion(stats);
   
    box.majax = region.MajorAxisLength;
    box.minax = region.MinorAxisLength;

    if box.majax < box.minax * 1.2          % 1.2 ratio has 93.75% accuracy
        box.type = "SQUARE";
    else
        box.type = "RECT";
    end
    
    box.center = region.Centroid;
    box.orientation = region.Orientation;
    box.majax = box.majax * 0.95; % TODO fix reduction
    box.minax = box.minax;

    boxSides = region.Extrema(4, :) - region.Extrema(6, :);
    box.angle = rad2deg(atan(-boxSides(2) / boxSides(1))) ; % The - sign compensates for the inverted y-values
    
    if box.type == "SQUARE"
        avgax = (box.minax + box.majax) / 2;
        d1x = box.center(1) + [-1, 1] * avgax * sqrt(2) * cosd(-box.angle + 45)/2; % TODO check angle vs orientation
        d1y = box.center(2) + [-1, 1] * avgax * sqrt(2) * sind(-box.angle + 45)/2;
        d2x = box.center(1) + [-1, 1] * avgax * sqrt(2) * cosd(-box.angle - 45)/2;
        d2y = box.center(2) + [-1, 1] * avgax * sqrt(2) * sind(-box.angle - 45)/2;

        xi = [d1x(1), d2x(1), d1x(2), d2x(2)];
        yi = [d1y(1), d2y(1), d1y(2), d2y(2)];
        
    elseif box.type == "RECT"       
        a = box.majax/2;
        b = box.minax/2;
        
        A = [box.center(1)-a, box.center(2)-b];
        B = [box.center(1)+a, box.center(2)-b];
        C = [box.center(1)+a, box.center(2)+b];
        D = [box.center(1)-a, box.center(2)+b];

        points = rotatePoints([A; B; C; D], box.center, box.orientation);
        
        xi = points(:, 1);
        yi = points(:, 2);
    end
    
    % Mask the image with a box polygon
    boxmask = poly2mask(xi, yi, r, c);
    maskedBox = maskRGB(im, boxmask);    

end

%% Returns the region with the largets area
function region = largestAreaRegion(stats)
    maxarea = 0;
    maxindex = 1;
    for i = 1 : size(stats)
        thisarea = stats(i).Area;
        if thisarea > maxarea
            maxarea = thisarea;
            maxindex = i;
        end
    end

    region = stats(maxindex);
end


%% Masks every RGB channel with a mask and returns the concatenated img     
function masked = maskRGB(img, mask)
    R = img(:, :, 1);
    G = img(:, :, 2);
    B = img(:, :, 3);

    R(~mask) = 0;
    G(~mask) = 0;
    B(~mask) = 0;
    
    masked = cat(3, R, G, B);

end

%% Applies a rotation matrix with angle theta to a set of points
function points = rotatePoints(points, center, theta)    
    Xc = center(1);
    Yc = center(2);
    Xrot =  (points(:, 1)-Xc)*cosd(theta) + (points(:, 2)-Yc)*sind(theta) + Xc;
    Yrot = -(points(:, 1)-Xc)*sind(theta) + (points(:, 2)-Yc)*cosd(theta) + Yc;
    points(:, 1) = Xrot;
    points(:, 2) = Yrot;
    
end