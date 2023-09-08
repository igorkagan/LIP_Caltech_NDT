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
%bins = bins > 1


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
    
    
    
    
    
    %create  binned_labels
    binned_labels.stimulus_ID{u} = horzcat(repmat(labels(1),1, size(PSTHinstr_right,1)),...
                                           repmat(labels(2),1, size(PSTHinstr_left,1)),...
                                           repmat(labels(3),1, size(PSTHchoice_right,1)),...
                                           repmat(labels(4),1, size(PSTHchoice_left,1)));
        

    %create binned_site_info
    %unitinfo_cell = struct2cell(unitinfo);
  
    binned_site_info.session_ID(u, 1)           = str2double(unitinfo(u).session) ;
    binned_site_info.recording_channel(u, 1)    = str2double(unitinfo(u).channame); 
    binned_site_info.unit{u}                    = unitinfo(u).cellname;
    binned_site_info.alignment_event_time(u, 1) = settings4phys.initial_fixation / settings4phys.psth_bin ; % 1800sm / 25ms(bin)   %501
    

    binned_site_info.binning_parameters.raster_file_directory_name = INPUT_PATH; % OUTPUT_PATH
    binned_site_info.binning_parameters.bin_width = 1; % 150
    binned_site_info.binning_parameters.sampling_interval =  1 ; % 50
    binned_site_info.binning_parameters.start_time = 1 ;
    binned_site_info.binning_parameters.end_time = size (PSTHchoice_left, 2); % 7000 ; % info from settings4psth.psth_bin of 
    
    
if (length(binned_site_info.binning_parameters.bin_width) == 1) && (length(binned_site_info.binning_parameters.sampling_interval) == 1); % if a single bin width and step size have been specified, then create binned data that averaged data over bin_width sized bins, sampled at sampling_interval intervals
    bin_start_time = binned_site_info.binning_parameters.start_time : binned_site_info.binning_parameters.sampling_interval : (binned_site_info.binning_parameters.end_time - binned_site_info.binning_parameters.bin_width  + 1);
    bin_widths = binned_site_info.binning_parameters.bin_width .* ones(size(bin_start_time)); 
end 
    binned_site_info.binning_parameters.the_bin_start_times = bin_start_time;
    binned_site_info.binning_parameters.the_bin_widths = bin_widths;
    binned_site_info.binning_parameters.alignment_event_time = settings4phys.initial_fixation / settings4phys.psth_bin ; %501
    
    
    %create binned_data
    binned_data{u} = vertcat(PSTHinstr_right, PSTHinstr_left, PSTHchoice_right, PSTHchoice_left);
%     binned_data_BINS{u} = vertcat(PSTHinstr_right, PSTHinstr_left, PSTHchoice_right, PSTHchoice_left); % The number of neuronal firing in bins. 
%    
%     % Find all values in a matrix greater than zero and put them into a matrix that will contain one value each different from zero in ascending order. 
%     positiveValues = binned_data_BINS{u}(binned_data_BINS{u} > 0);  % Extract all positive values
%     % Remove duplicate values using 'unique' and sort them in ascending order
%     uniquePositiveValues = unique(positiveValues); % Now, 'uniquePositiveValues' contains all unique positive values from the original matrix in ascending order
%     
%     % Define the factor by which you want to interpolate (25ms to 1ms, so 25x)
%     interpolationFactor = settings4phys.psth_bin * 1000 ; % each bin = 25 ms
% 
%     % Interpolate the data to create 1ms time bins
%     [rows, cols] = size(binned_data_BINS{u});
%     newCols = cols * interpolationFactor;
%     interpolatedRaster = zeros(rows, newCols);
% 
%     for col = 1:cols
%       % Interpolate the data for each column
%      interpolatedRaster(:, (col-1)*interpolationFactor+1 : col*interpolationFactor) = repmat(binned_data_BINS{u}(:, col), 1, interpolationFactor);
%     end % Now 'interpolatedRaster' contains your raster data with 1ms time bins
%    
%     threshold = 1; % Threshold value to determine if a neuron fired (e.g., you can use a threshold of 1)
%     % Create a binary raster matrix with the same size as your input matrix
%     raster_data = interpolatedRaster >= threshold; % Now 'binaryRaster' contains your raster data, where 1 indicates a neuron firing
%     raster_data = double (raster_data);
%     
%     binned_data{u} = bin_one_site (raster_data, binned_site_info.binning_parameters.the_bin_start_times, binned_site_info.binning_parameters.the_bin_widths);
%     
    
    % saving
    new_FullName = [OUTPUT_PATH unitinfo(u).ucellname '_binned_data_forNDT.mat']; % output folder + name of file
    save(new_FullName,'binned_data', 'binned_labels', 'binned_site_info');
    disp(['Saved ' new_FullName]);
    
    
end

%  %% Create binned data
%  function  binned_data = bin_one_site(raster_data, the_bin_start_times, the_bin_widths)  
% % a helper function that bins the data for one site
%   for c = 1:length(the_bin_start_times)      
%       binned_data(:, c) = mean(raster_data(:, the_bin_start_times(c):(the_bin_start_times(c) + the_bin_widths(c) -1)), 2);            
%   end
%  end 
