function [ID, CP, HP, stardust, level, cir_center] = pokemon_stats (img, model)
% Please DO NOT change the interface
% INPUT: image; model(a struct that contains your classification model, detector, template, etc.)
% OUTPUT: ID(pokemon id, 1-201); level(the position(x,y) of the white dot in the semi circle); cir_center(the position(x,y) of the center of the semi circle)

label = model.actual_label;
train = model.descriptor_list;

A = img(size(img,1)/10:size(img,1)/2.2,size(img,2)/4:3*size(img,2)/4,:);
A = imresize(A,[637,537]);
Ig = rgb2gray(A);
[descriptor,~] = extractHOGFeatures(Ig,'CellSize',[32 32]);

mdl = fitcknn(train,label,'NumNeighbors',1);
[predict_label,~,~] = predict(mdl,descriptor);

ID = predict_label;
CP = cp_extract(img);
HP = hp_extract(img);
stardust = power_extract(img);
[Lx,Ly,Cx,Cy] = extract_cir_n_level(img);
level = [Lx,Ly];
cir_center = [Cx,Cy];

end
