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
    
    for n = 1 : nimages
        %% Get the image data
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        [r, c, ch] = size(im);
        box.type = "SQUARE";

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
        maskedImg = bsxfun(@times, new, cast(masked, 'like', new));   
        equalized = histeq(maskedImg);

        %% Detect box type (square or rect)
        bw = imbinarize(rgb2gray(maskedImg), 0.000001);
        bw = imerode(bw, strel('disk', 15));
        bw = imdilate(bw, strel('square', 27)); % TODO eval constants

        % Compute regions data, only use the one with the largest area
        stats = regionprops(bw, "Area", "Centroid", "MajorAxisLength", "MinorAxisLength", "Orientation");

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
        centroid = region.Centroid;         % TODO remove if not needed
        majax = region.MajorAxisLength;
        minax = region.MinorAxisLength;
        orientation = region.Orientation;   % TODO remove if not needed

        if majax < minax * 1.2 % TODO square/rect ratio?
            box.type = "SQUARE";
        else
            box.type = "RECT";
        end
        disp(n);
        disp(box.type);

        % Draw the box axes
        xMajax = centroid(1) + [-1, 1] * majax * cosd(-orientation)/2;
        yMajax = centroid(2) + [-1, 1] * majax * sind(-orientation)/2;
        xMinax = centroid(1) + [-1, 1] * minax * sind(orientation)/2;
        yMinax = centroid(2) + [-1, 1] * minax * cosd(orientation)/2;

        %imshow(bw); hold on; 
        %plot(centroid(1), centroid(2), 'b*');
        %line(xMajax, yMajax, 'Linewidth', 4);
        %line(xMinax, yMinax, 'Linewidth', 4);
        %hold off;


        %% Find the circles round the rochers
        % TODO change circle range to the ratio of box-length/number of rochers
        minRadius = 60;
        maxRadius = 87;
        sensitivity = 0.97;
        [centers, radii] = imfindcircles(maskedImg, [minRadius, maxRadius], 'ObjectPolarity', 'bright', 'Sensitivity', sensitivity, 'Method', 'twostage');
        oc = centers;
        or = radii;

        %% Remove overlapping circles   
        for i = 1 : length(centers) - 1
            s = i + 1;
            for j = s : length(centers)
                tolerance = (radii(i) + radii(j)) / 2;
                cdist = sqrt((centers(i,1) - centers(j,1)) .^2 + (centers(i,2) - centers(j,2)) .^2);
                rdist = radii(i) + radii(j) - tolerance;

                if cdist < rdist && radii(j) > 0
                    if radii(i) > radii(j)
                        centers(j, 1) = 0;
                        centers(j, 2) = 0;
                        radii(j) = 0;
                    else
                        centers(i, 1) = 0;
                        centers(i, 2) = 0;
                        radii(i) = 0;
                        break;
                    end
                end
            end
        end    

        cx = centers(:, 1);
        cy = centers(:, 2);

        cx(cx == 0) = [];
        cy(cy == 0) = [];
        centers = [cx, cy];
        radii(radii == 0) = [];

        imshow(im);
        h = viscircles(centers, radii);
        
        
        %% Find stickers
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
        
        
        %% Remove circles without a sticker inside
        
        
 
        
    end
    
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

        
        
