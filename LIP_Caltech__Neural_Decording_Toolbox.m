%function LIP_Caltech__Neural_Decording_Toolbox
 clear
    
    % add the path to the NDT so add_ndt_paths_and_init_rand_generator can be called
    toolbox_basedir_name = 'ndt.1.0.4/'
    addpath(toolbox_basedir_name);
    
    % add the NDT paths using add_ndt_paths_and_init_rand_generator
    add_ndt_paths_and_init_rand_generator
    
    run('LIP_Caltech_NDT_settings');
    cd (OUTPUT_PATH);
    
    filename = 'GU_20110126_R01a1_1_binned_data_forNDT.mat';
    binned_format_file_name = [OUTPUT_PATH filename];
    load(filename);
    
   % Extract an important piece of data about a file from the file name, to save files with that piece in the file name in the future. 
        parts = strsplit(filename, '_');
        if numel(parts) >= 4
            extracted_string = [parts{1}, '_', parts{2}, '_', parts{3}, '_', parts{4}];
            disp(extracted_string);
        else
         disp('Filename does not have enough parts.');
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Determining how many times each condition was repeated
    %load the binned data

    for k = 1:205
        inds_of_sites_with_at_least_k_repeats = find_sites_with_k_label_repetitions(binned_labels.stimulus_ID, k);
        num_sites_with_k_repeats(k) = length(inds_of_sites_with_at_least_k_repeats);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
%% If the binned data has already been created, run the code from here

%Creating a Datasource (DS) object
% will decode the identity of which object was shown (regardless of its position)
specific_label_name_to_use = 'stimulus_ID';
%  20 cross-validation runs
num_cv_splits = 20;
% Create a datasource that takes our binned data, and specifies that we want to decode
ds = basic_DS(binned_format_file_name, specific_label_name_to_use, num_cv_splits);
file_name = [OUTPUT_PATH extracted_string '_binned_data_DS'];
save (file_name, 'ds');


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
the_cross_validator.num_resample_runs = 10;


%Running the decoding analysis and saving the results
% run the decoding analysis
DECODING_RESULTS = the_cross_validator.run_cv_decoding;
save_file_name = [OUTPUT_PATH extracted_string '_DECODING_RESULTS'];
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
plot_obj.significant_event_times = 0;
% display the results
plot_obj.plot_results;
ylim([0 100]);
line([0 0], [0 100], 'color', [0.6 0.6 0.6]);
saveas(gcf, [OUTPUT_PATH extracted_string '_decoding_accuracy_as_a_function_of_time.png']);


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
%   saveas(gcf, [output_path '\temporal_cross_training_decoding_accuracies' rng_name nu '.png']);

beep
