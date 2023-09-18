function LIP_Caltech_NDT__plot_results(save_file_name)

run('LIP_Caltech_NDT__settings');

load(save_file_name);

labels_to_use_string = strjoin(DECODING_RESULTS.DS_PARAMETERS.label_names_to_use); 


result_names{1} = save_file_name;
% create the plot results object
plot_obj = plot_standard_results_object(result_names);

% put a line at the time when the stimulus was shown
plot_obj.significant_event_times = settings.significant_event_times;

plot_obj.errorbar_file_names = result_names;
plot_obj.errorbar_type_to_plot = settings.errorbar_type_to_plot;

% display the results
plot_obj.plot_results;

title(labels_to_use_string);

set(gca,'Xlim',settings.time_lim, 'Ylim',settings.y_lim);

saveas(gcf, [save_file_name(1:end-4) '_' labels_to_use_string '_DA_as_a_function_of_time.png']);

