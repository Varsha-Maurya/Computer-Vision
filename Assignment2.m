%% Assignment 2
% Generating Hybrid images.
% We use 2 images and pass one image through a LPF and another through a 
% HPF and then add the images to generate a hybrid image.
%% Intialiazation

clc;clear all;
img_num = 6;

lpf_sigma = [13,12,18,9,12,10];
hpf_sigma = [5,5,1.25,2.5,5,6];

image1path = './lpf/';
image2path = './hpf/';

imgage1dir = dir([image1path,'*jpg']);
imgage2dir = dir([image2path,'*jpg']);

%%
for i = 1:img_num
    %% Low pass filter for smoothening image
    
    I1 = imread([image1path,imgage1dir(i).name]);
    I11 = imresize(I1,[640,640]);
    I1_grey = rgb2gray(I11);
    lpf = imgaussfilt(I1_grey,lpf_sigma(i));
    subplot(1,3,1);
    imshow(I1);
    
    %% High pass filter for sharpening image
    
    I2 = imread([image2path,imgage2dir(i).name]);
    I22 = imresize(I2,[640,640]);
    I2_grey = rgb2gray(I22);
    hpf = I2_grey - imgaussfilt(I2_grey,hpf_sigma(i));
    subplot(1,3,2);
    imshow(I2);
    %% Hybrid Image
    
    R = lpf + hpf;
    subplot(1,3,3);
    imshow(R);
    f = figure; 
    imshow(R);
    saveas(f,sprintf('output_%d',i),'jpg');
    fprintf('The hybrid image is saved as output image.Press enter to continue.\n');
    pause;
   
end;

fprintf('Please consider top 4 hybrid images. Thank you!')



