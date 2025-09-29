function [relation,signs] = energyCompNorm(data_dwt,dwtlevel,SMR,settings)


channels = size(data_dwt,1);
bl = size(data_dwt,2);
book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
for i = 1:size(data_dwt,1)
    SMR(i,:) = 10.^((SMR(i,:))/10);
end


relation = zeros(channels);

    
relation_temp1 = zeros([channels,channels,length(book)]);
relation_temp2 = zeros([channels,channels,length(book)]);
signs = ones(channels);

m = 0;
for b = 1:length(book)
    for i=1:channels
        for j=1:channels
            if(i~=j)
                E_i = energy(data_dwt(i,:),book);
                E_diff = energy(data_dwt(i,:)-data_dwt(j,:),book);
                relation_temp1(i,j,b) = sum((data_dwt(i,m+1:m+book(b))-data_dwt(j,m+1:m+book(b))).^2)/sum(data_dwt(i,m+1:m+book(b)).^2);
            end
        end
    end
    m = m+book(b);
end

relation_temp1_weighted = zeros(size(relation_temp1));
relation_temp2_weighted = zeros(size(relation_temp1));
for c = 1:channels
    relation_temp1_weighted(:,c,:) = squeeze(relation_temp1(:,c,:)) .* sqrt(SMR.*SMR(c,:));% .* repmat(book',[size(data,1),1]);
end

SMR_combined = zeros(size(relation));
for i=1:channels
    for j=1:channels
        SMR_combined(i,j) = sum(sqrt(SMR(i,:).*SMR(j,:)));
    end
end
relation_temp1_mean = sum(relation_temp1_weighted,3)./SMR_combined;


relation = relation_temp1_mean;
    
end