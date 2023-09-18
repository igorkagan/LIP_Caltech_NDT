function LIP_Caltech_NDT__decode_binned_data(binned_format_file_name)
% LIP_Caltech_NDT_decode_binned_data('E:\Projects\LIP_Caltech\NDT\filelist_290_tuned_units_95_runs_696_units_binned_data.mat');

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


% labels_to_use = {'instr_r', 'instr_l'};
labels_to_use = {'choice_r', 'choice_l'};
% labels_to_use = {'instr_r', 'choice_r'};
% labels_to_use = {'instr_l', 'choice_l'};

string_to_add_to_filename = '';
    
labels_to_use_string = strjoin(labels_to_use);

% labels_to_use = {'choice_r', 'choice_l'};

% Determining how many times each condition was repeated
for k = 1:40
    inds_of_sites_with_at_least_k_repeats = find_sites_with_k_label_repetitions(binned_labels.stimulus_ID, k, labels_to_use);
    num_sites_with_k_repeats(k) = length(inds_of_sites_with_at_least_k_repeats);
end


specific_label_name_to_use = 'stimulus_ID';

num_cv_splits = settings.num_cv_splits; % 20 cross-validation runs

% Create a datasource that takes our binned data, and specifies that we want to decode
ds = basic_DS([binned_format_file_name(1:end-4) '_smoothed.mat'], specific_label_name_to_use, num_cv_splits);

% can have multiple repetitions of each label in each cross-validation split (which is a faster way to run the code that uses most of the data)
% ds.num_times_to_repeat_each_label_per_cv_split = 2;

% optionally can specify particular sites to use
ds.sites_to_use = find_sites_with_k_label_repetitions(binned_labels.stimulus_ID, num_cv_splits, labels_to_use);  

% can do the decoding on a subset of labels
ds.label_names_to_use = labels_to_use; % {'instr_r', 'instr_l'} {'choice_r', 'choice_l'}

% ds.time_periods_to_get_data_from = {280}; 



% Creating a feature-preprocessor (FP) object
% create a feature preprocessor that z-score normalizes each neuron
% note that the FP objects are stored in a cell array, which allows multiple FP objects to be used in one analysis
the_feature_preprocessors{1} = zscore_normalize_FP;

% other useful options:   

% can include a feature-selection features preprocessor to only use the top k most selective neurons
% fp = select_or_exclude_top_k_features_FP;
% fp.num_features_to_use = 50;   % use only the 25 most selective neurons as determined by a univariate one-way ANOVA
% the_feature_preprocessors{2} = fp;
% string_to_add_to_filename = ['_top_ num2str(fp.num_features_to_use) '_units_'];



% Creating a classifier (CL) object
% create the CL object
the_classifier = max_correlation_coefficient_CL;
% the_classifier = libsvm_CL;
% the_classifier.multiclass_classificaion_scheme = 'one_vs_all';

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


