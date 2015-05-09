function [u,v] = OF_run(file1, file2, type, windowSize, rsize, scale)
% OF_RUN Main script to run optical flow
%  2 methods implemented
% type : 1 - patch-based, 2 - HS regularized
% quiver plot of (u,v) is shown over regions
if nargin < 2,
    type = 2;
end

if nargin < 4 || isempty(windowSize),
    windowSize = 2;
end

if nargin < 5 || isempty(rsize),
    rsize = 5;
end

if nargin < 6 || isempty(scale),
    scale = 10;
end

im1 = imread(file1);
im2 = imread(file2);

if ~isa(im1,'double');
    im1 = im2double(im1);
end

if ~isa(im2,'double');
    im2 = im2double(im2);
end

u = zeros(size(im1));
v = zeros(size(im2));
lambda = 10.5;

[Ix,Iy,It] = OF_ComputeDerivatives(im1,im2);

if type == 1, % patch-based
    halfWindowSize = floor(windowSize/2);
    % patch-based
    for i=halfWindowSize+1:size(im1,1)-halfWindowSize
        for j=halfWindowSize+1:size(im1,2)-halfWindowSize
            cx = Ix(i-halfWindowSize:i+halfWindowSize,j-halfWindowSize:j+halfWindowSize);
            cy = Iy(i-halfWindowSize:i+halfWindowSize,j-halfWindowSize:j+halfWindowSize);
            ct = -It(i-halfWindowSize:i+halfWindowSize,j-halfWindowSize:j+halfWindowSize);
            
            cx = cx';
            cy = cy';
            ct = ct';
            
            cx = cx(:);
            cy = cy(:);
            ct = ct(:);
            
            A = [cx cy];
            vel = pinv(A'*A)*A'*ct;
            %         disp(vel');
            if any(vel > 1.0e+10),
                disp(vel);
            end
            u(i,j) = vel(1);
            v(i,j) = vel(2);
        end
    end
elseif type == 2, % Horn-Schunck
    strE = [1/12 1/6 1/12;
        1/6 0 1/6;
        1/12 1/6 1/12];
    niter = 100;
    Z = 1./(lambda^2 + (Ix.^2 + Iy.^2));
    
    for it=1:niter
        
        %E = (Ix.*u + Iy.*v + It).^2 + lambda^2 * (Ix.^2 + Iy.^2)
        u_mu = conv2(u,strE,'same');
        v_mu = conv2(v,strE,'same');
        u = u_mu - (Ix .* ( ( Ix .* u_mu) + (Iy .* v_mu) + It ) ) .* Z;
        v = v_mu - (Iy .* ( ( Ix .* u_mu) + (Iy .* v_mu) + It ) ) .* Z;
    end
end
u(isnan(u)) = 0;
v(isnan(v)) = 0;

%% Enhance quiver by showing one vector per region
for i=1:size(im1,1)
    for j=1:size(im1,2)
        if floor(i/rsize) ~= i/rsize || floor(j/rsize) ~= j/rsize,
            u(i,j) = 0;
            v(i,j) = 0;
        end
    end
end

imshow(im1,[]); hold on;
quiver(u,v,scale,'linewidth',2);
if type == 1,
    title('Optical Flow : Patch-based');
elseif type == 2,
     title('Optical Flow : Horn Schunck regularized');
end