
%Read the image
img_path = './train/';
img_dir = dir([img_path,'*CP*']);
img_num = length(img_dir);

actual_label = []

%There are a total of 910 images
descriptor_list = [];
for i = 1:img_num
    name = img_dir(i).name;
    ul_idx = findstr(name,'_'); 
    img = imread([img_path,img_dir(i).name]);
    % We only need the 40% of the image
    A = img(size(img,1)/10:size(img,1)/2.2,size(img,2)/4:3*size(img,2)/4,:);
    A = imresize(A,[637,537]);

    Ig = rgb2gray(A);
    [descriptor,~] = extractHOGFeatures(Ig,'CellSize',[32 32]);
    r=str2num(name(1:ul_idx(1)-1));
    actual_label = [actual_label; repmat(r,size(descriptor,1),1)]; 
    
    descriptor_list = [descriptor_list; descriptor];
end
save('model.mat','actual_label','descriptor_list');
