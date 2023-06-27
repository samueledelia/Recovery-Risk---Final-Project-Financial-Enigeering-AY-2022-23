function [VaR] = VaR(q,p,N,N_issuers,X,Z_i,Distribution,alpha,RM,flag,flag2)
% VaR function
%
% INPUT:
% q:                    Sensitivity of obligor’s collateral to systematic risk factor
% p:                    Sensitivity of obligor’s financial condition to systematic risk factor
% N:                    Montecarlo simualtions
% N_issuers:            Number of issuer
% X:                    systematic risk factor realization
% Z_i:                  idiosyncratic risk factor realization
% Distribution:         Beta or Kuma distribution parameters
% alpha:                insolvency target
% RM:                   Struct containing the information from CASE 3 RM
% flag:                 1: stochastic recovery rate/ 2: deterministic recovery rate
% flag2:                1: beta distr./ 2: kuma. distr.
%
% OUTPUT:
% VaR:                  value at risk

% Let's simulate the recovery values
[Recovery] = recovery(q,Distribution,X,Z_i,flag,flag2);

% % Function that computes the VaR
% ZC_curve = [1.0 0.05; 2.0 0.05];
% 
% % Rating transition matrix
% Q = [0.5281	0.4619	0.0100;
%      0.3500	0.6000	0.0500;
%      0.0000	0.0000	1.0000];                       
%  
% % Two year bond IG
% IG_cf_schedule_2y = [0.5 0.0; 1.0 0.0; 1.5 0.0; 2.0 100.0];
% 
% % IG Z-spread (scalar, corresponding to a 2y bond)
% IG_z_2y = 115/10000;
% 
% % IG 1y fwd Z-spread (scalar, corresponding to a 1y bond)
% IG_z_1y = 60/10000;
% 
% % HY 1y fwd Z-spread (scalar, corresponding to a 1y bond)
% HY_z_1y = 300/10000;

%% Let's start with all bonds rated IG... (uncomment if needed)

% ...Investment grade one year from now
% IG_cf_schedule_1y = [0.5 0.0; 1.0 100.0];
P1 = exp(-(RM.ZC_curve(1,2)+RM.IG_z_1y)*RM.ZC_curve(1,1));
P2 = exp(-(RM.ZC_curve(1,2)+RM.IG_z_1y)*RM.ZC_curve(2,1));
FV.FV1 =P2/P1*100; 
% ...High Yield one year from now...
P3 = exp(-(RM.ZC_curve(1,2)+RM.IG_z_1y)*RM.ZC_curve(1,1));
P4 = exp(-(RM.ZC_curve(1,2)+RM.IG_z_1y)*RM.ZC_curve(1,1) - (RM.ZC_curve(2,2)+RM.HY_z_1y)*(RM.ZC_curve(2,1)-RM.ZC_curve(1,1)));
FV.FV2 = P4/P3*100;
%% Barriers and simulated P/L for a single IG issuer 
barrier.D = norminv(RM.Q(1,3),0,1);       % Barrier to Def.
barrier.d =  norminv(RM.Q(1,2)+RM.Q(1,3),0,1);    % Barrier to down (HY)
barrier.u = 1.0e6;                 % Barrier to up (never)

%% Idiosynchratic Montecarlo
Losses_D = zeros(N,1);
Losses_d = zeros(N,1);
Losses_i = zeros(N,1);
Losses_u = zeros(N,1);

[Losses_D,Losses_d,Losses_i,Losses_u] = arrayfun(@(i) losses(Recovery(:,i),RM.Q,FV,barrier,p,N_issuers,X,N,Losses_D,Losses_d,Losses_i,Losses_u),1:N_issuers,'un',0);


Total_Losses = sum(cell2mat(Losses_D),2) + sum(cell2mat(Losses_d),2) + sum(cell2mat(Losses_i),2);
VaR = -quantile(Total_Losses,alpha);

end

