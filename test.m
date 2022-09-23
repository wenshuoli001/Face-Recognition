% addpath software;
% 
% 
% Imagestrain = loadImagesInDirectory ( 'images/training-set/23x28/');
% [Imagestest, Identity] = loadTestImagesInDirectory ( 'images/testing-set/23x28/');
% % transform the images to vectors when reading the images. size of each image is 23*28 turns to a 1*644 vector%
% % there are 200 images in training set so the training set turns to a 200*644 matrix, similarly ,the test set turns to a 70*644 matrix %
% % the identity of test set means the id of human faces of test set%
% 
% ImagestrainSizes = size(Imagestrain);
% Means = floor(mean(Imagestrain));
% CenteredVectors = (Imagestrain - repmat(Means, ImagestrainSizes(1), 1));
% CovarianceMatrix = cov(CenteredVectors);
% %Means: mean image of training set, i.e.mean vector of training set, each value is the mean value of column of training set matrix%
% %CenteredVectors: each image in training set minus the mean image, this can move the center of all the vectors from mean to 0 for calculating covarence matrix%
% [U, S, V] = svd(CenteredVectors);
% Space = V(: , 1 : ImagestrainSizes(1))';
% Eigenvalues = diag(S);
% %Perform singular value decomposition on CenteredVectors, CenteredVectors=U*S*V, the diagonal of S are eigenvalues, which are 200 numbers, the first 200 rows of V are eigenvectors wrt the eigenvalues%
% %the eigenvalues are ranked from large to small,Eigenvectors with larger eigenvectors correspond to directions in which the data varies more%
% %the eigenvectors are eigenfaces%
% 
% 
% MeanImage = uint8 (zeros(28, 23));
% for k = 0:643
%    MeanImage( mod (k,28)+1, floor(k/28)+1 ) = Means (1,k+1);
%  
% end
% figure;
% subplot (1, 1, 1);
% imshow(MeanImage);
% title('Mean Image');
% %transform the mean image from a 1*644 vector back to 23*28 image and plot%
% 
% 
% for i=1:20
%     for k = 0:643
%         eigenface( mod (k,28)+1, floor(k/28)+1 ) = Space(i,k+1);
%     end
%     subplot (4, 5, i),imshow(eigenface,[]);
% end
% %transform the first 20 eigenvectors(eigenfaces) from a 1*644 vector  to 23*28 image and plot%
% %map the value in eigenfaces to 0-255 by add a [] in imshow function %
% % 
% % 
% % 
% Locationstrain=projectImages (Imagestrain, Means, Space);
% Locationstest=projectImages (Imagestest, Means, Space);
% 
% Threshold =20;
% 
% TrainSizes=size(Locationstrain);
% TestSizes = size(Locationstest);
% Distances=zeros(TestSizes(1),TrainSizes(1));
%%
% % 
% for i=1:TestSizes(1),
%     for j=1: TrainSizes(1),
%         Sum=0;
%         for k=1: Threshold,
%    Sum=Sum+((Locationstrain(j,k)-Locationstest(i,k)).^2);
%         end,
%      Distances(i,j)=Sum;
%     end,
% end,
% 
% Values=zeros(TestSizes(1),TrainSizes(1));
% Indices=zeros(TestSizes(1),TrainSizes(1));
% for i=1:70,
% [Values(i,:), Indices(i,:)] = sort(Distances(i,:));
% end,
% %calculate the distance between projected test images and projected training images %
% %for every projected test images, rank the distance to each projected training image and get the corresponding index of training set  %
% % 
% 
% figure;
% x=6;
% y=2;
% for i=1:6,
%       Image = uint8 (zeros(28, 23));
%       for k = 0:643
%      Image( mod (k,28)+1, floor(k/28)+1 ) = Imagestest (i,k+1);
%       end,
%    subplot (x,y,2*i-1);
%     imshow (Image);
%     title('Image tested');
%     
%     Imagerec = uint8 (zeros(28, 23));
%       for k = 0:643
%      Imagerec( mod (k,28)+1, floor(k/28)+1 ) = Imagestrain ((Indices(i,1)),k+1);
%       end,
%      subplot (x,y,2*i);
% imshow (Imagerec);
% title(['Image recognised with ', num2str(Threshold), ' eigenfaces:',num2str((Indices(i,1))) ]);
% end,
% %choose the training image with the nearest distance as the matched image, this means we used a KNN which K=1%
% % 
% 
% rec_rate = [];
% for i = 1: 70
%     if ceil(Indices(i,1)/5) == Identity(i)
%         rec_rate(i) = 1;
%     else 
%         rec_rate(i) = 0;
%     end
% end
% recognition_rate = sum(rec_rate)/70 *100;
% %in training set, each face has 5 images, so the number of images from 1-200 divided by 5 then round up, we can get the id of face%
% %if the id is matched, this means the result is correct, for 70 test images, calculate the proportion of correct matched images%
% % 
% 
% averageRR=zeros(1,20);
% for t=1:40,
%   Threshold =t;  
% Distances=zeros(TestSizes(1),TrainSizes(1));
% 
% for i=1:TestSizes(1),
%     for j=1: TrainSizes(1),
%         Sum=0;
%         for k=1: Threshold,
%    Sum=Sum+((Locationstrain(j,k)-Locationstest(i,k)).^2);
%         end,
%      Distances(i,j)=Sum;
%     end,
% end,
% 
% Values=zeros(TestSizes(1),TrainSizes(1));
% Indices=zeros(TestSizes(1),TrainSizes(1));
% number_of_test_images=zeros(1,40);% Number of test images of one given person.%YY I modified here
% for i=1:70,
% number_of_test_images(1,Identity(1,i))= number_of_test_images(1,Identity(1,i))+1;%YY I modified here
% [Values(i,:), Indices(i,:)] = sort(Distances(i,:));
% end,
% 
% rec_rate = [];
% for i = 1: length(Imagestest(:,1))
%     % if the indices of train does not match with Identity in test then rate is 0.
%     if ceil(Indices(i,1)/5) == Identity(i)
%         rec_rate(i) = 1;
%     else 
%         rec_rate(i) = 0;
%     end
% end
% recognition_rate = sum(rec_rate)/70 *100;
% averageRR(1,t) = recognition_rate;
% 
% end,
% figure;
% plot(averageRR(1,:));
% title('Recognition rate against the number of eigenfaces used');
% %threshold t means the number of eigenfaces, for the number of eigenfaces from 1 to 40，compute the distance and match images by the shortest distance (K=1 in KNN)%
% % 
% 
% 
Threshold =20;

