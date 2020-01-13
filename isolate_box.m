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
        box.grid = zeros([12, 2]);          % Boolean grid (has/nt rocher)
    else
        box.type = "RECT";
        box.grid = zeros([6,4]);
    end
    
    box.center = region.Centroid;
    box.orientation = region.Orientation;
    box.majax = box.majax * 0.95; % TODO fix reduction
    box.minax = box.minax * 0.95;

    boxSides = region.Extrema(4, :) - region.Extrema(6, :);
    box.angle = rad2deg(atan(-boxSides(2) / boxSides(1))) ; % The - sign compensates for the inverted y-values
    
    if box.type == "SQUARE"
        a = box.majax / 2;
        b = a;
    elseif box.type == "RECT"       
        a = box.majax/2;
        b = box.minax/2;
    end
    
    A = [box.center(1)-a, box.center(2)-b];
    B = [box.center(1)+a, box.center(2)-b];
    C = [box.center(1)+a, box.center(2)+b];
    D = [box.center(1)-a, box.center(2)+b];
    
    % Calculate the midway points for the RECT grid (6x4)
    A1 = [box.center(1)-a, box.center(2)-b/2];
    B1 = [box.center(1)+a, box.center(2)-b/2];
    Amid = [box.center(1)-a, box.center(2)];
    Bmid = [box.center(1)+a, box.center(2)];
    C1 = [box.center(1)-a, box.center(2)+b/2];
    D1 = [box.center(1)+a, box.center(2)+b/2];
    
    % Rotate the box corners
    points = rotatePoints([A; B; C; D], box.center, box.orientation);
    
    % Rotate the grdid corners
    grid1 = rotatePoints([A; B; B1; A1], box.center, box.orientation);
    grid2 = rotatePoints([A1; B1; Bmid; Amid], box.center, box.orientation);
    grid3 = rotatePoints([Amid; Bmid; D1; C1], box.center, box.orientation);
    grid4 = rotatePoints([C1; D1; C; D], box.center, box.orientation);
    
    box.grid = [grid1; grid2; grid3; grid4];

    xi = points(:, 1);
    yi = points(:, 2);
        
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
