function [dead_time,A]= XuCalcDeadTimePara(count, tube_current, exposure_time, figure_on)

if nargin == 3
    figure_on=0;
end

recorded_count_rate = count/exposure_time;
Y = log(squeeze(recorded_count_rate)./squeeze(tube_current));
X = squeeze(tube_current);

P=polyfit(X,Y,1);

dead_time = - P(1)/ exp(P(2));
A=exp(P(2));

if figure_on
    X_linear_plot = (X-mean(X))*1.1+mean(X);
    r_s = XuRSquared(X,Y);
    str_plot = sprintf('R^2=%.2f',r_s);
    figure();
     plot(X,Y,'k.','markersize',12);
    hold on;
    h2 = plot(X_linear_plot,polyval(P,X_linear_plot),'k-');
    hold off;
    xlabel('$I$ (mA)','interpreter','latex');
    ylabel('ln($\Psi/I$) (ln(mA$\cdot$s))','interpreter','latex')
    legend([h2],str_plot,'location','northeast');
    grid on;
end

end
% recorded_count_rate = count/squeeze(exposure_time);
% true_count_rate = count(1)/exposure_time/tube_current(1)*tube_current;
%
% Y = log(recorded_count_rate./true_count_rate);
% X = true_count_rate;
%
% P=polyfit(X,Y,1);
%
% dead_time = - P(1);