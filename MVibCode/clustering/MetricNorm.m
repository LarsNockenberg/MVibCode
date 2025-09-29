function [metric,metric_bands_w,w] = MetricNorm(sig_dwt, sig_diff_dwt, SMR1, SMR2,book)


SMR1 = 10.^(SMR1/10);
SMR2 = 10.^(SMR2/10);
w = sqrt(SMR1.*SMR2);
w = w/sum(w);

metric_bands = zeros(size(SMR1));
m = 0;
for b=1:length(SMR1)
    metric_bands(b) = sum((sig_dwt(m+1:m+book(b))).^2)/sum(sig_diff_dwt(m+1:m+book(b)).^2);
    m = m+book(b);
end

metric_bands_w = metric_bands.*w;
metric = sum(metric_bands_w);

end