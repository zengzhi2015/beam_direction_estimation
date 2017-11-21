clc;
clear;
close all
basePath = '/home/zhi/Datasets/beam_direction/img_theta_x/';
background = imread([basePath 'background.png']);
background = double(background);

Y = 0:99;
A = []; B = []; C = []; D = []; E = [];
for i = 1:length(Y)
    theta = Y(i);
    xpos = 0;
    % read image
    imgPath = [basePath sprintf('img_%d_%d.png',theta,xpos)];
    % imgPath = [basePath sprintf('img_%d_%d.png',xpos,theta)];
    img = imread(imgPath);
    img = double(img);
    % background subtraction
    img = img - background;
    % cropping
    img = img(80:180,100:250);
    % threshold
    img(img<0) = 0;
    img(img<100) = 0;
    % convert
    img = img/65535;
    % filter
    % img = medfilt2(img,[13,13]);
    % img = imgaussfilt(img,[13,13]);
    % img = bfilter2(img,25,[25 25/2]);
    % feature extraction
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
    E(int32(theta)+1) = real(sqrt(sigma_xy));
end

X0 = [ones(length(Y),1), A',B',C',D',E'];
Y0 = Y';
[b,bint,r,rint,stats] = regress(Y0,X0);
%% 
Y_reg = X0*b;
plot(Y,Y,'g-o',Y,Y_reg,'r-o')
figure(2)
imshow(img*100)