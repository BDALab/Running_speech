function F0 = praat_F0(wav_pth, dir_pth, minimum_pitch, maximum_pitch)

% F0 = praat_F0(wav_pth, dir_pth, minimum_pitch, maximum_pitch)
% 
% This function returns fundamental frequency. The Praat console
% application praatcon.exe and script praat_F0.praat is required.
% 
% wav_pth           - path to the *.wav file
% dir_pth           - path to the directory with Praat files with backslash
%                     at the end
% minimum_pitch     - minimum frequency (default: 75Hz)
% maximum_pitch     - maximum frequency (default: 400Hz)
% F0                - output F0 series

%% Paths and variables
if((nargin < 2) || isempty(dir_pth))
    dir_pth = '';
end
if((nargin < 3) || isempty(minimum_pitch))
    minimum_pitch = 75;
end
if((nargin < 4) || isempty(maximum_pitch))
    maximum_pitch = 400;
end

%% Prepare and run Praat command
F0_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(F0_pth, 'file'))
    F0_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
end

cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_F0.praat ' ...
    wav_pth ' ' F0_pth ' ' num2str(minimum_pitch) ' ' ...
    num2str(maximum_pitch)];
stat = system(cmd);

%% Load data to the environment
F0 = [];
if(~stat)
    fid = fopen(F0_pth, 'r');
    F0 = textscan(fid, '%f', 'HeaderLines', 4);
    F0 = F0{1,1};
    fclose(fid);
end

delete(F0_pth);