function LIP_Caltech_NDT__decode_generalization_binned_data(binned_format_file_name)
% LIP_Caltech_NDT__decode_generalization_binned_data('C:\Projects\LIP_Caltech\NDT\filelist_290_tuned_units_95_runs_696_units_50_ms_binned_data.mat');

% Add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
toolbox_basedir_name = 'Y:\Sources\ndt.1.0.4';
addpath(toolbox_basedir_name);
% Add the NDT paths using add_ndt_paths_and_init_rand_generator
add_ndt_paths_and_init_rand_generator;

run('LIP_Caltech_NDT__settings');
load(binned_format_file_name);

% smooth the data 
binned_data = arrayfun(@(x) smoothdata(binned_data{x}, 2, settings.smoothing_method, settings.smoothing_window), 1:length(binned_data), 'UniformOutput', false);
save([binned_format_file_name(1:end-4) '_smoothed.mat'],'binned_data','binned_labels','binned_site_info'); 


labels_to_use = {'instr_r', 'instr_l', 'choice_r', 'choice_l'};
labels_to_use_string = strjoin(labels_to_use);
specific_label_name_to_use = 'stimulus_ID';
num_cv_splits = settings.num_cv_splits; 

for k = 1:2 
    
    switch k
        case 1
            the_training_label_names = {{'instr_r'}, {'instr_l'}}; % need cell array of cells because of the expected format for generalization_DS
            the_test_label_names = {{'choice_r'}, {'choice_l'}};
            string_to_add_to_filename = '_train instr test choice_';
        case 2
            the_training_label_names = {{'choice_r'}, {'choice_l'}}; % need cell array of cells because of the expected format for generalization_DS
            the_test_label_names = {{'instr_r'}, {'instr_l'}};
            string_to_add_to_filename = '_train choice test instr_';
    end

    the_classifier = max_correlation_coefficient_CL;
    the_feature_preprocessors{1} = zscore_normalize_FP;
    
    ds = generalization_DS([binned_format_file_name(1:end-4) '_smoothed.mat'], specific_label_name_to_use, num_cv_splits, the_training_label_names, the_test_label_names);
    
    % optionally can specify particular sites to use
    ds.sites_to_use = find_sites_with_k_label_repetitions(binned_labels.stimulus_ID, num_cv_splits, labels_to_use);
    
    
    % Creating a cross-validator (CV) object
    % create the CV object
    the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
    
    % Set how many times the outer 'resample' loop is run
    the_cross_validator.num_resample_runs = settings.num_resample_runs;
    
    % other useful options:
    
    % can greatly speed up the run-time of the analysis by not creating a full TCT matrix (i.e., only trainging and testing the classifier on the same time bin)
    the_cross_validator.test_only_at_training_times = 1;
    
    % Running the decoding analysis and saving the results
    DECODING_RESULTS = the_cross_validator.run_cv_decoding;
    
    save_file_name = [binned_format_file_name(1:end-4) '_' labels_to_use_string string_to_add_to_filename '_DECODING_RESULTS.mat'];
    save(save_file_name, 'DECODING_RESULTS');
    
    % Plot decoding
    LIP_Caltech_NDT__plot_results(save_file_name);
end







