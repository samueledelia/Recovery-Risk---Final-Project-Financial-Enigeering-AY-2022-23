function [Recovery] = recovery(q,Distribution,X,Z_i,flag,flag2)
% Recovery value simulation according to Credit Capital Model
%
% INPUT:
% q:                            Sensitivity of obligor’s collateral to systematic risk factor
% Distribution:                 Distribution of the recovery rates
% X:                            sistematic risk factor
% Z_i:                          idiosyncratic risk factor
% flag:                         1: stochastic recovery rate/ 2: deterministic recovery rate
% flag2:                        1: beta distr./ 2: kuma. distr.
%
% OUTPUT:
% Recovery:                     Recovery value N x N_issuer

switch flag
    case 1
        %Recovery = zeros(size(Z_i,1),size(Z_i,2));
        C = q*X +sqrt(1-q^2)*Z_i;
        % Recovery computations
        switch flag2
            case 1
                Recovery = betainv(normcdf(C),Distribution.alpha,Distribution.beta);
            case 2
                kuma_inv_cdf= @(a,b,y) (1-(1-y).^(1/b)).^(1/a);
                Recovery = kuma_inv_cdf(Distribution.a,Distribution.b,normcdf(C));
        end
    case 2
        Collateral = Distribution.mean;
        Recovery = ones(1,size(Z_i,2))*min(1, Collateral);
end

