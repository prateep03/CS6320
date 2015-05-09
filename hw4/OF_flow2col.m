function [ img ] = OF_flow2col( flow )
%FLOW2COL Codes flow vector in a flow vector field

MAX_FLOW_THRESH = 1e7;

[h,w,nb] = size(flow);

if nb ~= 2,
    error('flow must have 2 bands');
end

u = flow(:,:,1);
v = flow(:,:,2);

% maxu = -Inf; maxv = -Inf;
% minu = Inf; minv = Inf;

junk = (abs(u) > MAX_FLOW_THRESH) | (abs(v) > MAX_FLOW_THRESH);
u(junk) = 0;
v(junk) = 0;

maxu = max(u(:)); 
maxv = max(v(:));
minu = min(u(:));
minv = min(v(:));

r = sqrt(u.^2 + v.^2);
maxr = max(r(:));

fprintf('max flow : %.4f, flow range : u = (%.4f, %.4f), v = (%.4f, %.4f)\n',maxr, minu,maxu,minv,maxv);

u = u ./ (maxr+eps);
v = v ./ (maxr+eps);

img = OF_computeColor(u,v);
img(repmat(junk,[1 1 3])) = 0; % ignore junk indices. (To make flow field look better)

function [img] = OF_computeColor(u,v)
% OF_COMPUTECOLOR Computes colormap 
nanidx = isnan(u) | isnan(v);
u(nanidx) = 0;
v(nanidx) = 0;

%   adapted from the color circle idea described at
%   http://members.shaw.ca/quadibloc/other/colint.htm
cwheel =   [255     0     0;
   255    17     0;
   255    34     0;
   255    51     0;
   255    68     0;
   255    85     0;
   255   102     0;
   255   119     0;
   255   136     0;
   255   153     0;
   255   170     0;
   255   187     0;
   255   204     0;
   255   221     0;
   255   238     0;
   255   255     0;
   213   255     0;
   170   255     0;
   128   255     0;
    85   255     0;
    43   255     0;
     0   255     0;
     0   255    63;
     0   255   127;
     0   255   191;
     0   255   255;
     0   232   255;
     0   209   255;
     0   186   255;
     0   163   255;
     0   140   255;
     0   116   255;
     0    93   255;
     0    70   255;
     0    47   255;
     0    24   255;
     0     0   255;
    19     0   255;
    39     0   255;
    58     0   255;
    78     0   255;
    98     0   255;
   117     0   255;
   137     0   255;
   156     0   255;
   176     0   255;
   196     0   255;
   215     0   255;
   235     0   255;
   255     0   255;
   255     0   213;
   255     0   170;
   255     0   128;
   255     0    85;
   255     0    43];

ncol = size(cwheel,1);

rad = sqrt(u.^2 + v.^2);
ang = atan2(-v, -u) / pi;

fk = (ang+1) / 2 * (ncol-1) + 1;
k0 = floor(fk);

k1 = k0 + 1;
k1(k1 == ncol+1) = 1;

f = fk - k0;

for i = 1:size(cwheel,2)
    tmp = cwheel(:,i);
    col0 = tmp(k0)/255;
    col1 = tmp(k1)/255;
    col = (1-f).*col0 + f.*col1;   
   
    idx = rad <= 1;   
    col(idx) = 1-rad(idx).*(1-col(idx));    % increase saturation with radius
    
    col(~idx) = col(~idx)*0.75;             % out of range
    
    img(:,:, i) = uint8(floor(255*col.*(1-nanidx)));         
end;    
