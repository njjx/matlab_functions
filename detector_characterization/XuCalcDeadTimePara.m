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
    figure();
    plot(X,Y,'s');
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