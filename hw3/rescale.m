function y = rescale(x,a,b)

% rescale - rescale data in [a,b]
%
%   y = rescale(x,a,b);
%

if nargin<2
    a = 0;
end
if nargin<3
    b = 1;
end

m = min(x(:));
M = max(x(:));

% y = x / 255;

if M-m<eps
    y = x;
else
    y = (b-a) * (x-m)/(M-m) + a;
end


