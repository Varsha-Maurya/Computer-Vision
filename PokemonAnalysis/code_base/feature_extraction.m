function feat = feature_extraction(img)
persistent descriptor_list
% persistent descriptors
persistent C
persistent cluster_size;
if isempty(descriptor_list)
    disp('Bag of visual words');
    img_path = './train/';
    class_num = 30;
    img_per_class = 55;
    cluster_size=35;
    % The total number of images for all the class included is = 1650 
    % Total number of classes that we have is 30. 
    % Total number of Images in each of these class is 55.
    sprintf('Total number of classes are %d',class_num);
    sprintf('Total number of images/class is %d',img_per_class);
    img_num = class_num .* img_per_class;
    folder_dir = dir(img_path);

    % extract all the surf descriptors for all the images.
    % This will give you a big list of all the descriptors that you have.
    % Iterate over all the classes in the training examples.
    descriptor_list = [];
    descriptors = [];
    actual_label= [];
    another_label=[];
    m = java.util.HashMap;
    index=1;
    disp('Generating SURF descriptors list for all the training images...')
    for p = 1:length(folder_dir)-2
        % Iterate over all the images in each class
        img_dir = dir([img_path,folder_dir(p+2).name,'/*.JPG']);
        if isempty(img_dir)
            img_dir = dir([img_path,folder_dir(p+2).name,'/*.BMP']);
        end
        for q = 1:length(img_dir)
            I = imread([img_path,folder_dir(p+2).name,'/',img_dir(q).name]);
            Ig = rgb2gray(I);
            % Used to detect SURF features.
            points = detectSURFFeatures(Ig,'NumOctaves',5);
            %Take only the top 5 feature descriptor for each image
            %strongest = points.selectStrongest(20);
            % extract features
            %%% take mean 
            [descriptor,vpts] = extractFeatures(Ig,points,'Method','SURF');
            descriptor_list = [descriptor_list;descriptor];
%             descriptors = [descriptors;descriptor];
%             another_label = [another_label; p*ones(size(descriptor,1),1)];
            m.put(index,descriptor);
            actual_label = [actual_label;p];
            index = index + 1;
        end
    end
    disp('SURF Descriptors are generated.');
    sprintf('Total number of descriptors %d x %d',size(descriptor_list));
    save('des.mat','descriptor_list');

    % Once you have the total number of descriptors you will try to cluster 
    % them using k-means clustering . k is an hyper-parameter here.
    % At this point here we have a dictionary of all the visual words.
    disp('Starting K-means clustering with K=10....');
    
    start = ones(cluster_size,64);
    %         'Start',start,...
    [idx,C] = kmeans(double(descriptor_list),cluster_size,...
        'Display','iter',...
        'Replicates',5,...
        'MaxIter',1000);
    disp('K-means clustering completed');

    % Once the dictionary is completed we run the image set again to get the 
    % frequency vector for each image this is an histogram of each image 
    % w.r.t to the codebook.
    disp('Generating Codebook/Dictionary with vector quantization of histogram for Visual words....');
    frequency_vector = [];
    for i = 1:m.size
        k = dsearchn(C,double(m.get(i)));
        v = zeros(1,cluster_size);
        v(unique(k)) = histc(k,unique(k));
        v = v / size(k,1); %Normalize the vector
        frequency_vector = [frequency_vector;v];
    end
    disp('Codebook/Dictionary of histogram for Visual words completed');
    disp('Bag of Visual words completed');
    disp('Save all the variables');
    save('model.mat','frequency_vector','C','idx','actual_label','descriptor_list');
%     ...
%        'another_label','descriptors');
end

%%% Extraction of features
% get surf descriptor
T = rgb2gray(img);
% Used to detect SURF features.
pointsT = detectSURFFeatures(T,'NumOctaves',4);
%Take only the top 5 feature descriptor for each image
%strongestT = pointsT.selectStrongest(20);
% extract features
[descriptorsT,vptsT] = extractFeatures(T,pointsT,'Method','SURF'); %detectSURFFeatures(Ig,'FilterSize',5);
kT = dsearchn(C,double(descriptorsT));
%%% Send the vector as the generated feature.
vT = zeros(1,cluster_size);
vT(unique(kT)) = histc(kT,unique(kT));
vT = vT / size(kT,1); %Normalize the vector
feat = mean(descriptorsT);
end


