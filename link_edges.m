function out = link_edges(E)
    [r, c] = size(E);
    thickEdges = imdilate(E, true(3));
    imshow(thickEdges, []);
    % Find the endpoints
    endPoints = bwmorph(E, 'endpoints');
    [endPointRows, endPointColumns] = find(endPoints);
    numberOfEndpoints = length(endPointRows);
    
    % Define the longest distance that we are willing to jump/close.
    longestGapToClose = ceil(0.3 * r);
    
    % Label the image.  Gives each separate segment a unique ID label number.
    [labeledImage, ~] = bwlabel(E);
    % Get the label numbers (segment numbers) of every endpoint.
    for k = 1 : numberOfEndpoints
        thisRow = endPointRows(k);
        thisColumn = endPointColumns(k);
        % Get the label number of this segment
        theLabels(k) = labeledImage(thisRow, thisColumn);
    end
    
    % For each endpoint, find the closest other endpoint that is not
    % in the same segment
    for k = 1 : numberOfEndpoints
        thisRow = endPointRows(k);
        thisColumn = endPointColumns(k);
        % Get the label number of this segment
        thisLabel = theLabels(k);
        % Get indexes of the other end points.
        otherEndpointIndexes = setdiff(1:numberOfEndpoints, k);
        % TODO check this belows
        % Consider joining only end points that reside on different segments
        % then we need to remove the end points on the same segment from the "other" list.
        % Get the label numbers of the other end points.
        otherLabels = theLabels(otherEndpointIndexes);
        onSameSegment = (otherLabels == thisLabel); % List of what segments are the same as this segment
        otherEndpointIndexes(onSameSegment) = []; % Remove if on the same segment


        % Now get a list of only those end points that are on a different segment.
        otherCols = endPointColumns(otherEndpointIndexes);
        otherRows = endPointRows(otherEndpointIndexes);

        % Compute distances
        distances = sqrt((thisColumn - otherCols).^2 + (thisRow - otherRows).^2);
        % Find the min
        [minDistance, indexOfMin] = min(distances);
        nearestX = otherCols(indexOfMin);
        nearestY = otherRows(indexOfMin);
        if minDistance < longestGapToClose
            % Draw line from this endpoint to the other endpoint.
            line([thisColumn, nearestX], [thisRow, nearestY], 'Color', 'g', 'LineWidth', 1);
            
        end
    end
end

