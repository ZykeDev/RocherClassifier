function out = clean_labels(img_labels)
%CLEAN_LABELS
    se = strel('disk', 23); % t_size + 2
    out = imclose(img_labels, se);
    
    se = strel('disk', 23*2);
    out = imdilate(out, se);

end

