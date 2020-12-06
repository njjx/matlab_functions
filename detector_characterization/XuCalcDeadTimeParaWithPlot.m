function [dead_time A]= XuCalcDeadTimeParaWithPlot(count, tube_current, exposure_time)

recorded_count_rate = count/exposure_time;
Y = log(squeeze(recorded_count_rate)./squeeze(tube_current)); 
X = squeeze(tube_current);

X_linear_plot = (X-mean(X))*1.1+mean(X);

P=polyfit(X,Y,1);

dead_time = - P(1)/ exp(P(2));
A=exp(P(2));

r_s = XuRSquared(X,Y);
str_plot = sprintf('R^2=%.2f',r_s);
figure()
hold on;
plot(X,Y,'k.','markersize',12);
h2 = plot(X_linear_plot,polyval(P,X_linear_plot),'k-');
hold off;
xlabel('$I$ (mA)','interpreter','latex');
ylabel('$\ln\left[\frac{M(+\infty)}{I\Delta t}\right]$ [ln(1/mA/s)]','interpreter','latex');
legend([h2],str_plot);
grid on; 
