function [HP] = hp_extract(img)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%% Set the HP template.
hp_template = imread('base/HP/hp.bmp');
hp_template1 = imread('base/HP/hp2.bmp');

%%% Set the slash template
slash_template = imread('base/HP/sls.bmp');
slash_template1 = imread('base/HP/sls2.bmp');

I = imresize(img,[1340 750]);

BW = rgb2gray(I);

% Split the image in 3 halves [0:50 , 50:60, 60:100]
A = BW(1:9*size(BW,1)/20,1:size(BW,2),:);
B = BW(9*size(BW,1)/20+1:3*size(BW,1)/5,1:size(BW,2),:);
C = BW(3*size(BW,1)/5+1:size(BW,1),1:size(BW,2),:);



[xpeakSlash, ypeakSlash, xoffSlash , yoffSlash] = getTemplateMatch(slash_template, B);

[xpeakHP, ypeakHp, xoffHP , yoffHP] = getTemplateMatch(hp_template, B);

B = 255 - B;
tresh = 70;
B(B > tresh) = 255;
B(B < tresh) = 0;

if xpeakSlash > xpeakHP
    % This means that HP precedes the slash e.g: HP 30/30
    % We will use the HPN base for this.
%     HP_NUM = imread('base/HPN');
    %hp_num = imcrop(B, [xpeakHP,yoffHP, 30, 30]);
    hp_num = imcrop(B, [xpeakHP+4,yoffHP, xoffSlash - xpeakHP-4, ypeakHp - yoffHP]);
    hp_num = imcrop(B, [xpeakHP+4,yoffHP-2, xoffSlash-xpeakHP-4, ypeakHp - yoffHP]);
    hp_num_path = './base/HPN/';
    
else
    % This means that Slash preceded the HP e.g: 10/10 HP
    % We will use the HPNUM base for this.
%     HP_NUM = imread('base/HPNUM');
    % do a template match again.
    % xpeak+1, yoffSet+1, xoffSetS - xpeak, ypeak - yoffSet
    [xpeakSlash, ypeakSlash, xoffSlash , yoffSlash] = getTemplateMatch(slash_template1, B);
    [xpeakHP, ypeakHp, xoffHP , yoffHP] = getTemplateMatch(hp_template1, B);
    hp_num = imcrop(B, [xpeakSlash+4,yoffSlash-2, xoffHP - xpeakSlash - 4, ypeakSlash - yoffSlash]);
    hp_num_path = './base/HPNUM/';
end

hp_num_bw = imbinarize(hp_num);
%hp_num_bw_open = bwareaopen(hp_num_bw, 50);
RP = regionprops(hp_num_bw);

hp_num_dir = dir(hp_num_path);
hp_num_dir=hp_num_dir(~ismember({hp_num_dir.name},{'.','..'}));

hp='';
for i=1:length(RP)
    %crop the image 
    hp_extract = imcrop(hp_num,RP(i).BoundingBox);
    % find the correlation wrt all the base images
    strength = [];
    for j=1:length(hp_num_dir)
        %open the image
        % TODO : Need to have images that i want as base
        name = hp_num_dir(j).name;
        hp_num_file = fullfile(hp_num_path, name);
        HP_NUM = imread(hp_num_file);
        % Resize the image to base image
        HP_RESIZE = imresize(hp_extract,[size(HP_NUM,1),size(HP_NUM,2)]);
        
        HP_NUM_BW = imbinarize(HP_NUM);
        HP_RESIZE_BW = imbinarize(HP_RESIZE);
        %Find the correlation 
        cor = corr2(HP_NUM_BW,HP_RESIZE_BW);  
        %strength array concat
        strength = [strength, cor];
    end
    index = find(strength == max(max(strength)));
    hp = strcat(hp,num2str(index-1));
end
if (isempty(hp))
    hp = '10'
end
HP = str2num(hp);
end

function [xpeak,ypeak,xoffSet,yoffSet] = getTemplateMatch(template , img)

    c = normxcorr2(template,img);
    %Find the peak in cross-correlation.
    [ypeak, xpeak] = find(c==max(c(:)));
    %Account for the padding that normxcorr2 adds.
    yoffSet = ypeak-size(template,1);
    xoffSet = xpeak-size(template,2);
    
%     Sometimes it returns 2.. this should prevent it.
    ypeak = ypeak(1);
    xpeak = xpeak(1);
    yoffSet = yoffSet(1);
    xoffSet = xoffSet(1);
        
end

