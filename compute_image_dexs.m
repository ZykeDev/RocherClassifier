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
    lbp = [];       % LBP (unused)
    bxt = [];       % Box Type
    grd = [];       % Boolean Grid of the rochers
    nos = [];       % Number Of Stickers
    rsh = [];       % List of rocher types
    srp = [];       % Stickers Relative Positions
    
    
    
    %% Compute the descriptors for every image
    for n = 39 : nimages
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        [r, c, ch] = size(im);
        disp(["Computing", n]);
        thisNos = 0;
        thisRsh = [];
        
        %% Isolate the box
        [maskedBox, box] = isolate_box(im);
        %imshow(maskedBox); hold on;
        %scatter(box.center(1), box.center(2));
        
        %% Project grid on top of the box
        % grid = build_grid(box);
        % proj = proj_grid(box, grid);
        % maybe use squareLength as diameter for maxRadius of circles?
        % maybe not even needed if we are no longer using circles.

        %% Find stickers
        rows = find_stickers(maskedBox, box);
        
        % Update the nos dex
        for r = 1 : length(rows)
            thisrow = rows(r);
            thisNos = thisNos + thisrow.sn;
        end
        
        thisRsh = find_rocher_types(maskedBox, box);
      
        %% Find the rochers
        %[rocherN, rocherC, rocherR] = find_rochers(maskedBox, box); 
        %if isempty(rocherC) 
        %    disp("No rochers found");
        %else
         %   %h = viscircles(rocherC, rocherR, 'Color', 'r'); hold on;
         %   box.rochers.number = rocherN;
        %    box.rochers.centers = rocherC;
        %    box.rochers.radii = rocherR;
        %end
        
        

        
        
        %% Store the computed descriptors
        hold off;
        lbp = [lbp; compute_lbp(im)];
        nos = [nos; thisNos];
        rsh = [rsh; thisRsh];
        
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


