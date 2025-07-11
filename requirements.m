function requirements()
    % add TIGRE path
    target_dir = fullfile(pwd, 'TIGRE');
    
    % TIGRE GitHub path
    tigre_url = 'https://github.com/CERN/TIGRE/archive/refs/heads/master.zip';
    
    % is exist TIGRE, if not, download it
    if exist(target_dir, 'dir')
        disp('TIGRE already exists. Skipping download.');
    else
        disp('Downloading TIGRE...');
        zip_file = 'TIGRE.zip';
        websave(zip_file, tigre_url);
        
        disp('Unzipping...');
        unzip(zip_file);
        movefile('TIGRE-master', target_dir);
        delete(zip_file);
        disp('TIGRE installed at:');
        disp(target_dir);
    end
    disp('All requirements are set up.');
end
