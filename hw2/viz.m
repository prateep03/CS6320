clear;

fprintf('Visualizing epipolar line...');

load stereoPointPairs;
Ileft  = imread('viprectification_deskLeft.png');
pts1 = matched_points1(knownInliers,:);
Iright = imread('viprectification_deskRight.png');
pts2 = matched_points2(knownInliers,:);

load('linepts.mat');

figure;clf;
subplot(121); imshow(Ileft); hold on;
plot(pts1(1,1), pts1(1,2),'go');
subplot(122); imshow(Iright); hold on;
line(linepts(:,1)', linepts(:,2)');
fprintf('Done\n');