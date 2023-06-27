function [BetaDistribution] = properties_beta_distribution(mean,var)
% Function that extract the properties of a beta distribution
%
% INPUT:
% mean:                         mean of the beta distribution
% var:                          variance of the beta distribution
%
% OUTPUT:
% BetaDistribution:             struct with the beta parameters and charat.

% Parameter estimation thought method of moments
alpha = ((mean*(1-mean)/var)-1)*mean;
beta = ((mean*(1-mean)/var)-1)*(1-mean);

% Main charatteristics
switch true
    case alpha>1 && beta>1
        mode = (alpha-1)/(alpha+beta-2);
    case alpha<1 && beta<1
        mode = [0 1];
    case alpha<=1 && beta>1
        mode = 0;
    case alpha>1 && beta<=1
        mode = 1;
end
skewness = (2*(beta-alpha)*sqrt(alpha+beta+1))/((alpha+beta+2)*sqrt(alpha+beta));
kurtosis = 6*((alpha-beta)^2*(alpha+beta+1)-alpha*beta*(alpha+beta+2))/(alpha*beta*(alpha+beta+2)*(alpha+beta+3));

% Output
BetaDistribution.alpha = alpha;
BetaDistribution.beta = beta;
BetaDistribution.mean = mean;
BetaDistribution.var = var;
BetaDistribution.mode = mode;
BetaDistribution.skewness = skewness;
BetaDistribution.kurtosis = kurtosis;
end

