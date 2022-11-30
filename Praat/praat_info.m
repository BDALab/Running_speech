function praat_str = praat_info(wav_pth, dir_pth, time_lo, time_up, pitch_lo, pitch_up, max_per, max_ampl, silence_th, voicing_th)

% [praat_str] = praat_info(wav_pth, time_lo, time_up, pitch_lo, pitch_up, max_per, max_ampl, silence_th, voicing_th)
% 
% This function calculates different speech features using Praat. The
% meaning of each feature can be found in Praat help.
% 
% wav_pth       - path to the *.wav file
% dir_pth       - path to the directory with Praat files with backslash at
%                 the end
% time_lo       - lower time range in seconds (default: 0.0)
% time_up       - upper time range in seconds (default: 0.0)
% pitch_lo      - lower pitch range in Hz (default: 75)
% pitch_up      - upper pitch range in Hz (default: 400)
% max_per       - maximum period factor (default: 1.3)
% max_ampl      - maximum amplitude factor (default: 1.6)
% silence_th    - silence threshold (default: 0.03)
% voicing_th    - voicing threshold (default: 0.45)
% 
% praat_str.F0_median           - median of F0 [Hz]
% praat_str.F0_mean             - mean of F0 [Hz]
% praat_str.F0_std              - standard deviation of F0 [Hz]
% praat_str.F0_min              - min F0 [Hz]
% praat_str.F0_max              - max F0 [Hz]
% 
% praat_str.voicing_frac        - fraction of locally unvoiced frames [%]
% praat_str.voicing_nbreaks     - number of voice breaks
% praat_str.voicing_degree      - degree of voice breaks [%]
% 
% praat_str.jitter_local        - jitter (local) [%]
% praat_str.jitter_localabs     - jitter (local, absolute) [s]
% praat_str.jitter_rap          - jitter (rap) [%]
% praat_str.jitter_ppq5         - jitter (ppq5) [%]
% praat_str.jitter_ddp          - jitter (ddp) [%]
% 
% praat_str.shimm_local         - shimmer (local) [%]
% praat_str.shimm_localdb       - shimmer (local, dB) [dB]
% praat_str.shimm_apq3          - shimmer (apq3) [%]
% praat_str.shimm_apq5          - shimmer (apq5) [%]
% praat_str.shimm_apq11         - shimmer (apq11) [%]
% praat_str.shimm_dda           - shimmer (dda) [%]
% 
% praat_str.hnr_aut             - mean autocorrelation
% praat_str.hnr_nh              - mean noise-to-harmonics ratio
% praat_str.hnr_hn              - mean harmonics-to-noise ratio [dB]

%% Paths and variables
if((nargin < 2) || isempty(dir_pth))
    dir_pth = '';
end
if((nargin < 3) || isempty(time_lo))
    time_lo = 0.0;
end
if((nargin < 4) || isempty(time_up))
    time_up = 0.0;
end
if((nargin < 5) || isempty(pitch_lo))
    pitch_lo = 75;
end
if((nargin < 6) || isempty(pitch_up))
    pitch_up = 400;
end
if((nargin < 7) || isempty(max_per))
    max_per = 1.3;
end
if((nargin < 8) || isempty(max_ampl))
    max_ampl = 1.6;
end
if((nargin < 9) || isempty(silence_th))
    silence_th = 0.03;
end
if((nargin < 10) || isempty(voicing_th))
    voicing_th = 0.45;
end

%% Prepare and run Praat command
tmp_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
while(exist(tmp_pth, 'file'))
    tmp_pth = [pwd '\' num2str(round(rand(1,1)*1e5)) '.tmp'];
end

cmd = [dir_pth 'praatcon.exe' ' ' dir_pth 'praat_info.praat ' wav_pth ...
    ' ' tmp_pth ' ' num2str(time_lo) ' ' num2str(time_up) ' ' ...
    num2str(pitch_lo) ' ' num2str(pitch_up) ' ' num2str(max_per) ' ' ...
    num2str(max_ampl) ' ' num2str(silence_th) ' ' num2str(voicing_th)];
stat = system(cmd);

%% Load data to the environment
if(~stat)
    fid = fopen(tmp_pth, 'r');
    pitch = textscan(fid, '%f %f %f %f %f', 1, 'HeaderLines', 1);
    voicing = textscan(fid, '%f %f %f', 1, 'HeaderLines', 2);
    jitter = textscan(fid, '%f %f %f %f %f', 1, 'HeaderLines', 2);
    shimmer = textscan(fid, '%f %f %f %f %f %f', 1, 'HeaderLines', 2);
    hnr = textscan(fid, '%f %f %f', 1, 'HeaderLines', 2);
    fclose(fid);

    delete(tmp_pth);

    % Save data to the structure
    praat_str.F0_median = pitch{1,1};
    praat_str.F0_mean = pitch{1,2};
    praat_str.F0_std = pitch{1,3};
    praat_str.F0_min = pitch{1,4};
    praat_str.F0_max = pitch{1,5};

    praat_str.voicing_frac = voicing{1,1}*100;
    praat_str.voicing_nbreaks = voicing{1,2};
    praat_str.voicing_degree = voicing{1,3}*100;

    praat_str.jitter_local = jitter{1,1}*100;
    praat_str.jitter_localabs = jitter{1,2};
    praat_str.jitter_rap = jitter{1,3}*100;
    praat_str.jitter_ppq5 = jitter{1,4}*100;
    praat_str.jitter_ddp = jitter{1,5}*100;

    praat_str.shimm_local = shimmer{1,1}*100;
    praat_str.shimm_localdb = shimmer{1,2};
    praat_str.shimm_apq3 = shimmer{1,3}*100;
    praat_str.shimm_apq5 = shimmer{1,4}*100;
    praat_str.shimm_apq11 = shimmer{1,5}*100;
    praat_str.shimm_dda = shimmer{1,6}*100;

    praat_str.hnr_aut = hnr{1,1};
    praat_str.hnr_nh = hnr{1,2};
    praat_str.hnr_hn = hnr{1,3};
end