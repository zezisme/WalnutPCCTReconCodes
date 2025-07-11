function [pre]=poly_corr_proj(proj_data1,proj_data2,corr_table,poly_type)
    s = ndims(proj_data1);
    if s==2
        corr_table = reshape(corr_table,size(corr_table,1)*size(corr_table,2),[]);
        switch poly_type
            case 0 %一阶+偏置
                pre = corr_table(:,1)+corr_table(:,2).*proj_data1+corr_table(:,3).*proj_data2;
            case 1 %一阶+无偏置
                pre = corr_table(:,1).*proj_data1+corr_table(:,2).*proj_data2;
            case 2
                pre = corr_table(:,1).*proj_data1+corr_table(:,2).*proj_data2+...
                corr_table(:,3).*proj_data1.^2+corr_table(:,4).*proj_data2.^2+corr_table(:,5).*proj_data1.*proj_data2;
            case 2.5
                pre = corr_table(:,1)+corr_table(:,2).*proj_data1+corr_table(:,3).*proj_data2+...
                corr_table(:,4).*proj_data1.^2+corr_table(:,5).*proj_data2.^2+corr_table(:,6).*proj_data1.*proj_data2;
            case 3
                pre = corr_table(:,1).*proj_data1+corr_table(:,2).*proj_data2+...
                corr_table(:,3).*proj_data1.^2+corr_table(:,4).*proj_data2.^2+corr_table(:,5).*proj_data1.*proj_data2+...
                corr_table(:,6).*proj_data2.*proj_data1.^2+corr_table(:,7).*proj_data1.*proj_data2.^2+...
                corr_table(:,8).*proj_data1.^3+corr_table(:,9).*proj_data2.^3;
        end
    else
        switch poly_type
            case 0 %一阶+偏置
                pre = corr_table(:,:,1)+corr_table(:,:,2).*proj_data1+corr_table(:,:,3).*proj_data2;
            case 1 %一阶+无偏置
                pre = corr_table(:,:,1).*proj_data1+corr_table(:,:,2).*proj_data2;
            case 2
                pre = corr_table(:,:,1).*proj_data1+corr_table(:,:,2).*proj_data2+...
                corr_table(:,:,3).*proj_data1.^2+corr_table(:,:,4).*proj_data2.^2+corr_table(:,:,5).*proj_data1.*proj_data2;
            case 2.5
                pre = corr_table(:,:,1)+corr_table(:,:,2).*proj_data1+corr_table(:,:,3).*proj_data2+...
                corr_table(:,:,4).*proj_data1.^2+corr_table(:,:,5).*proj_data2.^2+corr_table(:,:,6).*proj_data1.*proj_data2;
            case 3
                pre = corr_table(:,:,1).*proj_data1+corr_table(:,:,2).*proj_data2+...
                corr_table(:,:,3).*proj_data1.^2+corr_table(:,:,4).*proj_data2.^2+corr_table(:,:,5).*proj_data1.*proj_data2+...
                corr_table(:,:,6).*proj_data2.*proj_data1.^2+corr_table(:,:,7).*proj_data1.*proj_data2.^2+...
                corr_table(:,:,8).*proj_data1.^3+corr_table(:,:,9).*proj_data2.^3;
        end
    end
end