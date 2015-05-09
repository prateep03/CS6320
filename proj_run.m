clear;
close all;

I1 = rgb2gray(imread('view1.png'));
I2 = rgb2gray(imread('view5.png'));

if ~isa(I1,'double'),
    I1 = im2double(I1);
end

if ~isa(I2,'double'),
    I2 = im2double(I2);
end

I1e   = imfilter(I1, [-1 0 1]);
I2e   = imfilter(I2, [-1 0 1]);
% I1e = conv2(I1, 20.5 * [-1 1; -1 1],'same');
% I2e = conv2(I2, 20.5 * [-1 1; -1 1],'same');

I1e = double(abs(I1e) >= 0.1);
I2e = double(abs(I2e) >= 0.1);

I1e = I1e(:,1:(size(I1e,2)-1));
I2e = I2e(:,1:(size(I2e,2)-1));

%% Remove small blobs
th = 50;
[bw1,n1] = bwlabel(I1e);
s = regionprops(bw1,'Area');
for i=1:n1
    if s(i).Area < th,
        ind = find(bw1 == i);
        bw1(ind) = 0;
    end
end
[bw2,n2] = bwlabel(I2e);
s = regionprops(bw2,'Area');
for i=1:n2
    if s(i).Area < th,
        ind = find(bw2 == i);
        bw2(ind) = 0;
    end
end

bw1 = double(abs(bw1) > 0);
bw2 = double(abs(bw2) > 0);

% bw1s = bwmorph(bw1,'skel');
% bw2s = bwmorph(bw2,'skel');

%% 
p1 = generateProfile(bw1);
p2 = generateProfile(bw2);

figure;
subplot(221); imshow(I1,[]);
subplot(222); imshow(I2,[]);
subplot(223); imshow(p1,[]);
subplot(224); imshow(p2,[]);