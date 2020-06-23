function result = Kaiming_Algorithm(image, varargin)
omega = 0.95;
t0 = 0.1;
guideFilter = 1;
switch nargin
    case 2
        omega = varargin{1};
    case 3
        omega = varargin{1};
        t0 = varargin{2};
    case 4
        omega = varargin{1};
        t0 = varargin{2};
        guideFilter = varargin{3};
    otherwise
end
image = im2double(image);
winSize = [15 15];

% dark channel
darkChn = min(image, [], 3);
% minFunc = @(x) min(x(:));
% darkChn = nlfilter(darkChn, winSize, minFunc);
minFilter = strel('square', 15);
darkChn = imerode(darkChn, minFilter);

% find mospheric light A
image_flatten = reshape(image, [], 3);
[~, darkIndex] = sort(darkChn(:));
selPixels = image_flatten(darkIndex(double(end - uint16(length(darkIndex) * 0.001)):end), :);
intensity = sum(selPixels, 2);
[intensSorted, intensIndex] = sort(intensity);
pixNum = double(uint16(length(intensIndex) * 0.2));
A = mean(selPixels(intensIndex(end-pixNum:end), :), 1);
% A = mean(selPixels, 1);

% transmission map
[H, W, C] = size(image);
tmMap0 = image_flatten ./ (A + 1e-7);
tmMap0 = min(tmMap0, [], 2);
tmMap0 = reshape(tmMap0, H, W);
% tmMap = nlfilter(tmMap0, winSize, minFunc);
tmMap = imerode(tmMap0, minFilter);
t = max(0, 1 - omega * tmMap);

% Guide Filter
if guideFilter
    guideImg = rgb2gray(image);
%     t = imguidedfilter(t, guideImg, 'NeighborhoodSize', [60, 60]);
    t = guidedfilter(guideImg, t, 61, 0.00001);
end
    
% recover 
% result = (image - A) ./ max(t, t0) + A;
t = reshape(t, [], 1);
result = (image_flatten - A) ./ max(t, t0) + A;
result = reshape(result, H, W, C);
end