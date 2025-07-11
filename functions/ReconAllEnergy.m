function [] = ReconAllEnergy(data_dir_root,save_path,RecPara)

file_list = dir(data_dir_root);
file_list = file_list(3:end);
recon_bin = RecPara.recon_Bin;

SN = 0;
tid1 = tic;
for i=1:length(file_list)
    tid2 = tic;
    file_name = file_list(i).name;
    file_path = [data_dir_root,'\',file_name];
    fprintf('### %s begining ...\n',file_path);
    if recon_bin(1) %Low
        tid3 = tic;
        Energy = 'Low';
        fprintf('## %s begining ...\n',[file_path,'\',Energy]);
        [proj_data,AcqPara,ReconPara] = ProjDataPrepare(file_path,RecPara,Energy);
        [ReconData,ReconPara] = ProjDataRecon(proj_data,AcqPara,ReconPara);
        SN_New = ReconDataSave(ReconData, AcqPara, ReconPara,SN,save_path);
        clear proj_data ReconData ReconPara AcqPara
        fprintf(['##',Energy,' Recon',':total running time is %.3f s\n'], toc(tid3));
    end
    if recon_bin(2) %High
        tid3 = tic;
        Energy = 'High';
        fprintf('##: %s begining ...\n',[file_path,'\',Energy]);
        [proj_data,AcqPara,ReconPara] = ProjDataPrepare(file_path,RecPara,Energy);
        [ReconData,ReconPara] = ProjDataRecon(proj_data,AcqPara,ReconPara);
        SN_New = ReconDataSave(ReconData, AcqPara, ReconPara,SN,save_path);
        clear proj_data ReconData ReconPara AcqPara
        fprintf(['##',Energy,' Recon',':total running time is %.3f s\n'], toc(tid3));
    end
    if recon_bin(3) %Total
        tid3 = tic;
        Energy = 'Total';
        fprintf('##: %s begining ...\n',[file_path,'\',Energy]);
        [proj_data,AcqPara,ReconPara] = ProjDataPrepare(file_path,RecPara,Energy);
        [ReconData,ReconPara] = ProjDataRecon(proj_data,AcqPara,ReconPara);
        SN_New = ReconDataSave(ReconData, AcqPara, ReconPara,SN,save_path);
        clear proj_data ReconData ReconPara AcqPara
        fprintf(['##',Energy,' Recon',':total running time is %.3f s\n'], toc(tid3));
    end
    SN = SN_New;
    fprintf(['###',file_name,' Recon',':total running time is %.3f s\n'], toc(tid2));
end
fprintf('######：%s Recon:total running time is %.3f s\n',data_dir_root ,toc(tid1));
end