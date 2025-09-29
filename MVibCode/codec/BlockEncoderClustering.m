function [bitstream,clustering,rep_dwt_quant,counter_arithmetic] = BlockEncoderClustering(sig,bl,dwtlevel,fs,bitbudget,min_corr,settings,counter_arithmetic)

    old_mode = settings.old_mode;
    mean_mode = settings.mean_mode;

    means = [];
    
    if(nargin<8)
        counter_arithmetic = [];
    end
    
    if(old_mode == 0)

        means_enc = [];
        if(mean_mode==1)
            [means_enc,sig] = encodeMeans(sig,settings);
        end

        [sig_dwt] = wavecdf97_MD(sig,dwtlevel);
        book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
        [SMR,bandenergy,globalmask] = PsychohapticModel_MD(sig,bl,book,fs,settings);
        
        [clustering,clustering_sorting,signs,references,references_sorted,correlations] = HierarchicalClustering3(sig_dwt,SMR,min_corr,dwtlevel,settings);
        
        clustering_enc = encodeClustering3(clustering,references,size(sig,1));
        cluster_count = length(clustering);
        %cluster_count

        
        [clusters,clusters_SMR,clusters_bandenergy] = orderSignal(sig_dwt,SMR,bandenergy,clustering_sorting,bl,signs);

        representatives = zeros(cluster_count,bl);
        SMR_rep = zeros(cluster_count,length(book));
        bandenergy_rep = zeros(cluster_count,length(book));
        for c=1:cluster_count
            representatives(c,:) = clusters{c}(1,:);
            SMR_rep(c,:) = clusters_SMR{c}(1,:);
            bandenergy_rep(c,:) = clusters_bandenergy{c}(1,:);
        end
        [bitstream,rep_dwt_quant,counter_arithmetic] = BlockEncoderMD(representatives,[],SMR_rep,bandenergy_rep,bl,dwtlevel,bitbudget,fs,settings,counter_arithmetic);
        bitstream = [means_enc,clustering_enc,bitstream];


        for c=1:cluster_count

            diff_channels = clusters{c}(2:end,:);
            SMR_diff = clusters_SMR{c}(2:end,:);
            bandenergy_diff = clusters_bandenergy{c}(2:end,:);

            if size(diff_channels,1) > 0

                [bitstream_res,residuals,~,counter_arithmetic] = BlockEncoderResidual3Graph(diff_channels,rep_dwt_quant(c,:),references_sorted{c},SMR_diff,bandenergy_diff,bl,dwtlevel,bitbudget/(dwtlevel+1),settings,counter_arithmetic);
                
                bitstream = [bitstream,bitstream_res];

            end

        end
        
    else
        [sig_dwt] = wavecdf97_MD(sig,dwtlevel);
        book = bl./(2.^([dwtlevel,dwtlevel:-1:1]))';
        [SMR,bandenergy,globalmask] = PsychohapticModel_MD(sig,bl,book,fs,settings);
        
        [bitstream,rep_dwt_quant,counter_arithmetic] = BlockEncoderMD(sig_dwt,[],SMR,bandenergy,bl,dwtlevel,bitbudget,fs,settings,counter_arithmetic);
        clustering = [];
        signs = [];
       
    end
end