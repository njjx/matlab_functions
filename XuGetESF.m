function [esf, corr ] =  XuGetESF(edgedata,resampling_interval)
l_s_f = XuGetLineSpreadFunction(edgedata); 
l_s_f_resample = XuSpreadFunctionResample(l_s_f,resampling_interval);

l_s_f_resample(isnan(l_s_f_resample)) = 0;

esf = cumsum(l_s_f_resample(2,:))*resampling_interval;
corr = l_s_f_resample(1,:);
