clear all;
close all;

%% world coordinates in cms
Wz = zeros(1,60);
Wx = zeros(1,60);
Wy = zeros(1,60);
% z
Wz(1:6) = 7*2.8;  Wz(31:36) = 7*2.8;
Wz(7:12) = 6*2.8; Wz(37:42) = 6*2.8;
Wz(13:18) = 5*2.8; Wz(43:48) = 5*2.8;
Wz(19:24) = 4*2.8; Wz(49:54) = 4*2.8;
Wz(25:30) = 3*2.8; Wz(49:54) = 3*2.8;
% y
Wy(31:6:60) = 0.9 + 1*2.8;
Wy(32:6:60) = 0.9 + 2*2.8;
Wy(33:6:60) = 0.9 + 3*2.8;
Wy(34:6:60) = 0.9 + 4*2.8;
Wy(35:6:60) = 0.9 + 5*2.8;
Wy(36:6:60) = 0.9 + 6*2.8;
% x
Wx(1:6:30) = 0.9 + 6*2.8;
Wx(2:6:30) = 0.9 + 5*2.8;
Wx(3:6:30) = 0.9 + 4*2.8;
Wx(4:6:30) = 0.9 + 3*2.8;
Wx(5:6:30) = 0.9 + 2*2.8;
Wx(6:6:30) = 0.9 + 1*2.8;

%% Image coords
Ix = [0.4020 0.5177 0.6333 0.7365 0.8294 0.9202 0.4062 0.5218 0.6333 0.7386 ...
0.8294 0.9202 0.4124 0.5239 0.6333 0.7365 0.8273 0.9202 0.4144 0.5300 ...
0.6312 0.7324 0.8315 0.9202 0.4144 0.5280 0.6353 0.7324 0.8294 0.9161 ...
1.1700 1.2712 1.3724 1.4942 1.6119 1.7419 1.1659 1.2650 1.3724 1.4859 ...
1.6057 1.7337 1.1618 1.2588 1.3662 1.4818 1.5995 1.7275 1.1577 1.2547 ...
1.3620 1.4735 1.5912 1.7171 1.1535 1.2506 1.3538 1.4694 1.5850 1.7130] * 1000; % 60x1

Iy = [0.4222 0.4168 0.4168 0.4141 0.4168 0.4195 0.5731 0.5677 0.5570 0.5543 ...
0.5489 0.5462 0.7213 0.7079 0.6998 0.6863 0.6782 0.6701 0.8696 0.8534 ...
0.8345 0.8210 0.8076 0.7941 1.0124 0.9908 0.9720 0.9504 0.9342 0.9181 ...
0.4195 0.4222 0.4276 0.4276 0.4330 0.4384 0.5435 0.5516 0.5597 0.5704 ...
0.5785 0.5866 0.6728 0.6836 0.6917 0.7052 0.7186 0.7348 0.7968 0.8103 ...
0.8237 0.8399 0.8588 0.8722 0.9181 0.9342 0.9531 0.9720 0.9908 1.0151] * 1000; % 60x1

num = 60;
P(1:2*num, 1:12) = 0;
k = 1;
for i=1:2:120
    P(i,1) = Wx(k); P(i+1,5) = Wx(k);
    P(i,2) = Wy(k); P(i+1,6) = Wy(k);
    P(i,3) = Wz(k); P(i+1,7) = Wz(k);
    P(i,4) = 1; P(i+1,8) = 1;
    P(i,9:12) = -P(i,1:4) * Ix(k);
    P(i+1,9:12) = -P(i,1:4) * Iy(k);
    k=k+1;
end

[U,S,V] = svd(P,'econ');
S_ = S(1:12,1:12);
[minm, ind] = min(diag(S_));

m = V(1:12,ind);
m_canonical = m / norm(m(9:11));
M(1,1:4) = m_canonical(1:4);
M(2,1:4) = m_canonical(5:8);
M(3,1:4) = m_canonical(9:12);

a1 = M(1,1:3);
a2 = M(2,1:3);
a3 = M(3,1:3);
b = M(1:3,4);

% computing intrinsic params
u_0 = a1*a3';
v_0 = a2*a3';
theta = acos(-cross(a1,a3) * cross(a2,a3)' / ( norm(cross(a1,a3)) * norm(cross(a2,a3)) ) ); 
alpha = norm( cross(a1,a3) ) * sin( theta );
beta = norm( cross(a2,a3) ) * sin( theta );

% computing extrinsic params
r1 = cross(a2,a3) / norm(cross(a2,a3));
r2 = cross(a3, r1);
r3 = a3;
K = [alpha -alpha * cot(theta) u_0; 
     0       beta / sin(theta) v_0; 
     0               0          1];

% translation
t = K \ b;
% rotation
R(1,1:3) = r1;
R(2,1:3) = r2;
R(3,1:3) = r3;

%% Test estimated parameters by reconstructing error for 3 new points
% image coords
test_Ix = [0.5177 0.7365 1.2485] * 1000;
test_Iy = [0.2740 0.2794 1.0609] * 1000;
% world corrds
test_Wx = [0.9+5*2.8 0.9+3*2.8 0 0];
test_Wy = [0 0 0.9+2*2.8 0.9+3*2.8];
test_Wz = [8*2.8 8*2.8 2*2.8 2*2.8];
% reconstruct image coords and calculate estimation error
for i=1:3
    t = [test_Wx(i) test_Wy(i) test_Wz(i) 1]; % homogenous
    I = M * t';
    % transform to cartesian coords
    Rx(i) = I(1) / I(3);
    Ry(i) = I(2) / I(3);
    errEst(i) = sqrt( (Rx(i) - test_Ix(i)) * (Rx(i) - test_Ix(i)) + ...
                        (Ry(i) - test_Iy(i)) * (Ry(i) - test_Iy(i)));
end

fprintf('Theta : %f\n', rad2deg(theta) );
fprintf('u_0 : %f, v_0 : %f\n',u_0, v_0);
fprintf('alpha : %f, beta : %f\n',alpha, beta);
R
t
disp('Reconstruction error');
for i=1:3
    fprintf('%d : %.5f\n',i,errEst(i));
end
