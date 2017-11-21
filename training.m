clc;
clear;
basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';

Y = 0:99;
A = []; B = []; C = []; D = []; E = [];
for theta = Y
    xpos = 0;
    imgPath = [basePath sprintf('img_%d_%d.png',theta,xpos)];
    img = imread(imgPath);
    img = double(img);
    [m,n]=size(img);
    s = sum(sum(img));
    x = linspace(0,n-1,n);
    y = linspace(0,m-1,m);
    mu_x = sum(img*x')/s;
    mu_y = sum(y*img)/s;
    sigma_xx = sum(img*((x-mu_x).^2)')/s;
    sigma_yy = sum((y-mu_y).^2*img)/s;
    sigma_xy = (y-mu_y)*img*(x-mu_x)'/s;
    A(int32(theta)+1) = mu_x;
    B(int32(theta)+1) = mu_y;
    C(int32(theta)+1) = sqrt(sigma_xx);
    D(int32(theta)+1) = sqrt(sigma_yy);
    E(int32(theta)+1) = sqrt(sigma_xy);
end

X0 = [ones(length(Y),1), A',B',C',D',E'];
Y0 = Y';
[b,bint,r,rint,stats] = regress(Y0,X0);
%% 
Y_reg = X0*b;
plot(Y,Y,'g-o',Y,Y_reg,'r-o')