function [img_labels] = compute_labels(im)
% COMPUTE_LABELS Segments an image using weighted LBP and AVG.
    gray = rgb2gray(im);
    
    t_size = 21;
    n_clusters = 2;
    lbp_weigth = 1;
    avg_weight = 1.1;
    
    %disp("Computing local dexs...");
    lbpdex = compute_local_descriptors(gray, t_size, t_size, @compute_lbp);
    avgdex = compute_local_descriptors(im, t_size, t_size, @compute_average_color);
    
    dex.descriptors = [lbpdex.descriptors .* lbp_weigth, avgdex.descriptors .* avg_weight];
    dex.nt_rows = [lbpdex.nt_rows, avgdex.nt_rows];
    dex.nt_cols = [lbpdex.nt_cols, avgdex.nt_cols];
    %disp("Done");
    
    % Creates the labels using kmeans
    labels = kmeans(dex.descriptors, n_clusters);

    img_labels = reshape(labels, lbpdex.nt_rows, lbpdex.nt_cols);
    img_labels = imresize(img_labels, t_size, 'nearest');
    
    % Make logical (1->0, 2->1)
    img_labels = img_labels - 1;
    
    % TODO make the bg always 0 and the object always 1
    if img_labels(1, 1) == 1
        img_labels = not(img_labels);
    end
    
end

