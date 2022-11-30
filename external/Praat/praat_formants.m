function frm = praat_formants(wav_pth, dir_pth, time_step, max_frm, win_len, preem)

% frm = praat_formants(wav_pth, time_step, max_frm, win_len, preem)
% 
% This function extracts first three formants and their bandwidths using
% Praat. The files praatcon.exe and praat_formants.praat must be in the
% same directory.
% 
% wav_pth       - path to the *.wav file
% dir_pth       - path to the directory with Praat files with backslash at
%                 the end
% time_step     - time step in seconds (default: 0)
% max_frm       - maximum formant in Hz (default: 5500)
% win_len       - window length in s (default: 0.025)
% preem         - pre-emphasis from Hz (default: 50)
% 
% frm(1)        - series of the 1st formant
% frm(2)        - series of the bandwidth of 1st formant
% frm(3)        - series of the 2nd formant
% frm(4)        - series of the bandwidth of 2nd formant
% frm(5)        - series of the 3rd formant
% frm(6)        - series of the bandwidth of 3rd formant

%% Paths and variables
if((nargin < 2) || isempty(dir_pth))
    dir_pth = '';
end
if((nargin < 3) || isempty(time_step))
    time_step = 0;
end
if((nargin < 4) || isempty(max_frm))
    max_frm = 5500;
end
if((nargin < 5) || isempty(win_len))
    win_len = 0.025;
end
if((nargin < 6) || isempty(preem))
    preem = 50;
end

%% Prepare and run Praat command
tmp_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(tmp_pth, 'file'))
    tmp_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
end

cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_formants.praat ' ...
    wav_pth ' ' tmp_pth ' ' num2str(time_step) ' 3 ' num2str(max_frm) ...
    ' ' num2str(win_len) ' ' num2str(preem)];
stat = system(cmd);

%% Load data to the environment
if(~stat)
    fid = fopen(tmp_pth, 'r');
    frm = textscan(fid, '%f %f %f %f %f %f', 'HeaderLines', 1, ...
        'treatAsEmpty', '--undefined--');
    fclose(fid);

    frm{1,1}(~(frm{1,1} > 0)) = [];
    frm{1,2}(~(frm{1,2} > 0)) = [];
    frm{1,3}(~(frm{1,3} > 0)) = [];
    frm{1,4}(~(frm{1,4} > 0)) = [];
    frm{1,5}(~(frm{1,5} > 0)) = [];
    frm{1,6}(~(frm{1,6} > 0)) = [];

    delete(tmp_pth);
else
    error(['Unable to run command: ' cmd]);
end