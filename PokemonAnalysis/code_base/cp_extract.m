function [CP] = cp_extract(img)
%CP_EXTRACT Summary of this function goes here
%   Detailed explanation goes here

%resize the image
I = imresize(img,[1340 750]);
%convert image into BW
BW = rgb2gray(I);

% Split the image in 4 halves
A = BW(1:size(BW,1)/4,1:size(BW,2),:);
B = BW(size(BW,1)/4+1:size(BW,1)/2,1:size(BW,2),:);
C = BW(size(BW,1)/2+1:3*size(BW,1)/4,1:size(BW,2),:);
D = BW(1+3*size(BW,1)/4:size(BW,1),1:size(BW,2),:);

% Call the base image for template matching.
CP = imread('base/CP/cp.bmp');

%Perform template matching.
c = normxcorr2(CP,A); %Only need the first quarter.
%Find the peak in cross-correlation.
[ypeak, xpeak] = find(c==max(c(:)));

%Account for the padding that normxcorr2 adds.
yoffSet = ypeak-size(CP,1);
xoffSet = xpeak-size(CP,2);


% Now extract the region for numbers
x = xpeak;
y = yoffSet-4;
dx = 142;
dy = 60;
%%% Add the offset
% This is considering that region has max 3 digits.
cp_num = imcrop(A,[x,y,dx,dy]);
%%% Extract the image by using regionprops
cp_num_bw = imbinarize(cp_num);
cp_num_bw_open = bwareaopen(cp_num_bw, 50);
RP = regionprops(cp_num_bw_open);
cp_num_path = './base/CPNUM/';
cp_num_dir = dir(cp_num_path);
cp_num_dir=cp_num_dir(~ismember({cp_num_dir.name},{'.','..'}));
c = '';
for i=1:length(RP)
    %crop the image 
    cp_extract = imcrop(cp_num,RP(i).BoundingBox);
    % find the correlation wrt all the base images
    strength = [];
    for j=1:length(cp_num_dir)
        %open the image
        % TODO : Need to have images that i want as base
        name = cp_num_dir(j).name;
        cp_num_file = fullfile(cp_num_path, name);
        CP_NUM = imread(cp_num_file);
        % Resize the image to base image
        CP_RESIZE = imresize(cp_extract,[size(CP_NUM,1),size(CP_NUM,2)]);
        
        CP_NUM_BW = imbinarize(CP_NUM);
        CP_RESIZE_BW = imbinarize(CP_RESIZE);
        %Find the correlation 
        cor = corr2(CP_NUM_BW,CP_RESIZE_BW);  
        %strength array concat
        strength = [strength, cor];
    end
    index = find(strength == max(max(strength)));
    c = strcat(c,num2str(index-1));
end
% Return the CP value
CP = str2num(c);
end

