clear;
close all;

n = 8;
vec = randperm(n);
lineRight = 1;

%% Load Input
load stereoPointPairs;
Ileft  = imread('viprectification_deskLeft.png');
pts1 = matched_points1(knownInliers,:);
Iright = imread('viprectification_deskRight.png');
pts2 = matched_points2(knownInliers,:);

%% Get 'n' matched points from both images in order to find F
pts1 = pts1(vec,:);
pts2 = pts2(vec,:);

%% Compute F
M = [pts1(:,1).*pts2(:,1) pts1(:,1).*pts2(:,2) pts1(:,1) pts1(:,2).*pts2(:,1) ...
                pts1(:,2).*pts2(:,2) pts1(:,2) pts2(:,1) pts2(:,2)];
            
Fvec = -[M \ ones(n,1); 1];
F = reshape(Fvec,3,3)';
disp(F);
% clear variables
clear M;
clear Fvec;

%% Convert pts1 pts2 to homogenous
pts1h = [pts1 ones(size(pts1,1),1)];
pts2h = [pts2 ones(size(pts2,1),1)];

%% Get epipolar line 
ptIndex = 1:2:length(pts1);
if lineRight,
    lineSegment = F * pts1h(ptIndex,:)';
else
    lineSegment = pts2h(ptIndex,:) * F;
end
lineSegment = lineSegment ./ sqrt(sum(lineSegment(1:2).^2));
fprintf('Computing points on line...');
if lineRight,
    linepts = lineToBorderPoints(lineSegment', size(Iright));
else
    linepts = lineToBorderPoints(lineSegment, size(Ileft));
end

fprintf('Done\n');
fprintf('Number of points found = %d\n',length(linepts));

%% Compute epipoles
fprintf('Computing epipoles...\n');

if lineRight,
    [u,d] = eigs(F * F');
else
     [u,d] = eigs(F' * F);
end
uu = u(:,3);
ep = uu / uu(3);
fprintf('epipole = (%.2f,%.2f)\n', ep(1), ep(2));
fprintf('Done\n');

%% Display
figure;clf;
if lineRight,
    subplot(121); imshow(Ileft); hold on;
    line(linepts(:,[1,3])',linepts(:,[2,4])','Linewidth',2);
    plot(ep(1), ep(2), 'd','Color',[1.0 0.2 0.3],  'Linewidth',2);
    subplot(122); imshow(Iright); hold on;
    plot(pts2(ptIndex,1), pts2(ptIndex,2),'go','Linewidth',2);
else
    subplot(121); imshow(Ileft); hold on;
    plot(pts1(ptIndex,1), pts1(ptIndex,2),'go','Linewidth',2);
    subplot(122); imshow(Iright); hold on;
    line(linepts(:,[1,3])',linepts(:,[2,4])','Linewidth',2);
    plot(ep(1), ep(2), 'd', 'Color',[1.0 0.2 0.3], 'Linewidth',2);
end