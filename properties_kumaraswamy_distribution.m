function [KumaDistribution] = properties_kumaraswamy_distribution(BetaDistribution)
% From a beta distribution to a kumaraswamy distribution
%
% INPUT:
% BetaDistribution:                     Beta distribution with 2 parameters
%
% OUTPUT:
% KumaDistribution:                     Kumaraswamy distribution with 2 parameters

% i-th moment of the Kumaraswamy distribution
m_i = @(a,b,i) b*beta(1+i/a,b);

% Parameter estimationkuma_inv_cdf
KumaDistribution.a = BetaDistribution.alpha;
KumaDistribution.b = 1/KumaDistribution.a*(1+((KumaDistribution.a-1)/((BetaDistribution.mode)^KumaDistribution.a)));

% Main charatteristics
KumaDistribution.mean = (KumaDistribution.b*gamma(1+1/KumaDistribution.a)*gamma(KumaDistribution.b))/(gamma(1+1/KumaDistribution.a+KumaDistribution.b));
KumaDistribution.var = m_i(KumaDistribution.a,KumaDistribution.b,2) +m_i(KumaDistribution.a,KumaDistribution.b,1)^2;
KumaDistribution.mode = ((KumaDistribution.a-1)/(KumaDistribution.a*KumaDistribution.b-1))^2;
KumaDistribution.skewness =  m_i(KumaDistribution.a,KumaDistribution.b,2)/((sqrt(KumaDistribution.var))^3);
%KumaDistribution
%kuma_pdf = @(a,b,x) a.*b.*x.^(a-1).*(1-x.^a).^(b-1);
%kuma_cdf = @(a,b,x) 1-(1-x.^a).^b;
%kuma_inv_cdf= @(a,b,y) (1-(1-y).^(1/b)).^(1/a);
%KumaDistribution.kuma_inv_cdf = @(a,b,y) (1-(1-y)^(1/b))^(1/a);
end

