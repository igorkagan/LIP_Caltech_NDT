% LIP_Caltech_NDT_settings

INPUT_PATH = 'Y:\Projects\LIP_Caltech\';
OUTPUT_PATH = 'E:\Projects\LIP_Caltech\NDT\';

% data preparation
settings.bin_dur = 50; % ms
settings.smoothing_window = 3; % number of bins to smooth over
settings.smoothing_method = 'gaussian'; % movmean / gaussian, see smoothdata


% Decoding
settings.num_cv_splits = 20;
settings.num_resample_runs = 50;

% plotting
settings.time_lim = [-1000 5000]; % s, relative to cue onset
settings.y_lim = [30 100];

settings.significant_event_times = [0 200 1200]; % for plotting relevant trial events

settings.errorbar_type_to_plot = 1;



