function hnr = praat_harmonicity(wav_pth, dir_pth, time_step, minimum_pitch, silence_thr, periods_per_win)

% This function returns harmonic-to-noise ratio (HNR). The Praat console
% application praatcon.exe and script praat_harmonicity.praat is required.
% 
% wav_pth           - path to the *.wav file
% dir_pth           - path to the directory with Praat files with backslash
%                     at the end
% time_step         - length of window in seconds (default: 0.01)
% minimum_pitch     - minimum frequency (default: 75Hz)
% silence_thr       - silence threshold (default: 0.1)
% periods_per_win   - periods per window (default: 1)
% hnr               - output HNR series

%% Paths and variables
if((nargin < 2) || isempty(dir_pth))
    dir_pth = '';
end
if((nargin < 3) || isempty(time_step))
    time_step = 0.01;
end
if((nargin < 4) || isempty(minimum_pitch))
    minimum_pitch = 75;
end
if((nargin < 5) || isempty(silence_thr))
    silence_thr = 0.1;
end
if((nargin < 6) || isempty(periods_per_win))
    periods_per_win = 1.0;
end

%% Prepare and run Praat command
hnr_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(hnr_pth, 'file'))
    hnr_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
end

cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_harmonicity.praat ' ...
    wav_pth ' ' hnr_pth ' ' num2str(time_step) ' ' ...
    num2str(minimum_pitch) ' ' num2str(silence_thr) ' ' ...
    num2str(periods_per_win)];
stat = system(cmd);

%% Load data to the environment
hnr = [];
if(~stat)
    fid = fopen(hnr_pth, 'r');
    hnr = textscan(fid, '%f', 'HeaderLines', 4);
    hnr = hnr{1,1};
    fclose(fid);
end

delete(hnr_pth);