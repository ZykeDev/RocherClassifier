function [out] = clean_labels(img_labels)
%CLEAN_LABELS
    se = strel('disk', 21);
    out = imclose(img_labels, se);
    
    %se = strel('disk', 29);
    %out = imopen(out, se);
end

