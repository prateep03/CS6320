function pts = pointsOnLine(line, im)

if length(line) ~= 3,
    error('line not in appropriate form. Should be in [cosine sin rho]');
end

cosine_phi = line(1); 
sin_phi    = line(2);
rho        = line(3);

if round((cosine_phi^2 + sin_phi^2) / 1e-8) * 1e-8 ~= 1,
    fprintf('%f\n', cosine_phi^2 + sin_phi^2);
    error('line parmeters incorrect.');
end

[m,n,z] = size(im);
pts = [];
for x=1:m
    for y=1:n
%         fprintf('%f %f\n',(x*cosine_phi + y*sin_phi), rho);
        if dist( (x*cosine_phi + y*sin_phi), -rho) < 0.01,
            pts = [pts; x y];
        end
    end
end