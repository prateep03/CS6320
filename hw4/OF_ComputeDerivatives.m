function [ Ix,Iy,It ] = OF_ComputeDerivatives( im1,im2 )
%ComputeDerivatives Compute x,y and t derivatives of two gray-scale images

[m,n,p] = size(im1);
if size(im2,1) ~= m || size(im2,2) ~= n || size(im2,3) ~= p,
    error('input images are not the same size');
end

if p > 1,
    error('only grayscale images are processed');
end

im1 = imgaussian(im1,2.5,3);
im2 = imgaussian(im2,2.5,3);

s = 2;
Fx = conv2(im1,s * [-1 1; -1 1]) + conv2(im2, s * [-1 1; -1 1]); % edge in X
Fy = conv2(im1,s * [-1 -1; 1 1]) + conv2(im2, s * [-1 -1; 1 1]); % edge in Y
Ft = conv2(im1, s*ones(2)) - conv2(im2, s*ones(2));              % time gradient

Ix = Fx(2:size(Fx,1), 2:size(Fx,2));
Iy = Fy(2:size(Fy,1), 2:size(Fy,2));
It = Ft(2:size(Ft,1), 2:size(Ft,2));

disp('Derivatives computed');
