function [ z, albedo, surfNormals ] = hw1( dir, imPref, numImages, subsetOfImages )
%HW2.1 Photometric Stero / Shape from shading
%   Call routine via 
%       z = hw1( dir, dataset, numImages)
% Input:
%    dir - full directory path to images
%    imPref - image prefix
% 
% Output:
%   z - depth map

if nargin < 4,
    subsetOfImages = 1:numImages;
end

fprintf('processing %d images from %s ...\n', length(subsetOfImages), dir);

% ================================================
% Read light directions 
% ================================================

lightFile = strcat( dir, '/lights.txt');
fid = fopen( lightFile, 'r');
numLights = fscanf(fid, '%d\n', [1]);

V = [];
for i=1:numLights
    v = fscanf(fid, '%f %f %f\n', [3]);
    v = v / norm(v);
    V(i,:) =  v;
end

% ================================================
% Read all images in RGB format 
% ================================================

filename = strcat( dir, '/', imPref, '1.bmp' );
im0 = imread( filename );
[nr,nc,dim] = size(im0);
fprintf('Number of channels=%d\n',dim);

% caches
sumImage = zeros(nr,nc,dim);
images = zeros(nr,nc,dim,numImages);
grayImages = zeros(nr,nc,numImages);
maskImage = zeros(nr,nc);

for i=1:length(subsetOfImages) %    numImages
    id = num2str(subsetOfImages(i));
    filename = strcat( dir, '/', imPref, id, '.bmp');
    im = imread( filename );
%     im = im / 255;
    im = rescale(im,0.0,1.0);
    % check dimensions
    if size(im,1) ~= nr,
        error('image dimensions do not match. Consider rescale...');
    end
    if size(im,2) ~= nc,
        error('image dimensions do not match. Consider rescale...');
    end
    if size(im,3) ~= dim,
       error('image channels do not match.');
    end
    
    for r=1:nr
        for c=1:nc
            for d=1:dim
                sumImage(r,c,d) = sumImage(r,c,d) + double(im(r,c,d));
            end
        end
    end
    
    images(:,:,:,i) = im;
    if dim ~= 1,
        grayImages(:,:,i) = rgb2gray(im);
    else
        grayImages(:,:,i) = im;
    end
end  

for r=1:nr
    for c=1:nc
        col = [];
        for d = 1:dim
            col(d) = sumImage(r,c,d);
        end
        if (any(col < 0.1) == 1),
            maskImage(r,c) = 0;
        else
            maskImage(r,c) = 1;
        end
    end
end

figure(1); clf;
imshow(maskImage,[]); title('Mask Image');
% figure(2);
% imshow(sumImage,[]); title('Sum = $$\sum_{i=1}^N I_{i}$$','interpreter','latex');
fprintf('Generated sum and mask images ...\n');

% ================================================
% Photometric Calirbations : Define Depth Map
% ================================================
z = zeros(nr,nc);

% ================================================
% Photometric Calirbations : Albedo for red
% ================================================
if dim > 1,
    [surfNormals, albedo] = normalMap( images, V, maskImage, 1,subsetOfImages);
    saveResults( surfNormals, albedo, maskImage, z, 'redChannel.dat');
end
% ================================================
% Photometric Calirbations : Albedo for green
% ================================================
if dim > 1,
    [surfNormals, albedo] = normalMap( images, V, maskImage, 2,subsetOfImages);
    saveResults( surfNormals, albedo, maskImage, z, 'greenChannel.dat');
end
    
% ================================================
% Photometric Calirbations : Albedo for blue
% ================================================
if dim > 1,
    [surfNormals, albedo] = normalMap( images, V, maskImage, 3,subsetOfImages);
    saveResults( surfNormals, albedo, maskImage, z, 'blueChannel.dat');
end

% ================================================
% Photometric Calirbations : Albedo for gray
% ================================================
[surfNormals, albedo] = normalMap( images, V, maskImage, 0,subsetOfImages);
z = depthMap(surfNormals, maskImage);
saveResults( surfNormals, albedo, maskImage, z, 'grayChannel.dat');

figure(2); clf;
surfl(z); shading interp; colormap gray;
set(gca,'projection', 'perspective');
% das = daspect;
% daspect([das(1) das(2) 2]);
lighting phong;
axis tight;
disp('done');


%------------ Utilities ------------------------------------
function saveResults(surfNormals, albedo, maskImage, z, filename)

    fid = fopen( filename,'w');
    
    [nr,nc] = size(maskImage);
    
    xind = zeros(nr,nc);
    yind = zeros(nr,nc);
    for r=1:nr
        for c=1:nc
            xind(r,c) = double(c) / double(nc);
            yind(r,c) = double(nr-r+1) / double(nr);
        end
    end

    fprintf(fid, '%d %d\n', nr, nc);
    for r=1:nr
        for c=1:nc
            nx = surfNormals(r,c,1);
            ny = surfNormals(r,c,2);
            nz = surfNormals(r,c,3);
            al = albedo(r,c);
            
            if(maskImage(r,c))
                msk = 1;
            else 
                msk = 0;
            end
            fprintf(fid, '%d %f %f %f %f %f %f %f\n', msk, ...
                        xind(r,c), yind(r,c), z(r,c), ...
                        nx, ny, nz, al );
            
        end
    end