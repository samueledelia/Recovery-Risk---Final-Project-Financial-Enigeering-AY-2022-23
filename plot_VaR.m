function [] = plot_VaR(p_grid,VaR_BaseCase,VaR_CreditMetrics,flag2)
% Chart of the Credit Portfolio VaR in dependence of the sensitivity of obligor’s
% INPUT:
% p_grid:                           sensitivity of obligor’s grid
% VaR_Beta:                         VaR to each p_grid (beta distr.)
% VaR_Kuma:                         VaR to each p_grid (kuma distr.)
% flag2:                            1: beta distr./ 2: kuma. distr.
%
% OUTPUT:
% ~:                            nothing
switch flag2
    case 1
        plot(p_grid,cell2mat(VaR_BaseCase),'linewidth',2);
        title("Credit Portfolio VaR in dependence of the sensitivity of obligor’s")
        grid on
        xlabel("Sensitivity p");
        ylabel("VaR (%)")
    case 2
        plot(p_grid,cell2mat(VaR_BaseCase),'linewidth',2);
        title("Credit Portfolio VaR in dependence of the sensitivity of obligor’s")
        grid on
        hold on
        plot(p_grid,cell2mat(VaR_CreditMetrics),"linewidth",2)
        legend("p = q","q = 0");
        xlabel("Sensitivity p");
        ylabel("VaR (%)")
end

