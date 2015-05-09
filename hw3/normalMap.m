function [ surfNormals, albedo ] = normalMap( images, V, maskImage, channel, subsetOfImages )
%NORMALMAP Routine to generate surface normals given images captured using
%            different light sources(>= 3)
%   Detailed explanation goes here

nr = size(images,1);
nc = size(images,2);
dim = size(images,3);
numImages = size(images,4);

if nargin < 5,
    subsetOfImages = 1:size(images,4);
end

surfNormals = zeros(nr,nc,3);
albedo      = zeros(nr,nc);

for r=1:nr
    for c=1:nc
        surfNormals(r,c,1) = 0.0;
        surfNormals(r,c,2) = 0.0;
        surfNormals(r,c,3) = 1.0;
    end
end

if channel == 0,
    for r=1:nr
        for c=1:nc
            if(maskImage(r,c) )
                for i=1:length(subsetOfImages)
                    ind = subsetOfImages(i);
                    I(ind) = double(images(r,c,1,ind));
                    VV(ind,:) = V(ind,:);
                end
                [NP,R,ok] = pixelNormal(I, VV);
                surfNormals(r,c,1) = NP(1);
                surfNormals(r,c,2) = NP(2);
                surfNormals(r,c,3) = NP(3);
                albedo(r,c)        = R;
            end
        end
    end
end

if channel > 0,
    for r=1:nr
        for c=1:nc
            if(maskImage(r,c) )
                for i=1:numImages
                    I(i) = double(images(r,c,channel,i));
                end
                [NP,R,ok] = pixelNormal(I, V);
                surfNormals(r,c,1) = NP(1);
                surfNormals(r,c,2) = NP(2);
                surfNormals(r,c,3) = NP(3);
                albedo(r,c)        = R;
            end
        end
    end
end
    
% normalize albedo to [0,1]
maxal = max(albedo(:));
if maxal > 0,
    albedo = albedo / maxal;
end

%---------------------------------------------
function [N,R,ok] = pixelNormal(I, L)

    ok = 1;
    I = I';
    LT = L';
    A = LT * L;
    b = LT*I;
    g = pinv(A)*b;
    R = norm(g);
    N = g/R;
    
    if norm(I) < eps,
        warning('Pixel intensity is zero');
        N(1) = 0.0;
        N(2) = 0.0;
        N(3) = 0.0;
        R    = 0.0;
        ok   = 0;
    end

%---------------------------------------------