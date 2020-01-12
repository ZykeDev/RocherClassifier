function [] = compute_image_dexs()
%COMPUTE_IMAGE_DEXS
    close all;
    clear all;
       
    %% Read the image names and respective labels from the 2 .list files
    f = fopen('images.list');
    z = textscan(f, '%s');
    fclose(f);
    images = z{:}; 

    f = fopen('labels.list');
    l = textscan(f, '%s');
    labels = l{:};
    fclose(f);
    nimages = numel(images);
    
    % Descriptors lists
    lbp = [];       % LBP
    nos = [];       % Number Of Stickers
    bxt = [];       % Box Type
    
    %% Compute the descriptors for every image
    for n = 1 : nimages
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        [r, c, ch] = size(im);
        disp(["Computing", n]);

        
        %% Set default box data
        box.originalSize = [r, c];
        box.type = "SQUARE";
        box.expectedNumber = 24;

        %% Preprocessing
        gray = rgb2gray(im);
        im = imgaussfilt(im, 0.5);

        %% Correct Nonuniform Illumination
        se = strel('disk', 80); % TODO eval se size
        bg = imopen(gray, se);
        new = im - bg .* 2;

        img_labels = compute_labels(new);
        masked = clean_labels(img_labels);
        masked = padarray(masked, [8, 6]); % TODO fix numbers
        masked = masked(2:end, :);

        % Mask the original using the BW image
        imgmask = bsxfun(@times, new, cast(masked, 'like', new));   
        graymask = rgb2gray(imgmask);
        
        %% Detect box type (square or rect)
        bwo = imbinarize(graymask, 0.000001);
        bw = imerode(bwo, strel('disk', 15));
        bw = imdilate(bw, strel('disk', 25)); % TODO eval constants
        bw = imerode(bw, strel('disk', 29));
        bw = imdilate(bw, strel('disk', 47));
        %bw = imclose(bw, strel('disk', 21));

        % Compute regions data, only use the one with the largest area
        stats = regionprops(bw, "Area", "Centroid", "MajorAxisLength", "MinorAxisLength", "Orientation", "Extrema", "FilledImage", "BoundingBox");
        region = largestAreaRegion(stats);
        
        
        majax = region.MajorAxisLength;
        minax = region.MinorAxisLength;
        
        % Save ONLY the cleaned area of the box. Might be useful later. 
        box.region = region.FilledImage;
        
        if majax < minax * 1.2              % 1.2 ratio has 93.75% accuracy
            box.type = "SQUARE";
        else
            box.type = "RECT";
        end
        
        
        
        box.center = region.Centroid;
        box.orientation = region.Orientation;
        box.majax = majax;
        box.minax = minax;
               
        boxSides = region.Extrema(4, :) - region.Extrema(6, :);
        box.angle = rad2deg(atan(-boxSides(2) / boxSides(1))) ; % The - sign compensates for the inverted y-values
        
        % Draw the main axes (unused)
        xMajax = box.center(1) + [-1, 1] * minax * cosd(-box.angle)/2;
        yMajax = box.center(2) + [-1, 1] * minax * sind(-box.angle)/2;
        xMinax = box.center(1) + [-1, 1] * minax * sind(box.angle)/2;
        yMinax = box.center(2) + [-1, 1] * minax * cosd(box.angle)/2;
       
        % TODO mod for RECT boxes
        avgax = (minax+majax)/2;
        d1x = box.center(1) + [-1, 1] * avgax * sqrt(2) * cosd(-box.angle+45)/2;
        d1y = box.center(2) + [-1, 1] * avgax * sqrt(2) * sind(-box.angle+45)/2;
        d2x = box.center(1) + [-1, 1] * avgax * sqrt(2) * cosd(-box.angle-45)/2;
        d2y = box.center(2) + [-1, 1] * avgax * sqrt(2) * sind(-box.angle-45)/2;
       
        xi = [d1x(1), d2x(1), d1x(2), d2x(2)];
        yi = [d1y(1), d2y(1), d1y(2), d2y(2)];
        
        % Mask the image with a box polygon
        boxmask = poly2mask(xi, yi, r, c);
        
        maskedBox = maskRGB(im, boxmask);             
        
        
        %% Project grid on top of the box
        % grid = build_grid(box);
        % proj = proj_grid(box, grid);
        % maybe use squareLength as diameter for maxRadius of circles?
        % maybe not even needed if we are no longer using circles.

        %% Find stickers
        [stickerN, stickerC, stickerR] = find_stickers(maskedBox, box);
          
        if isempty(stickerC)
            box.stickers.number = stickerN;
            box.stickers.centers = [];
            box.stickers.radii = [];
        else
            %h = viscircles(stickerC, stickerR, 'Color', 'b');
            box.stickers.number = stickerN;
            box.stickers.centers = stickerC;
            box.stickers.radii = stickerR;
        end
        
        
    
        %% Find the rochers
        [rocherN, rocherC, rocherR] = find_rochers(maskedBox, box); 
        if isempty(rocherC) 
            disp("No rochers found");
        else
            %h = viscircles(rocherC, rocherR, 'Color', 'r'); hold on;
            box.rochers.number = rocherN;
            box.rochers.centers = rocherC;
            box.rochers.radii = rocherR;
        end
        
        

        
        %% Remove circles without a sticker inside
        
        
        %% Store the computed descriptors
        hold off;
        lbp = [lbp; compute_lbp(im)];
        nos = [nos; box.stickers.number];
        
        if box.type == "SQUARE"
            bxt = [bxt; 0];
        else
            bxt = [bxt; 1];
        end
                
        
    end
    
    %E = edge(graymask, 'canny', [.2,.55]);

    %E = imclose(E, strel("disk", 4));
    %E = bwmorph(E, 'skel', 4);
    %imshow(E);
    % Compute the dexs for the number of Stickers

    %L = bwlabel(E);
    % Prune small CCs
    %for k = 1 : 2781
    %    n = numel(L(L == k));
    %    if n < 80
    %        L(L == k) = 0;
    %    end
    %end
    %imshow(L);

    %[sn, spos] = compute_stickers(E);

    
    %% Save images, labels and descriptors
    save("data.mat", "images", "labels", "lbp", "nos", "boxtype");
    disp("Descriptors Saved");

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