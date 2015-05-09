function [r] = generateProfile(im)

r = zeros(size(im));
[w,h] = size(im);

% Bottom up
for i=w:-1:1
    v = 1;
    for j=1:h
        if im(i,j) > 0,
            r(i,j) = v;
            v = v+1;
        else
            r(i,j) = v;
        end
    end
end