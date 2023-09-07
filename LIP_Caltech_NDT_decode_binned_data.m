function LIP_Caltech_NDT_decode_binned_data(binned_format_file_name)
% LIP_Caltech_NDT_decode_binned_data('E:\Projects\LIP_Caltech\NDT\filelist_290_tuned_units_95_runs_696_units_binned_data.mat');

%     add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
toolbox_basedir_name = 'Y:\Sources\ndt.1.0.4';
addpath(toolbox_basedir_name);
%     add the NDT paths using add_ndt_paths_and_init_rand_generator
add_ndt_paths_and_init_rand_generator;

run('LIP_Caltech_NDT_settings');
load(binned_format_file_name);

ds.label_names_to_use = {'instr_r', 'instr_l'}; % {'instr_r', 'instr_l'} {'choice_r', 'choice_l'}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Determining how many times each condition was repeated
%load the binned data

for k = 1:40
    inds_of_sites_with_at_least_k_repeats = find_sites_with_k_label_repetitions(binned_labels.stimulus_ID, k, ds.label_names_to_use);
    num_sites_with_k_repeats(k) = length(inds_of_sites_with_at_least_k_repeats);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% If the binned data has already been created, run the code from here

%Creating a Datasource (DS) object
% will decode the identity of which object was shown (regardless of its position)
specific_label_name_to_use = 'stimulus_ID';

num_cv_splits = 5; % 20 cross-validation runs
% Create a datasource that takes our binned data, and specifies that we want to decode
ds = basic_DS(binned_format_file_name, specific_label_name_to_use, num_cv_splits);

%ds.time_periods_to_get_data_from = {280}; % lenght ()



%Creating a feature-preprocessor (FP) object
% create a feature preprocessor that z-score normalizes each neuron
% note that the FP objects are stored in a cell array, which allows multiple FP objects to be used in one analysis
the_feature_preprocessors{1} = zscore_normalize_FP;


%Creating a classifier (CL) object
% create the CL object
the_classifier = max_correlation_coefficient_CL;


%Creating a cross-validator (CV) object
% create the CV object
the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
% set how many times the outer 'resample' loop is run
% generally we use more than 2 resample runs which will give more accurate results, but to save time in this tutorial we are using a small number.
the_cross_validator.num_resample_runs = 5; % 10


%Running the decoding analysis and saving the results
% run the decoding analysis
DECODING_RESULTS = the_cross_validator.run_cv_decoding;
save_file_name = [binned_format_file_name(1:end-4) '_DECODING_RESULTS.mat'];
save(save_file_name, 'DECODING_RESULTS');



%Plotting the results

result_names{1} = save_file_name;
% create the plot results object
plot_obj = plot_standard_results_object(result_names);
% display the results
plot_obj.plot_results;
%   saveas(gcf, [output_path '\decoding_accuracy_as_a_function_of_time_1' rng_name nu '.png']);

%Plot the decoding accuracy as a function of time
% Specify the name of the file that we want to plot
result_names{1} = save_file_name;
% create the plot results object
plot_obj = plot_standard_results_object(result_names);
% put a line at the time when the stimulus was shown
plot_obj.significant_event_times = 1800; 
% display the results
plot_obj.plot_results;
ylim([0 100]);

hold on; title ([ds.label_names_to_use]);
saveas(gcf, [binned_format_file_name(1:end-4) '_DA_as_a_function_of_time.png']);

%{
% Plot temporal cross training decoding accuracies
% create the plot results object
% note that this object takes a string in its constructor not a cell array
plot_obj_matrix = plot_standard_results_TCT_object(save_file_name);
% put a line at the time when the stimulus was shown
plot_obj_matrix.significant_event_times = 0;
% display the results
plot_obj_matrix.plot_results;
ylim([0 100]);
line([0 0], [0 100], 'color', [0.6 0.6 0.6]);
% %   saveas(gcf, [output_path '\temporal_cross_training_decoding_accuracies' rng_name nu '.png']);
%}
