%% RECOVERY RISK
% Final Project RM5A Financial Engineering - A.Y. 2022-2023
% D'Elia Samuele (samuele.delia@mail.polimi.it)
% Soatto Silvia (silvia.soatto@mail.polimi.it)

clear
close all
clc
%% Senior Secured Bank loans statistics
% Those statistics are taken from the secondary market price quotes of bank loans one month after the time of default
sec.count = 119;                                    % number of defaulted bank loans
sec.avarage = 69.5;                                 % arithmetic avarage
sec.median = 74.0;                                  % median
sec.max = 98.0;                                     % maximum
sec.perc_10th = 39.2;                               % 10th percentile
sec.min = 15.0;                                     % minumun
sec.std = 22.5;                                     % standard deviation
%% Senior Unsecured Bank loans statistics
unsec.count = 33;
unsec.avarage = 52.1;
unsec.median = 50.0;
unsec.max = 88.0;
unsec.perc_10th = 5.8;
unsec.min = 5.0;
unsec.std = 28.6;
%% 1. Calibrate beta distribution to the empirical distribution of defaulted bank loans
% We will refer to Secured Bank loans as 1 and Unsecured Bank loans as 2
% Normalize the statistics in the range [0,1]

mean_1 = sec.avarage/100;                           % Sample mean normalized
var_1 = (sec.std/100)^2;                            % Sample variance normalized
mean_2 = unsec.avarage/100;
var_2 = (unsec.std/100)^2;

% Beta properties
[BetaDistribution_1] = properties_beta_distribution(mean_1,var_1);
[BetaDistribution_2] = properties_beta_distribution(mean_2,var_2);

% similarities and differences of the two distributions
plot_distributions(BetaDistribution_1,BetaDistribution_2,1);
%% 2. MC Simulation of Recovery Rates with Credit capital model
rng(1)
% DATASET FROM CASE 3 RM
RM.ZC_curve = [1.0 0.05; 2.0 0.05];

% Rating transition matrix
RM.Q = [0.5281	0.4619	0.0100;
     0.3500	0.6000	0.0500;
     0.0000	0.0000	1.0000];                       
 
% Two year bond IG
RM.IG_cf_schedule_2y = [0.5 0.0; 1.0 0.0; 1.5 0.0; 2.0 100.0];

% IG Z-spread (scalar, corresponding to a 2y bond)
RM.IG_z_2y = 115/10000;

% IG 1y fwd Z-spread (scalar, corresponding to a 1y bond)
RM.IG_z_1y = 60/10000;

% HY 1y fwd Z-spread (scalar, corresponding to a 1y bond)
RM.HY_z_1y = 300/10000;

RM.IG_cf_schedule_1y = [0.5 0.0; 1.0 100.0];

% flag
flag_stochastic = 1;                                  % 1: stochastic recovery rate
flag_det = 2;                                         % 2: deterministic recovery rate
flag_beta = 1;                                        % 1: we use beta distr.
flag_kuma = 2;                                        % 2: we use kuma. distr.

% Target insolvency
alpha = 0.001;

% Minimum number of Monte Carlo Scenarios
N = 100000;

% Number of issuers in portfolio
N_issuers = 119;                                      % Based on the paper

% Generate N standard 1-d normal variables (macro-factor) and N x N_issuer
X = randn(N,1);                                       % systematic risk factor realization
Z_i = randn(N,N_issuers);                             % idiosyncratic risk factor realization
%% 3. Credit Portfolio VaR (BASE CASE)
tic
% Loading term/ Sensitivity of obligor’s collateral to systematic risk factor
q = 0.5;
% Sensitivity of obligor’s financial condition to systematic risk factor
p = 0.5;
[VaR_BaseCase_beta] = VaR(q,p,N,N_issuers,X,Z_i,BetaDistribution_1,alpha,RM,flag_stochastic,flag_beta);
disp('––– Credit VaR BASE CASE (p=q=0.5) –––')
fprintf('Credit VaR: %.2f \n', VaR_BaseCase_beta)
disp(' ')
toc
%% 4. Credit Portfolio VaR calculation (ALTERNATIVE CASE)
p = 0.5;
q = 0; 
[VaR_CreditMetrics_beta] = VaR(q,p,N,N_issuers,X,Z_i,BetaDistribution_1,alpha,RM,flag_stochastic,flag_beta);
disp('––– Credit VaR CREDIT METRICS (p=0.5, q=0) –––')
fprintf('Credit VaR: %.2f \n', VaR_CreditMetrics_beta)
disp(' ')
%% Std of the beta in null
mean_3 = sec.avarage/100;
BetaDistribution_3.mean = mean_3;
p = 0.5;
q = 0; 
[VaR_CreditRisk_beta] = VaR(q,p,N,N_issuers,X,Z_i,BetaDistribution_3,alpha,RM,flag_det,flag_beta);
disp('––– Credit VaR CREDIT RISK+ (p=0.5, sigma=0) –––')
fprintf('Credit VaR: %.2f \n', VaR_CreditRisk_beta)
disp(' ')
%% 5. Chart of the Credit Portfolio VaR in dependence of the sensitivity of obligor’s
p_grid = [0:0.1:0.5];
q_grid = p_grid;
% Compute the vector VaR + plot
[VaR_BaseCase_chart_beta] =arrayfun(@(i) VaR(q_grid(i),p_grid(i),N,N_issuers,X,Z_i,BetaDistribution_1,alpha,RM,flag_stochastic,flag_beta),1:length(p_grid),'un',0);
plot_VaR(p_grid,VaR_BaseCase_chart_beta,[],flag_beta)


