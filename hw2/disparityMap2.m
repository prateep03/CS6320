function [ res ] = disparityMap2( I1, I2, opt )
%DISPARITY_MAP Summary of this function goes here
%   Detailed explanation goes here

opt.null = 0;

if nargin < 3, % default options
    opt.windowSize = 3;
    opt.metric     = 'SSD';
    opt.mins       = 1;
    opt.maxs       = 20;
end

if ~isfield(opt,'mins'), 
    opt.mins = 1;
end

if ~isfield(opt,'maxs'),
    opt.maxs = 20;
end

opt.blockSize = 1;
if opt.windowSize > 1,
    opt.blockSize = (opt.windowSize - 1) / 2;
end

tol = 0;
if isfield(opt,'tol'),
    tol = opt.tol;
end

if isempty(I1),
    error('I1 empty');
end

if isempty(I2),
    error('I2 empty');
end

if size(I1,1)~=size(I2,1) || size(I1,2)~=size(I2,2) || size(I1,3)~=size(I2,3),
    error('dimension mismatch');
end

[dimy,dimx,c] = size(I1);
[xx,yy] = meshgrid(1:size(I1,2),1:size(I1,1));

res = ones(dimy,dimx);

% -- determine pixel correspondence Right-to-Left
[disparity1,mindiff1] = slide_images(I1,I2,opt.mins,opt.maxs,opt.windowSize);

% -- determine pixel correspondence Left-to-Right
[disparity2,mindiff2] = slide_images(I2,I1,-opt.mins,-opt.maxs,opt.windowSize);
disparity2 = abs(disparity2);

res = winner_take_all(disparity1, mindiff1, disparity2, mindiff2, tol);

res(res == inf) = NaN;

%% ----- UTITLITY

function [disparity,mindiff] = slide_images(I1,I2, mins, maxs, win_size)
    [dimy,dimx,c] = size(I1);
    disparity = zeros(dimy,dimx);
    mindiff = inf(dimy,dimx);
    w = 5;
    hx = [-1 0 1]; hy = [-1 0 1]'; % -- gradient filter
    h = 1/win_size.^2 * ones(win_size); % -- averaging filter
    
    g1x = sum(imfilter(I1,hx).^2,3);
    g1y = sum(imfilter(I1,hy).^2,3);
    g2x = sum(imfilter(I2,hx).^2,3);
    g2y = sum(imfilter(I2,hy).^2,3);
    
    step = sign(maxs - mins); % adjust for reverse slide
    for i=mins:step:maxs
        s = shift_image(I2,i);
        sx = shift_image(g2x,i);
        sy = shift_image(g2y,i);
       
        diffs = sum(ncc2(I1,s),3);
        CNCC = imfilter(diffs,h); % -- average 
        gdiff = w * (sum(abs(g1x-sx),3) + sum(abs(g1y-sy),3));
        CGRAD = imfilter(gdiff,h);
        d = CNCC + CGRAD;
        
        idx = find(d < mindiff);
        disparity(idx) = i;
        mindiff(idx) = d(idx);
    end
    
function I = shift_image(I,shift)
    dimx = size(I,2);
    if shift > 0,
        I(:,shift:dimx,:) = I(:,1:dimx-shift+1,:);
        I(:,1:shift-1,:) = 0;
    elseif shift < 0,
        I(:,1:dimx+shift+1,:) = I(:,-shift:dimx,:);
        I(:,dimx+shift+1:dimx,:) = 0;
    end
    
function [pd] = winner_take_all(d1,m1,d2,m2,tol)
    if nargin < 5, tol = 0; end
    [dimy,dimx] = size(d1);
    d3 = zeros(size(d1));
    m3 = zeros(size(d1));
    
    for i=1:max(d1(:))
        [yy,xx] = find(d2 == i); % -- get all disparities i
        idx2 = sub2ind([dimy,dimx],yy,xx);
        xx = xx + i - 1;         % -- get new position
        xx(xx > dimx) = dimx;    % -- boundary condition
        idx3 = sub2ind([dimy,dimx],yy,xx);
        d3(idx3) = d2(idx2);
        m3(idx3) = m2(idx2);
    end
    
    % -- keep best ones and mark bad ones
    pd = d3;
    idx = find(m1 < m3);
    pd(idx) = d1(idx);
    diff(idx) = m1(idx);
    idx = find(m1 == m3);
    pd(idx) = round(d1(idx) + d3(idx))/2;
    
    pd(abs(d1-d3) > tol) = inf;
    
function [I,t]=ncc2(V,U)
    if isequal(class(V),'uint8'), V = im2double(V); end
    if isequal(class(U),'uint8'), U = im2double(U); end
    Vvar=V-mean(V(:)); Uvar=U-mean(U(:));
    I=(Vvar.*Uvar)/((sqrt(sum(Vvar(:).^2))*sqrt(sum(Uvar(:).^2)))+eps);
    t=sum(I(:));    