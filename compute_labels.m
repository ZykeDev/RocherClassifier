function [] = compute_labels(im)
    gray = rgb2gray(im);
    
    t_size = 21;
    n_clusters = 2;
    
    disp("Computing local dexs...");
    lbpdex = compute_local_descriptors(gray, t_size, t_size, @compute_lbp);
    avgdex = compute_local_descriptors(im, t_size, t_size, @compute_average_color);
    
    dex.descriptors = [lbpdex.descriptors, avgdex.descriptors];
    dex.nt_rows = [lbpdex.nt_rows, avgdex.nt_rows];
    dex.nt_cols = [lbpdex.nt_cols, avgdex.nt_cols];

    disp("Done");
    
    labels = kmeans(dex.descriptors, n_clusters);

    img_labels = reshape(labels, lbpdex.nt_rows, lbpdex.nt_cols);
    img_labels = imresize(img_labels, t_size, 'nearest');
    
    % Binarize (1->0, 2->1)
    img_labels = img_labels - 1;
    
    subplot(211), imshow(gray);
    subplot(212), imagesc(img_labels), axis image;

end

