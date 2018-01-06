function k_K = f_K_regression( K,D )
%F_K_REGRESSION Summary of this function goes here
%   Regression of K on D
    X_D = [ones(length(D),1), D];
    Y_D = K;

    [k_K,~,r_K,~,~] = regress(Y_D,X_D);
    Y_D_reg = X_D*k_K;
    
    figure('Name','Box plot of abs(r_K)/abs(K)','NumberTitle','off')
    boxplot(100*abs(r_K)./abs(K))
    ylabel('percentage of deviation (%)')
    %% Plot regression
    figure('Name','Distribution of K','NumberTitle','off')
    plot(D,Y_D_reg,'-*');
    xlabel('D (mm)')
    ylabel('K (rad/pixel)')
    hold on
    plot(D,Y_D','o');
    hold off

end

