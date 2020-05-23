function [Lx,Ly,Cx,Cy] = extract_cir_n_level(img)
%EXTRACT_CIR_N_LEVEL Summary of this function goes here
%   Detailed explanation goes here
BW = rgb2gray(img);
BW = min(img,[],3);

%Resize the image
A1 = BW(1:19*size(BW,1)/50,1:size(BW,2),:);
A = imresize(A1, [530,750]);

%%% while giving it back i need to adjust it to the original image
fractionX = size(A1,2) / size(A,2);
fractionY = size(A1,1) / size(A,1) ;
 
%%% Centers.
Rmin=200;
Rmax=500;

[center, radius] = imfindcircles(BW,[Rmin Rmax],...
    'ObjectPolarity','bright' , 'Sensitivity',0.99);

if size(center,1) == 1
    Cx = center(1,1);
    Cy = center(1,2);
else
    Cx = fractionX * size(A,2)/2;
    Cy = fractionY * 490;
    % half the image and somewhere. This is not simple i need to
    %take into account some other things as well. Like scaling
end

mask = imread('./base/mask.bmp');
% A = imcomplement(A - mask);
Amask = mask - A;
points = detectBRISKFeatures(Amask);
strongestPoints =points.selectStrongest(5);
% imshow(Amask);hold on;
% plot(strongestPoints);
cordinates = strongestPoints.Location;
[idx, Level] = kmeans(cordinates, 2);

vT = zeros(1,2);
vT(unique(idx)) = histc(idx, unique(idx));

% Remove everything that is below 495. 

% mask(500:530, :) = zeros(31,750);

vT = zeros(1,2);
vT(unique(idx)) = histc(idx, unique(idx));
[~, point] = max(vT);
imshow(img);hold on;

%%% current 495.1324, 205.8949
%%% 371, 148
Lx = fractionX * Level(point,1);
Ly = fractionY * Level(point,2);

% plot(Lx, Ly, 'r*');
end

