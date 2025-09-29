function [clusters,references,correlation,correlations,signs] = JoinClusters3(correlations,clusters,references,signs_all,signs)

[min_val,min_ind] = min(correlations(:));
[i1,i2] = ind2sub(size(correlations),min_ind);

%find cluster of i1
c1 = references(i1,2);
%find cluster of i2
c2 = references(i2,2);

%adapt sign of added cluster
index_cluster = 1;
while(1)
    if(clusters{c2}(index_cluster) == i2)
        break;
    else
        index_cluster = index_cluster+1;
    end
end
sign = signs_all(i1,i2);
signs{c1} = sign * signs{c2}(index_cluster) * signs{c1};

%set reference of i1 as i2
references(i1,1) = i2;

correlation = min_val;

%apply rules for graph building
%i1 now has a reference
correlations(i1,:) = Inf;

%correlations(:,i2) = Inf; %if only one channel can have i2 as reference

%avoid cycles in graph
for i=1:length(clusters{c1})
    for j=1:length(clusters{c2})
        correlations(clusters{c1}(i),clusters{c2}(j)) = inf;
        correlations(clusters{c2}(j),clusters{c1}(i)) = inf;
    end
end

clusters{c1} = [clusters{c1},clusters{c2}];
signs{c1} = [signs{c1},signs{c2}];

for i=1:length(clusters{c2})
    references(clusters{c2}(i),2) = c1;
end

clusters(c2) = [];
signs(c2) = [];
logical = references(:,2) > c2;
references(logical,2) = references(logical,2) - 1;

end
