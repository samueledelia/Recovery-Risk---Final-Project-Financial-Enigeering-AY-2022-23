function [] = plot_distributions(Distribution_1,Distribution_2,flag)
% Given two input distribution plot pdf and cdf
%
% INPUT:
% Distribution_1:             struct with the parameters alpha and beta
% Distribution_2:             struct with the parameters alpha and beta
% flag:                       1: beta distributions/ 2: Distribution_1 is beta and Distribution_2 is kuma distr
%
% OUTPUT:
% ~:                            nothing

x = 0:0.01:1;
switch flag
    case 1
        pdf_1 = betapdf(x,Distribution_1.alpha,Distribution_1.beta);
        pdf_2 = betapdf(x,Distribution_2.alpha,Distribution_2.beta);
        plot(x,pdf_1,x,pdf_2,'linewidth',2)
        title("Beta PDFs")
        grid on
        legend(["secured pdf (\alpha=" + Distribution_1.alpha+ ", \beta=" + Distribution_1.beta+")","unsecured pdf (\alpha=" + Distribution_2.alpha+ ", \beta=" + Distribution_2.beta+")"])

        figure()
        cdf_1 = betacdf(x,Distribution_1.alpha,Distribution_1.beta);
        cdf_2 = betacdf(x,Distribution_2.alpha,Distribution_2.beta);
        plot(x,cdf_1,x,cdf_2,'linewidth',2)
        title("Beta CDFs")
        grid on
        legend(["secured cdf (\alpha=" + Distribution_1.alpha+ ", \beta=" + Distribution_1.beta+")","unsecured cdf (\alpha=" + Distribution_2.alpha+ ", \beta=" + Distribution_2.beta+")"])
        % Print Beta properties
        fprintf('The properties of the Secured beta distribution are:\n');
        fprintf('alpha:        %.4f\n',Distribution_1.alpha);
        fprintf('beta:         %.4f\n',Distribution_1.beta);
        fprintf('mean:         %.4f\n',Distribution_1.mean);
        fprintf('variance:     %.4f\n',Distribution_1.var);
        fprintf('mode:         %.4f\n',Distribution_1.mode);
        fprintf('skewness:     %.4f\n',Distribution_1.skewness);
        fprintf('kurtosis:     %.4f\n',Distribution_1.kurtosis);
        fprintf('\nThe properties of the Unsecured beta distribution are:\n');
        fprintf('alpha:        %.4f\n',Distribution_2.alpha);
        fprintf('beta:         %.4f\n',Distribution_2.beta);
        fprintf('mean:         %.4f\n',Distribution_2.mean);
        fprintf('variance:     %.4f\n',Distribution_2.var);
        fprintf('mode:         %.4f\n',Distribution_2.mode);
        fprintf('skewness:     %.4f\n',Distribution_2.skewness);
        fprintf('kurtosis:     %.4f\n',Distribution_2.kurtosis);
    case 2
        kuma_pdf = @(a,b,x) a.*b.*x.^(a-1).*(1-x.^a).^(b-1);
        pdf_1 = betapdf(x,Distribution_1.alpha,Distribution_1.beta);
        plot(x,pdf_1,x,kuma_pdf(Distribution_2.a,Distribution_2.b,x),'linewidth',2)
        grid on
        legend(["Beta pdf (\alpha=" + Distribution_1.alpha+ ", \beta=" + Distribution_1.beta+")","Kumaraswamy pdf (a=" + Distribution_2.a+ ", b=" + Distribution_2.b+")"])
        title("Secured loans PDFs plot")
        figure()
        kuma_cdf = @(a,b,x) 1-(1-x.^a).^b;
        cdf_1 = betacdf(x,Distribution_1.alpha,Distribution_1.beta);
        plot(x,cdf_1,x,kuma_cdf(Distribution_2.a,Distribution_2.b,x),'linewidth',2)
        grid on
        legend(["Beta cdf (\alpha=" + Distribution_1.alpha+ ", \beta=" + Distribution_1.beta+")","Kumaraswamy cdf (a=" + Distribution_2.a+ ", b=" + Distribution_2.b+")"])
        title("Secured loans CDFs plot")       
end       

end

