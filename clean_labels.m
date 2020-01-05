function out = clean_labels(img_labels)
%CLEAN_LABELS
    se = strel('disk', 23); % t_size + 2
    out = imclose(img_labels, se);
    
    se = strel('disk', 56); % double of the closing se (23*2)
    out = imdilate(out, se);
        
    % TODO remove elements out of the box?

end

