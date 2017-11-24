function [ theta, xpos ] = find_match(X,MU_X,MU_Y,SIGMA_XX,SIGMA_XY,SIGMA_YY)
%FIND_MATCH Summary of this function goes here
%   Detailed explanation goes here
    theta = -1;
    xpos = -1;
    diff_star = Inf;
    [r,c] = size(MU_X);
    for i = 1:r
        for j = 1:c
            mu_x = MU_X(i,j);
            mu_y = MU_Y(i,j);
            sigma_xx = SIGMA_XX(i,j);
            sigma_xy = SIGMA_XY(i,j);
            sigma_yy = SIGMA_YY(i,j);
            diff = norm(X - [mu_x mu_y sigma_xx sigma_xy sigma_yy]);
            if diff < diff_star
                theta = i;
                xpos = j;
                diff_star = diff;
            end
        end
    end
end

