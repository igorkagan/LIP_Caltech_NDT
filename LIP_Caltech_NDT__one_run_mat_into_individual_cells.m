% [binned_data binned_labels binned_site_info] = function LIP_Caltech_NDT__one_run_mat_into_individual_cells(mat_filename)
% LIP_Caltech_NDT__one_run_mat_into_individual_cells('Y:\Projects\LIP_Caltech\Gutalin\20110126\GU_20110126_1-01.psth.mat')

% This code loads one psth.mat file and converts it to a cell array (where N is number of units), one cell per unit, according to NDT binned data format.

run('LIP_Caltech_NDT_settings');

mkdir(OUTPUT_PATH);

% load(mat_filename);
load('Y:\Projects\LIP_Caltech\Gutalin\20110126\GU_20110126_1-01.psth.mat'); % once debug is complete, comment this line and enable the line above


% count number of units in this run
N_units =  numel(unitinfo);

if ~exist('PSTHinstr','var');
    PSTHinstr       = PSTH_mem_instr;
    PSTHchoice      = PSTH_mem_choice;
end

% adjust timeline
bins = bins > 1


% labels
labels = {'instr_r','instr_l','choice_r','choice_l'};

for u = 1:N_units % for each unit

    % 4 conditions
    
    if size(PSTH_mem_instr,2) > 2 % 8 targets, sort to right: 2,3,4 and left: 6, 7, 8
        
        PSTHinstr_right = [PSTHinstr(u,2).histo_trial; PSTHinstr(u,3).histo_trial PSTHinstr(u,4).histo_trial];
        PSTHinstr_left  = [PSTHinstr(u,6).histo_trial; PSTHinstr(u,7).histo_trial PSTHinstr(u,8).histo_trial];
        PSTHchoice_right = [PSTHchoice(u,2).histo_trial; PSTHchoice(u,3).histo_trial PSTHchoice(u,4).histo_trial];
        PSTHchoice_left  = [PSTHchoice(u,6).histo_trial; PSTHchoice(u,7).histo_trial PSTHchoice(u,8).histo_trial];
        
        
    else % 2 targets
        
        PSTHinstr_right = PSTHinstr(u,1).histo_trial ; % instr right
        PSTHinstr_left = PSTHinstr(u,2).histo_trial ; % instr left
        PSTHchoice_right = PSTHchoice(u,1).histo_trial ; % choice right
        PSTHchoice_left = PSTHchoice(u,2).histo_trial ; % choice left
        
    end
    
    %create binned_data
    binned_data{u} = vertcat(PSTHinstr_right, PSTHinstr_left, PSTHchoice_right, PSTHchoice_left);
   
    
    binned_labels.stimulus_ID{u} = horzcat(repmat(labels(1),1, size(PSTHinstr_right,1)),...
                                           repmat(labels(2),1, size(PSTHinstr_left,1)),...
                                           repmat(labels(3),1, size(PSTHchoice_right,1)),...
                                           repmat(labels(4),1, size(PSTHchoice_left,1)));
        

    %create binned_site_info
    binned_site_info.session_ID(u)          = unitinfo(u).session;
    binned_site_info.recording_channel(u)   = unitinfo(u).channame; 
    binned_site_info.unit{u}                = unitinfo(u).ucellname;
    binned_site_info.alignment_event_time(u) = 1800;
    

    binned_site_info.binning_parameters.raster_file_directory_name = OUTPUT_PATH;
    binned_site_info.binning_parameters.bin_width = 150;
    binned_site_info.binning_parameters.sampling_interval =  50
    binned_site_info.binning_parameters.start_time = 1
    binned_site_info.binning_parameters.end_time = 1000
    binned_site_info.binning_parameters.the_bin_start_times = [1 51 101 151 201 251 301 351 401 451 501 551 601 651 701 751 801 851]
    binned_site_info.binning_parameters.the_bin_widths = [150 150 150 150 150 150 150 150 150 150 150 150 150 150 150 150 150 150]
    binned_site_info.binning_parameters.alignment_event_time = 501
    
    
    % saving
%     new_FullName = [OUTPUT_PATH unitinfo(u).ucellname '_binned_data_forNDT.mat']; % output folder + name of file
%     save(new_FullName,'PSTH_mem_instr_right', 'PSTH_mem_instr_left', 'PSTH_mem_choice_right', 'PSTH_mem_choice_left');
%     disp(['Saved ' new_FullName]);
      
end

