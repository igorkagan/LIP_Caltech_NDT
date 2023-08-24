% function LIP_Caltech_NDT__one_run_mat_into_individual_files
% This code load one psth.mat file and convert it to N (where N is number of units) mat files, one mat file per unit.
% The mat files named according to the unit name.

run('LIP_Caltech_NDT_settings');

monkey_name  = ['Gutalin']; % Hanuman 
recording_date = ['20110126']; 

input_files_folder = ['Y:\Projects\LIP_Caltech\' monkey_name '\' recording_date]; 
output_files_folder = 'C:\Projects\LIP_Caltech\NDT\'; 

mkdir(output_files_folder)

%% load the file

load('Y:\Projects\LIP_Caltech\Gutalin\20110126\GU_20110126_1-01.psth.mat');

%% create and save new files from one file 

% count number of units in this run
N_units =  numel(unitinfo);


for u = 1:N_units, % for each unit

    % 4 conditions
    PSTH_mem_instr_right = PSTH_mem_instr(u,1).histo_trial ; % instr right
    PSTH_mem_instr_left = PSTH_mem_instr(u,2).histo_trial ; % instr left
    PSTH_mem_choice_right = PSTH_mem_choice(u,1).histo_trial ; % choice right
    PSTH_mem_choice_left = PSTH_mem_choice(u,2).histo_trial ; % choice left
    
    new_FullName = [output_files_folder unitinfo(u).ucellname '_binned_data_forNDT.mat']; % output folder + name of file
    save(new_FullName,'PSTH_mem_instr_right', 'PSTH_mem_instr_left', 'PSTH_mem_choice_right', 'PSTH_mem_choice_left');
    disp(['Saved ' new_FullName]);
      
end

