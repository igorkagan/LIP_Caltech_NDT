

input_files_folder = ['C:\Projects\LIP_Caltech\NDT\'] ;
output_files_folder = ['C:\Projects\LIP_Caltech\NDT\Сonverted_and_suitable_for_NDT\'] ;

mkdir(output_files_folder);


input_files_folder_original_data = ['Y:\Projects\LIP_Caltech\Gutalin\20110126\'] ;

%% load the files and put in into one array called binned_data

% Set the pattern you want to match in the filenames using regular expression
file_pattern = 'GU_20110126_\d+\_binned_data_forNDT.mat'; % \d+ matches one or more digits

% List files in the directory that match the pattern
matching_files = dir(fullfile(input_files_folder, '*.mat'));

% Loop through the matching files and load each one
for i = 1:length(matching_files)
    file_name = matching_files(i).name;
    cd(input_files_folder)
    load(file_name);
    
    %create binned_data
    binned_data {:, i} = vertcat (PSTH_mem_instr_right, PSTH_mem_instr_left, PSTH_mem_choice_right, PSTH_mem_choice_left);
    
    %create binned_labels
    binned_labels.stimulus_ID {:, i} = horzcat (size(PSTH_mem_instr_right,1), size(PSTH_mem_instr_left,1), size(PSTH_mem_choice_right,1), size(PSTH_mem_choice_left,1));
       
    %create binned_site_info
    cd(input_files_folder_original_data);
    load('GU_20110126_1-01.psth.mat', 'unitinfo');
    binned_site_info.session_ID (i, 1) = 1
    binned_site_info.recording_channel(i, 1) = vertcat (unitinfo(i).channame); 
    binned_site_info.unit {:, i} = horzcat (unitinfo(i).cellname);
    binned_site_info.alignment_event_time = 1
end


 