function [dead_time,A ]= XuCalcDeadTimeNonPara(count, tube_current, exposure_time)

recorded_count_rate = count/exposure_time;
Y = squeeze(tube_current)./squeeze(recorded_count_rate); 
X = squeeze(tube_current);

P=polyfit(X,Y,1);

dead_time = P(1);
A = 1/P(2);


X_linear_plot = (X-mean(X))*1.1+mean(X);
r_s = XuRSquared(X,Y);
str_plot = sprintf('R^2=%.2f',r_s);
figure()
hold on;
plot(X,Y,'k.','markersize',12);
h2 = plot(X_linear_plot,polyval(P,X_linear_plot),'k-');
hold off;
xlabel('$I$ (mA)','interpreter','latex');
ylabel('$I/\Psi$ (mA$\cdot$s)','interpreter','latex');
legend([h2],str_plot,'location','southeast');
grid on; 
