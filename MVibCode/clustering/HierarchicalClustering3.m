function [out_members,out_sorting,out_signs,out_references,out_references_sorted,correlations] = HierarchicalClustering3(data_dwt,SMR,max_corr,dwtlevel,settings)

if(size(data_dwt,1) == 1)
    out_clusters = {1};
    out_signs = {1};
    correlations = {0};
    out_members = {1};
    out_sorting = {1};
    out_references = {0};
    out_references_sorted = {0};
    return
end

[correlation_all,signs_all] = energyCompNorm(data_dwt,dwtlevel,SMR,settings);


test = correlation_all;
test(test==0) = Inf;

sz = size(data_dwt);

clusterings = cell(1,sz(1));
references_all = cell(1,sz(1));
signs = cell(1,sz(1));
correlations = zeros(1,sz(1));

clustering = cell(1,sz(1));
cluster_channels = cell(1,sz(1));
signs_temp = cell(1,sz(1));
references = zeros(sz(1),2);
for i=1:sz(1)
	clustering{i} = i;
	cluster_channels{i} = data_dwt(i,:);
    signs_temp{i} = 1;
    references(i,2) = i;
end

clusterings{1} = clustering;
signs{1} = signs_temp;
correlations(1) = 1;
references_iter{1} = references;


correlation_all = correlation_all + diag(ones(1,sz(1))*Inf);

for i=1:sz(1)-1
    
    [clustering,references,corr_best,correlation_all,signs_temp] = JoinClusters3(correlation_all,clustering,references,signs_all,signs_temp);
    correlations(i+1) = corr_best;
    if corr_best>max_corr
        clusterings = clusterings(1:i);
        signs = signs(1:i);
        correlations = correlations(1:i);
        references_iter = references_iter(1:i);
        break;
    end
    
    
    signs{i+1} = signs_temp;

    clusterings{i+1} = clustering;
    references_iter{i+1} = references;
    
end

out_clusters_temp = clusterings{end};
out_signs_temp = signs{end};
out_references = references_iter{end};

out_clusters = cell(0);
out_signs = cell(0);
lengths = zeros(1,length(out_clusters_temp));
for c=1:length(out_clusters_temp)
    lengths(c) = numel(out_clusters_temp{c});
end
[~,indices_sorted] = sort(lengths,'descend');
out_clusters = out_clusters_temp(indices_sorted);
out_signs = out_signs_temp(indices_sorted);

[out_members,out_sorting,out_signs,out_references_sorted,out_references] = sortClusters(out_clusters,out_signs,out_references);

end
