function [ res ] = disparityMap( I1, I2, opt )
%DISPARITY_MAP Summary of this function goes here
%   Detailed explanation goes here

opt.null = 0;

if nargin < 3, % default options
    opt.windowSize = 3;
    opt.metric     = 'SSD';
end

opt.blockSize = 1;
if opt.windowSize > 1,
    opt.blockSize = (opt.windowSize - 1) / 2;
end

if ~isfield(opt,'metric'),
    opt.metric = 'SSD';
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

[m,n,p] = size(I1);

% row-scan algorithm
res = zeros(m,n);
for x=1:m % every row
    for y=1:n % every col
        res(x,y) = computeD(I1,I2,p,x,y,m,n,opt);
    end
end


function res = computeD(I1,I2,dim,row,col,height,width,opt)
    opt.null = 0;
    bs = opt.blockSize;
    if bs < 1,
        error('non-integer blockSize');
    end
    
    ret = [];
    for dx=-bs:bs
        for dy=-bs:bs
           rr = row + dx;
           cc = col + dy;
           if ~valid(rr,cc,height,width),
               continue;
           end
           ret = [ret; calc(I1,I2,dim,row,col,rr,cc,opt)];
        end
    end
    res = norm(ret);

    
function r = calc(I1,I2,dim,r1,c1,r2,c2,opt)
    opt.null = 0;
    r = 0;
    switch opt.metric
        case 'SSD',
            for d=1:dim
                r = r + (I1(r1,c1,d) - I2(r2,c2,d))^2;
            end
            r = r / dim;
        case 'NCC',
        otherwise,
            error([opt.metric, ' not supported.']);
    end
    
function ok = valid(r,c,h,w)
   ok = 1;
   if or( or(c < 1, c > w ) ,or(r < 1, r > h)),
       ok = 0;
   end