function vad = praat_VAD(y, fs, time_step, minimum_pitch, silence_thr, periods_per_win, n_seg)

% vad = praat_VAD(y, fs, time_step, minimum_pitch, silence_thr, periods_per_win, n_seg)
% 
% This function returns a logic vector that identifies the presence of
% speech. The Praat console application praatcon.exe and script
% praat_VAD.praat is required.
% 
% y                 - input column signal
% fs                - sampling frequency
% time_step         - length of window in seconds (default: 0.01)
% minimum_pitch     - minimum frequency (default: 75Hz)
% silence_thr       - silence threshold (default: 0.1)
% periods_per_win   - periods per window (default: 1)
% n_seg             - length of output vector; if set to -1 the length will
%                     be determined by Praat (default: -1)
% vad               - output VAD series

%% Paths and variables
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
if((nargin < 7) || isempty(n_seg))
    n_seg = -1;
end

dir_pth = [fileparts(mfilename('fullpath')) filesep];

%% Store signal to the temporary *.wav file
wav_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.wav'];
while(exist(wav_pth, 'file'))
    wav_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.wav'];
end

audiowrite(wav_pth, y, fs);

%% Prepare and run Praat command
hnr_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(hnr_pth, 'file'))
    hnr_pth = [pwd filesep num2str(round(rand(1,1)*1e5)) '.tmp'];
end

if(strcmp(computer, 'MACI64'))
    cmd = ['/Applications/Praat.app/Contents/MacOS/Praat --run' ' ' ...
        'praat_VAD.praat ' wav_pth ' ' hnr_pth ' ' num2str(time_step) ...
        ' ' num2str(minimum_pitch) ' ' num2str(silence_thr) ' ' ...
        num2str(periods_per_win)];
else
    cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_VAD.praat ' ...
    wav_pth ' ' hnr_pth ' ' num2str(time_step) ' ' ...
    num2str(minimum_pitch) ' ' num2str(silence_thr) ' ' ...
    num2str(periods_per_win)];
end

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
delete(wav_pth);

%% Set HNR to the binary values
sel = hnr > -200;
hnr(sel) = 1;
hnr(~sel) = 0;

%% Mark silence shorter than 0.05s as speech
tmp = find(abs(hnr(1:end-1)-hnr(2:end)), 1);

if(~isempty(tmp))
    brd = [1; find(abs(hnr(1:end-1)-hnr(2:end)))];
    brd(end) = length(hnr);
    brd = [brd(1:end-1) brd(2:end)];

    brd(:,3) = brd(:,2)-brd(:,1)+1;

    if(hnr(1) == 0)
        brd(1:2:end,4) = 0;
        brd(2:2:end,4) = 1;
    else
        brd(1:2:end,4) = 1;
        brd(2:2:end,4) = 0;
    end

    brd = brd(brd(:,3) < 0.05/time_step, :);
    brd = brd(brd(:,4) == 0, :);

    for i = 1:size(brd,1)
        hnr(brd(i,1):brd(i,2)) = 1;
    end
end

%% Get the VAD vector
if(n_seg > 0)
    tmp = fix(linspace(1,length(hnr),n_seg));
    hnr = hnr(tmp);
end

vad = logical(hnr);