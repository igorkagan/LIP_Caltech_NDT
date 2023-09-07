function LIP_Caltech_NDT__convert_many_runs_mat_into_binned_format(filelist)
% LIP_Caltech_NDT__convert_many_runs_mat_into_binned_format('filelist_290_tuned_units_95_runs');

run('LIP_Caltech_NDT_settings');
run(filelist);

% run('filelist_290_tuned_units_95_runs');

% if needed, change the path to data
% files = phy_replace_drive_letter(files,'Y:\Projects\LIP_Caltech','E:\Data');

N_files = numel(files);

n_units = 0;
for f = 1:N_files
    
    [binned_data1, binned_labels1, binned_site_info1] = LIP_Caltech_NDT__one_run_mat_into_individual_cells(files{f});                    
                    
    n_units_in_file = numel(binned_data1);
    binned_data(n_units + 1:n_units + n_units_in_file) = binned_data1;
    binned_labels(n_units + 1:n_units + n_units_in_file) = binned_labels1;
    binned_site_info(n_units + 1:n_units + n_units_in_file) = binned_site_info1;
    n_units = n_units + n_units_in_file;
    
end

% save binned data
file2save = [OUTPUT_PATH filelist '_' num2str(n_units) '_units_binned_data.mat'];
save(file2save,'binned_data','binned_labels','binned_site_info');
disp([file2save ' saved']);





