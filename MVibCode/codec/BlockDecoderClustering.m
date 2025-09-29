function [bitstream,block_rec,counter_arithmetic] = BlockDecoderClustering(bitstream,channel_count,settings,counter_arithmetic)
    
    old_mode = settings.old_mode;
    mean_mode = settings.mean_mode;

    if(nargin<4)
        counter_arithmetic = [];
    end
    
    if(old_mode==0)

        means = zeros(1,channel_count);
        if(mean_mode==1)
            [bitstream,means] = decodeMeans(bitstream,channel_count,settings);
        end

        [cluster_members,references,bitstream] = decodeClustering3(bitstream,channel_count);
        [clustering,ref_sorted] = sortClustersDec(cluster_members,references);

        signs = cell(size(clustering));
        for i=1:length(clustering)
            signs{i} = ones(1,length(clustering{i}));
        end


        cluster_count = length(clustering);
        [bitstream,recsignal,counter_arithmetic,bl,dwtlevel] = DecoderMD(bitstream,cluster_count,settings,counter_arithmetic);
        if(length(clustering)<channel_count)
            [bitstream,recsignal2,counter_arithmetic] = DecoderMD(bitstream,channel_count-cluster_count,settings,counter_arithmetic,0,bl,dwtlevel);
            %recsignal2 =recsignal2/4;
            recsignal = [recsignal;recsignal2];
        end
        
        

        representatives = recsignal(1:cluster_count,:);
        recsignal(1:cluster_count,:) = [];
        clusters_rec = cell(size(clustering));
        for c=1:cluster_count
            cluster = clustering{c};
            if(length(cluster)==1)
                clusters_rec{c} = wavecdf97(representatives(c,:),-dwtlevel);
            else
                cluster_rec = [representatives(c,:);zeros(length(cluster)-1,bl)];
                for i=1:length(cluster)-1
                    cluster_rec(i+1,:) = cluster_rec(ref_sorted{c}(i),:) + recsignal(i,:);
                end
                recsignal(1:length(cluster)-1,:) = [];

                for i=1:size(cluster_rec,1)
                        cluster_rec(i,:) = wavecdf97(cluster_rec(i,:),-dwtlevel);
                end
                clusters_rec{c} = cluster_rec;

            end
        end


        block_rec = reorderSignal(clusters_rec,clustering,channel_count,bl,signs);

        for i=1:channel_count
            block_rec(i,:) = block_rec(i,:) + means(i);
        end
        
    else
        
        [bitstream,recsignal,counter_arithmetic,bl,dwtlevel] = DecoderMD(bitstream,channel_count,settings,counter_arithmetic);
        block_rec = zeros(size(recsignal));
        for i=1:channel_count
            block_rec(i,:) = wavecdf97(recsignal(i,:),-dwtlevel);
        end
        
    end
    
end