function [ordered,SMR_ordered,bandenergy_ordered] = orderSignal(data,SMR,bandenergy,clustering,bl,signs)

clusters = length(clustering);
ordered = cell(1,clusters);
SMR_ordered = cell(1,clusters);
bandenergy_ordered = cell(1,clusters);
for c=1:clusters
    ordered{c} = zeros(length(clustering{c}),bl);
    SMR_ordered{c} = zeros(length(clustering{c}),size(SMR,2));
    bandenergy_ordered{c} = zeros(length(clustering{c}),size(SMR,2));
    for i=1:length(clustering{c})
        ordered{c}(i,:) = data(clustering{c}(i),:)*signs{c}(i);
        SMR_ordered{c}(i,:) = SMR(clustering{c}(i),:);
        bandenergy_ordered{c}(i,:) = bandenergy(clustering{c}(i),:);
    end
end

end