TrainSizes=size(Locationstrain);
TestSizes = size(Locationstest);
Distances=zeros(TestSizes(1),TrainSizes(1));

for i=1:TestSizes(1),
    for j=1: TrainSizes(1),
        Sum=0;
        for k=1: Threshold,
   Sum=Sum+((Locationstrain(j,k)-Locationstest(i,k)).^2);
        end,
     Distances(i,j)=Sum;
    end,
end,

Values=zeros(TestSizes(1),TrainSizes(1));
Indices=zeros(TestSizes(1),TrainSizes(1));
for i=1:70,
[Values(i,:), Indices(i,:)] = sort(Distances(i,:));
end,
%recalculate the distance and indices with 20 eigenfaces %

RRwrtK=zeros(1,200);%for 200 K %
for K=1:200
    rec_rate = [];
for i = 1: length(Imagestest(:,1))
    for j=1:K
        Kpridictions(j)=ceil(Indices(i,j)/5);%for the nearest K training images , save their id to a vector and choose the mode of id as the prediction%
    end
    pridiction=mode(Kpridictions);
    if pridiction == Identity(i)
        rec_rate(i) = 1;
    else 
        rec_rate(i) = 0;
    end
end
recognition_rate = sum(rec_rate)/70 *100;
RRwrtK(1,K) = recognition_rate;
end
figure;
plot(RRwrtK(1,:));
%calculate the recognition rate of 200 K and plot %
