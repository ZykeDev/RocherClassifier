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
    
    gridRect   = zeros([4, 6]);
    gridSquare = []; % TODO
    
    
    
    %% Compute the descriptors for every image
    for n = 1 : nimages
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        [r, c, ch] = size(im);
        disp(["Computing", n])
        thisNos = 0;
        thisSrp = [];

        %% Isolate the box (bxt)
        [maskedBox, box] = isolate_box(im);
        %imshow(maskedBox); hold on;
        %scatter(box.center(1), box.center(2));
        
        %% Project grid on top of the box
        % grid = build_grid(box);
        % proj = proj_grid(box, grid);
        % maybe use squareLength as diameter for maxRadius of circles?
        % maybe not even needed if we are no longer using circles.

        %% Find stickers (rsh)
        rows = find_stickers(maskedBox, box);
        
        %% Count the stickers (nos)
        for r = 1 : length(rows)
            thisrow = rows(r);
            thisNos = thisNos + thisrow.sn;
        end
        
        thisRsh = find_rocher_types(maskedBox, box);
        
        
        %% Compute the sticker relative positions using rows
        %imshow(maskedBox); hold on;
        
        boxsrp = [];
        for r = 1 : length(rows)
            thisrow = rows(r);
            sn = thisrow.sn;
            sc = thisrow.sc;
             
            %for p = 1 : sn
                %scatter(sc(p, 1), sc(p, 2));
            %end
            
            rowsrp = compute_srp(maskedBox, sc, box);
            boxsrp = [boxsrp; rowsrp];
        end
        
        thisSrp = [thisSrp; boxsrp];
        
        %% Compute the grid (grd)
        
        thisGrd = ones([4, 6]);
        
        %% Store the computed descriptors
        hold off;
        lbp = [lbp; compute_lbp(im)];
        grd = [grd; reshape(thisGrd.', 1, [])]; 
        nos = [nos; thisNos]; 
        rsh = [rsh; reshape(thisRsh.', 1, [])];
        srp = [srp; reshape(thisSrp.', 1, [])];
                
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
    save("data.mat", "images", "labels", "lbp", "nos", "bxt", "grd", "rsh", "srp");
    disp("Descriptors Saved");

end


