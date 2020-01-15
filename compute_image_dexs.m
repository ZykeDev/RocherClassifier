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
    bxt = [];       % Box Type
    grd = [];       % Boolean Grid of the rochers
    nos = [];       % Number Of Stickers
    rsh = [];       % List of rocher types
    srp = [];       % Stickers Relative Positions
       
    
    %% Compute the descriptors for every image
    for n = 14 : 14%nimages
        im = imread(['Dataset/' images{n}]);
        im = im2double(im);
        imshow(im); hold on;
        
        [r, c, ch] = size(im);
        disp(["Computing", n])
        thisNos = 0;
        thisSrp = [];

        %% Isolate the box (bxt)
        [maskedBox, box] = isolate_box(im);
        
        if box.type == "SQUARE"
            bxt = [bxt; 0];
        else
            bxt = [bxt; 1];
        end
        
        
        %% Find stickers (rsh)
        rows = find_stickers(maskedBox, box);
        
        %% Count the stickers (nos)
        for r = 1 : length(rows)
            if box.type == "RECT"
                thisrow = rows(r);
                thisNos = thisNos + thisrow.sn;
            elseif box.type == "SQUARE"
                
                
            end
        end
        
        thisRsh = find_rocher_types(maskedBox, box);
        
        
        %% Compute the sticker relative positions using rows       
        boxsrp = [];
        if box.type == "RECT"
            for r = 1 : length(rows)
                thisrow = rows(r);
                sc = thisrow.sc;

                rowsrp = compute_srp(maskedBox, sc, box);
                boxsrp = [boxsrp; rowsrp];
            end
        elseif box.type == "SQUARE"
            thisrow = rows(r);
            sc = thisrow.sc;
            boxsrp = compute_srp(maskedBox, sc, box);
        end
        
        thisSrp = [thisSrp; boxsrp];
        
        %% Compute the grid (grd)
        thisGrd = ones([4, 6]);
        
                
        
        %% Store the computed descriptors
        hold off;
        grd = [grd; reshape(thisGrd.', 1, [])]; 
        nos = [nos; thisNos]; 
        rsh = [rsh; reshape(thisRsh.', 1, [])];
        srp = [srp; reshape(thisSrp.', 1, [])];        
    end
    
    
    %% Save images, labels and descriptors
    save("data.mat", "images", "labels", "nos", "bxt", "grd", "rsh", "srp");
    disp("Descriptors Saved");

end


