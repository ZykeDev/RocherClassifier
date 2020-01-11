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
    
    %% Compute the descriptors for every image
    for n = 63 : nimages
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        [r, c, ch] = size(im);
        
        %% Set default box data
        box.originalSize = [r, c];
        box.type = "SQUARE";
        box.expectedNumber = 24;

        %% Preprocessing TODO
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
        bw = imbinarize(graymask, 0.000001);
        bw = imerode(bw, strel('disk', 15));
        bw = imdilate(bw, strel('square', 27)); % TODO eval constants

        % Compute regions data, only use the one with the largest area
        stats = regionprops(bw, "Area", "Centroid", "MajorAxisLength", "MinorAxisLength", "Orientation", "Extrema", "FilledImage");

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
        
        % Draw the main axes
        xMajax = box.center(1) + [-1, 1] * majax * cosd(-box.angle)/2;
        yMajax = box.center(2) + [-1, 1] * majax * sind(-box.angle)/2;
        xMinax = box.center(1) + [-1, 1] * minax * sind(box.angle)/2;
        yMinax = box.center(2) + [-1, 1] * minax * cosd(box.angle)/2;
       
        
        %% Project grid on top of the box
        %grid = proj_grid(box);
        
        % maybe use squareLength as diameter for maxRadius of circles?
        % maybe not even needed if we are no longer using circles.

        %% Find stickers
        [stickerN, stickerC, stickerR] = find_stickers(imgmask, box);
        
        imshow(imgmask); hold on;

        if isempty(stickerC)
            disp("No stickers found");
            box.stickers.number = stickerN;
        else
            h = viscircles(stickerC, stickerR, 'Color', 'b');
            box.stickers.number = stickerN;
            box.stickers.centers = stickerC;
            box.stickers.radii = stickerR;
        end
        
        
        grid = build_grid(box);
        proj = proj_grid(box, grid);
        
        
        return
        %% Find the rochers
        [rocherN, rocherC, rocherR] = find_rochers(imgmask, box); 
        if isempty(rocherC) 
            disp("No rochers found");
        else
            h = viscircles(rocherC, rocherR, 'Color', 'r'); hold on;
            box.rochers.number = rocherN;
            box.rochers.centers = rocherC;
            box.rochers.radii = rocherR;
        end
        
        
       
        
        %% Remove circles without a sticker inside
        
        
        
        return
        
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

    %% For every image, compute a set of descriptors
    %disp("Computing Descriptors...");
    %lbp = [];
    %for n = 1 : nimages
        %lbp = [lbp; compute_lbp(im)];
        %box.type
        %number of (valid) rochers (not missing/unlabled)
    %end

    % Save images, labels and descriptors
    %save("data.mat", "images", "labels", "lbp");
    %disp("Descriptors Saved");

        
        
