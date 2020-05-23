function predict_label = your_kNN(feat)

disp('------------TESTING ON IMAGES--------------');
file = load('train.mat');
actual_label = file.actual_label;
frequency_vector = file.frequency_vector;
%%% Apply Knn
KNN = fitcknn(frequency_vector,actual_label,'NumNeighbors',30),%...
%     'NumNeighbors',30,...
%     'Standardize',1);

Y = predict(KNN,frequency_vector);
training_acc = sum(actual_label == Y) ./ length(actual_label);
display(training_acc);


predict_label = predict(KNN,feat);
%%% break the tie-breaker by selecting the first in the original list.
end