%% Focus on initial interval p=[0, 0.15]
p_grid_1 = [0:0.025:0.15];
q_grid_1 = p_grid_1;
% Compute the vector VaR + plot
[VaR_BaseCase_chart_focus] =arrayfun(@(i) VaR(q_grid_1(i),p_grid_1(i),N,N_issuers,X,Z_i,BetaDistribution_1,alpha,RM,flag_stochastic,1),1:length(p_grid_1),'un',0);
plot_VaR(p_grid_1,VaR_BaseCase_chart_focus,[],flag_beta);
% Create the increment of the VaR with step 0.025
p_i = p_grid_1(1:end-1);
p_f = p_grid_1(2:end);
incremets = cell2mat(VaR_BaseCase_chart_focus(2:end))-cell2mat(VaR_BaseCase_chart_focus(1:end-1));
T = table(p_i',p_f',incremets','VariableNames', {'p_inf', 'p_sup', 'increment = VaR(p_sup)-VaR(p_inf)'});
% Display the Table
disp(T);




%% 6.0 A beta-like distribution 
% We re-do all the computations with the Kumaraswamy distridution, that is
% distribution similat to a beta but much simpler
% With this distribution we are able to reduce the computational time
[KumaDistribution] = properties_kumaraswamy_distribution(BetaDistribution_1);
plot_distributions(BetaDistribution_1,KumaDistribution,2);

%% 6.1 Credit Portfolio VaR (BASE CASE)
tic
% Loading term/ Sensitivity of obligor’s collateral to systematic risk factor
q = 0.5;
% Sensitivity of obligor’s financial condition to systematic risk factor
p = 0.5;
[VaR_BaseCase_kuma] = VaR(q,p,N,N_issuers,X,Z_i,KumaDistribution,alpha,RM,flag_stochastic,flag_kuma);
disp('––– Credit VaR BASE CASE (p=q=0.5) Kuma distr.–––')
fprintf('Credit VaR: %.2f \n', VaR_BaseCase_kuma)
disp(' ')
toc
%% 6.2 Credit Portfolio VaR calculation (ALTERNATIVE CASE)
p = 0.5;
q = 0; 
[VaR_CreditMetrics_kuma] = VaR(q,p,N,N_issuers,X,Z_i,KumaDistribution,alpha,RM,flag_stochastic,flag_kuma);
disp('––– Credit VaR CREDIT METRICS (p=0.5, q=0) Kuma distr.–––')
fprintf('Credit VaR: %.2f \n', VaR_CreditMetrics_kuma)
disp(' ')
%% 6.3 Std of the kuma is null
mean_3 = sec.avarage/100;
KumaDistribution_2.mean = mean_3;                           % this is the only parameter we are interest in
p = 0.5;
q = 0; 
[VaR_CreditRisk_kuma] = VaR(q,p,N,N_issuers,X,Z_i,KumaDistribution_2,alpha,RM,flag_det,flag_kuma);
disp('––– Credit VaR CREDIT RISK+ (p=0.5, sigma=0) Kuma distr.–––')
fprintf('Credit VaR: %.2f \n', VaR_CreditRisk_kuma)
disp(' ')
%% 6.4 Chart of the Credit Portfolio VaR in dependence of the sensitivity of obligor’s
% Now we can Display the VaR with a much lower step thank to time computing
p_grid = [0:0.01:0.5];
q_grid = p_grid;
[VaR_BaseCase_chart_kuma] = arrayfun(@(i) VaR(q_grid(i),p_grid(i),N,N_issuers,X,Z_i,KumaDistribution,alpha,RM,flag_stochastic,flag_kuma),1:length(p_grid),'un',0);
p_grid = [0:0.01:0.5];
q_grid = zeros(1,length(p_grid));
[VaR_CreditMetrics_chart_kuma] = arrayfun(@(i) VaR(q_grid(i),p_grid(i),N,N_issuers,X,Z_i,KumaDistribution,alpha,RM,flag_stochastic,flag_kuma),1:length(p_grid),'un',0);
plot_VaR(p_grid,VaR_BaseCase_chart_kuma,VaR_CreditMetrics_chart_kuma,flag_kuma)

% Find the p value under which the VaR increment is negligible
diff = abs(cell2mat(VaR_BaseCase_chart_kuma)-cell2mat(VaR_CreditMetrics_chart_kuma));
position = find(diff>0.1);
position = position(1);
fprintf('p limit: %.4f\n', p_grid(position));

%% Error = VaR_beta-VaR_kuma
err1 = abs(VaR_BaseCase_kuma-VaR_BaseCase_beta);
err2 = abs(VaR_CreditMetrics_kuma-VaR_CreditMetrics_beta);
err3 = abs(VaR_CreditRisk_kuma-VaR_CreditRisk_beta);
disp('  ');
disp('––– Credit VaR Difference between Beta and Kuma–––')
fprintf('Error Base Case: %.4f\n', err1);
fprintf('Error CreditMetrics: %.4f\n', err2);
fprintf('Error CreditRisk+: %.4f\n', err3);