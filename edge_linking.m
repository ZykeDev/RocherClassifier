


edgeImage = edge(grayImage, 'canny', [.2,.55]);

% Sometimes due to shrinking the image for display, breaks will appear in the display
% that are not realy there - caused by subsampling.  Let's dilate the edge image just for
% display, but not for finding endpoints.
thickenedEdges = imdilate(edgeImage, true(3));

% Display the original gray scale image.
subplot(2, 2, 2);
imshow(thickenedEdges, []);
axis on;
title('Edge Image', 'FontSize', fontSize, 'Interpreter', 'None');

% Find the endpoints
endPoints = bwmorph(edgeImage, 'endpoints');
subplot(2, 2, 3);
imshow(thickenedEdges, []);
axis on;
[endPointRows, endPointColumns] = find(endPoints);
numberOfEndpoints = length(endPointRows)
hold on;
hEndPoints = plot(endPointColumns, endPointRows, 'r.', 'MarkerSize', 23);
title('Endpoints in Red', 'FontSize', fontSize, 'Interpreter', 'None');

% Display it again in the lower right where we will put line on it.
subplot(2, 2, 4);
imshow(thickenedEdges, []);
axis on;
hold on;

% See if they want to connect endpoints if they are on the same segment,
% or must the endpoints reside on different segments.
message = sprintf('Do you want to connect end points if they reside on the same segment or must they reside on different segments?');
button = questdlg(message, 'Continue?', 'Same is OK', 'Different Only', 'Same is OK');
drawnow;	% Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'Different Only')
   mustBeDifferent = true;
else
   mustBeDifferent = false;
end

% Define the longest distance that we are willing to jump/close.
longestGapToClose = ceil(0.3 * rowsInImage)
% Ask user how long a gap do they want to jump/close.
defaultValue = {num2str(longestGapToClose)};
titleBar = 'Enter a value';
userPrompt = {'Enter longest gap to close : '};
caUserInput = inputdlg(userPrompt, titleBar, 1, defaultValue);
if isempty(caUserInput),return,end; % Bail out if they clicked Cancel.
% Convert to floating point from string.
usersValue1 = str2double(caUserInput{1})
% Check for a valid number.
if isnan(usersValue1)
    % They didn't enter a number.  
    % They clicked Cancel, or entered a character, symbols, or something else not allowed.
	% Convert the default from a string and stick that into usersValue1.
    usersValue1 = str2double(defaultValue{1});
    message = sprintf('I said it had to be a number.\nI will use %.2f and continue.', usersValue1);
    uiwait(warndlg(message));
end
longestGapToClose = usersValue1;
fprintf('I will close gaps of %.1f pixels.\n', longestGapToClose);

% Label the image.  Gives each separate segment a unique ID label number.
[labeledImage, numberOfSegments] = bwlabel(edgeImage);
fprintf('There are %d endpoints on %d segments.\n', numberOfEndpoints, numberOfSegments);
% Get the label numbers (segment numbers) of every endpoint.
for k = 1 : numberOfEndpoints
	thisRow = endPointRows(k);
	thisColumn = endPointColumns(k);
	% Get the label number of this segment
	theLabels(k) = labeledImage(thisRow, thisColumn);
	fprintf('Endpoint #%d at (%d, %d) is in segment #%d.\n', k, thisRow, thisColumn, theLabels(k));
end

% For each endpoint, find the closest other endpoint
% that is not in the same segment
for k = 1 : numberOfEndpoints
	thisRow = endPointRows(k);
	thisColumn = endPointColumns(k);
	% Get the label number of this segment
	thisLabel = theLabels(k);
	% Get indexes of the other end points.
	otherEndpointIndexes = setdiff(1:numberOfEndpoints, k);
	if mustBeDifferent
		% If they want to consider joining only end points that reside on different segments
		% then we need to remove the end points on the same segment from the "other" list.
		% Get the label numbers of the other end points.
		otherLabels = theLabels(otherEndpointIndexes);
		onSameSegment = (otherLabels == thisLabel); % List of what segments are the same as this segment
		otherEndpointIndexes(onSameSegment) = []; % Remove if on the same segment
	end
	
	% Now get a list of only those end points that are on a different segment.
	otherCols = endPointColumns(otherEndpointIndexes);
	otherRows = endPointRows(otherEndpointIndexes);
	
	% Compute distances
	distances = sqrt((thisColumn - otherCols).^2 + (thisRow - otherRows).^2);
	% Find the min
	[minDistance, indexOfMin] = min(distances);
	nearestX = otherCols(indexOfMin);
	nearestY = otherRows(indexOfMin);
	if minDistance < longestGapToClose;
		% Draw line from this endpoint to the other endpoint.
		line([thisColumn, nearestX], [thisRow, nearestY], 'Color', 'g', 'LineWidth', 2);
		fprintf('Drawing line #%d, %.1f pixels long, from (%d, %d) on segment #%d to (%d, %d) on segment #%d.\n', ...
			k, minDistance, thisColumn, thisRow, theLabels(k), nearestX, nearestY, theLabels(indexOfMin));
	end
end
title('Endpoints Linked by Green Lines', 'FontSize', fontSize, 'Interpreter', 'None');

