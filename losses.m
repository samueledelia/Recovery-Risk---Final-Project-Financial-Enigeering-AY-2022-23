function [Losses_D,Losses_d,Losses_i,Losses_u] = losses(Recovery,Q,FV,barrier,p,N_issuers,X,N,Losses_D,Losses_d,Losses_i,Losses_u)
% Losses function in order to compute the VaR
%
% INPUT:
% Recovery:                             recovery matrix
% Q:                                    transition matrix
% FV:                                   Face value struct
% barrier:                              quantile dist. for down grade/ up grade
% p:                                    Sensitivity of obligor’s financial condition to systematic risk factor
% N_issuers:                            Number of issuer
% X:                                    systematic risk factor realization
% N:                                    Montecarlo simualtions
% Losses_D:                             Losses to default
% Losses_d:                             Losses to dowgrade
% Losses_i:                             Losses to unchanged state
% Losses_u:                             Losses to upgrade
% 
% OUTPUT:
% Losses_D:                             Final Losses to default
% Losses_d:                             Final Losses to dowgrade
% Losses_i:                             Final Losses to unchanged state
% Losses_u:                             Final Losses to upgrade


% ...Defaulted one year from now
FV.FV3 = Recovery(:)*100;
% Fwd expected value
E_FV = FV.FV1*Q(1,1) + FV.FV2*Q(1,2) + FV.FV3*Q(1,3);

L_D = (FV.FV3 - E_FV)/N_issuers;           % Loss if default
L_d = (FV.FV2 - E_FV)/N_issuers;           % Loss if down
L_i = (FV.FV1 - E_FV)/N_issuers;           % Profit if unchanged
L_u = 0;                    % Profit if up (never)
% Generate N x 1 normal samples
X_i = randn(N,1);                               % idiosyncratic variable realization

% overall financial condition of the obligor
A = p*X +sqrt(1-p^2)*X_i;

Losses_D = L_D .* (A<barrier.D) + Losses_D;
Losses_d = L_d .* ((A>barrier.D) & (A<barrier.d)) + Losses_d;
Losses_i = L_i .* ((A>barrier.d) & (A<barrier.u)) + Losses_i;
end

