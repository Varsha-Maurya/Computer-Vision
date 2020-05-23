function [POW] = power_extract(img)
%EXTRACT_STARDUST Summary of this function goes here
%   Detailed explanation goes here

%%% Set the power up template.
powup_template = imread('base/DUST/powUP.bmp');

%%% Set the slash template
p00_template = imread('base/DUST/p00.bmp');
power_template = imread('base/DUST/pow.bmp');

I = imresize(img,[1340 750]);
BW  = rgb2gray(I);

% Split the image in 3 halves [0:50 , 50:60, 60:100]
A = BW(1:2*size(BW,1)/3,1:size(BW,2),:);
B = BW(2*size(BW,1)/3+1:size(BW,1),1:size(BW,2),:);

%%%First find the Power up button
[xpeakPowUp, ypeakPowUp, xoffPowUp , yoffPowUp] = getTemplateMatch(powup_template, B);

%%% crop the image
powup = imcrop(B, [xpeakPowUp-8, yoffPowUp,120, 90]);

if size(powup,1) < size(p00_template,1) || size(powup,2) < size(p00_template,2)
    powup = imresize(powup,[80,80]);
end
%%%Detect the p00 and power
[xpeakPower, ypeakPower, xoffPower , yoffPower] = getTemplateMatch(power_template, powup);

[xpeakP00, ypeakP00, xoffP00 , yoffP00] = getTemplateMatch(p00_template, powup);

powup_num = imcrop(powup, [xpeakPower, yoffPower+4,xoffP00-xpeakPower,ypeakP00 - yoffPower]);

%%%Now once this is done convert the image to binary.
powup_num = 255 - powup_num;
tresh = 100;
powup_num(powup_num > tresh) = 255;
powup_num(powup_num < tresh) = 0;
powup_num_bw = imbinarize(powup_num);
%Needed sometimes
pow_num_bw_open = bwareaopen(powup_num_bw, 10);

RP = regionprops(pow_num_bw_open);
pow_num_path = './base/DUSTNUM/';
pow_num_dir = dir(pow_num_path);
pow_num_dir=pow_num_dir(~ismember({pow_num_dir.name},{'.','..'}));

pow='';
for i=1:length(RP)
    pow_extract = imcrop(powup_num,RP(i).BoundingBox);
    % find the correlation wrt all the base images
    strength = [];
    for j=1:length(pow_num_dir)
        %open the image
        % TODO : Need to have images that i want as base
        name = pow_num_dir(j).name;
        pow_num_file = fullfile(pow_num_path, name);
        POW_NUM = imread(pow_num_file);
        % Resize the image to base image
        POW_RESIZE = imresize(pow_extract,[size(POW_NUM,1),size(POW_NUM,2)]);
        
        POW_NUM_BW = imbinarize(POW_NUM);
        POW_RESIZE_BW = imbinarize(POW_RESIZE);
        %Find the correlation 
        cor = corr2(POW_NUM_BW,POW_RESIZE_BW);  
        %strength array concat
        strength = [strength, cor];
    end
    index = find(strength == max(max(strength)));
    pow = strcat(pow,num2str(index-1));
end
pow = strcat(pow,'00');
POW = str2num(pow);
end

function [xpeak,ypeak,xoffSet,yoffSet] = getTemplateMatch(template , img)

    c = normxcorr2(template,img);
    %Find the peak in cross-correlation.
    [ypeak, xpeak] = find(c==max(c(:)));
    %Account for the padding that normxcorr2 adds.
    yoffSet = ypeak-size(template,1);
    xoffSet = xpeak-size(template,2);
    
    % Sometimes it returns 2.. this should prevent it.
    ypeak = ypeak(1);
    xpeak = xpeak(1);
    yoffSet = yoffSet(1);
    xoffSet = xoffSet(1);
        
end


