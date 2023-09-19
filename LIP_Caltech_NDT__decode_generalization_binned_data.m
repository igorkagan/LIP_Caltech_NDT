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


 labels_to_use = {'instr_r', 'instr_l'};
% labels_to_use = {'choice_r', 'choice_l'};
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

%% generalization analysis

%Create a feature proprocessor object
    %the_classifier = max_correlation_coefficient_CL;
    %the_feature_preprocessors{1} = zscore_normalize_FP; 

%  4. Let's first train the classifier to discriminate between objects at the upper location, and test the classifier with objects shown at the lower location
%  4a.  create labels for which exact stimuli (ID plus position) belong in the training set, and which stimuli belong in the test set
    the_training_label_names = {'instr_r', 'instr_l'};
    the_test_label_names = {'choice_r', 'choice_l'};

%  4b.  creata a generalization datasource that produces training data at the upper location, and test data at the lower location
    num_cv_splits = settings.num_cv_splits; % 20 cross-validation runs
    specific_labels_names_to_use = 'stimulus_ID';  % use the combined ID and position labels
    ds = generalization_DS([binned_format_file_name(1:end-4) '_smoothed.mat'], specific_labels_names_to_use, num_cv_splits, the_training_label_names, the_test_label_names);

%  4c. run a cross-validation decoding analysis that uses the generalization datasource we created to 
% train a classifier with data from the upper location and test the classifier with data from the lower location

    %the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
    %the_cross_validator.num_resample_runs = 10;

    %DECODING_RESULTS = the_cross_validator.run_cv_decoding;


% viewing the results suggests that they are above chance  (where chance is .1429)
    DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results 

%  5.  Training and Testing at all locations
    mkdir C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results;  % make a directory to save all the results
    %num_cv_splits = 5;
    
    id_string_names_train = {'instr_r', 'instr_l'};
    id_string_names_test = {'choice_r', 'choice_l'};
    %pos_string_names = {'upper', 'middle', 'lower'};
 
for iTrainPosition = 1:2
    
    tic   % print how long it to run the results for training at one position (and testing at all three positions)
    
    for iTestPosition = 1:2
 
      % create the current labels that should be in the training and test sets 
      for iID = 1:2
            the_training_label_names{iID} = {[id_string_names_train{iTrainPosition}]};
            the_test_label_names{iID} =  {[id_string_names_test{iTestPosition}]};
      end
      % create the generalization datasource for training and testing at the current locations
      ds = generalization_DS([binned_format_file_name(1:end-4) '_smoothed.mat'], specific_labels_names_to_use, num_cv_splits, the_training_label_names, the_test_label_names);       
 
      % create the cross-validator
      the_cross_validator = standard_resample_CV(ds, the_classifier, the_feature_preprocessors);
      the_cross_validator.num_resample_runs = settings.num_resample_runs; 
      
      the_cross_validator.display_progress.zero_one_loss = 0;     % let us supress all the output from the cross-validation procedure
      the_cross_validator.display_progress.resample_run_time = 0;
                 
      DECODING_RESULTS = the_cross_validator.run_cv_decoding;    % run the decoding analysis
 
      % save the results
      save_file_name = ['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]; 
      save(save_file_name, 'DECODING_RESULTS')
 
   end
   
   toc
   

% 6.  plot the results
    position_names = {'instr', 'choice'}


for iTrainPosition = 1:2
    
    
    % load the results from each training and test location
    for iTestPosition = 1:2
        
        load(['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]);
        all_results(iTrainPosition, iTestPosition) = DECODING_RESULTS.ZERO_ONE_LOSS_RESULTS.mean_decoding_results;
    
    end
    
    figure (1)
    subplot(1, 2, iTrainPosition)
    result_names {iTestPosition} =  {['C:\Projects\LIP_Caltech\Generalization_analysis\position_invariance_results__train_pos' num2str(iTrainPosition) '_test_pos' num2str(iTestPosition)]};
    end
    
    plot_obj = plot_standard_results_object(result_names); % create the plot results object
    %plot_obj.significant_event_times = 0;                 % put a line at the time when the stimulus was shown
    plot_obj.plot_results;                                 % display the results
    
    
    
    
    % create a bar plot for each training lcoation
    figure (2)
    subplot(1, 3, iTrainPosition)
    bar(all_results(iTrainPosition, :) .* 100);
    
    title(['Train ' position_names{iTrainPosition}])
    
    ylabel('Classification Accuracy');
    set(gca, 'XTickLabel', position_names)
    xlabel('Test position')
    
    xLims = get(gca, 'XLim');
    line([xLims], [1/7 1/7] .* 100, 'color', [0 0 0]);    % put a line at the chance level of decoding    
    
end


set(gcf, 'position', [247   315   950   300])


end






