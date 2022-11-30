function [glot] = glottal(x,fs)

% Settings
F0min = 80; % Minimum F0 set to 80 Hz
F0max = 500; % Maximum F0 set to 80 Hz
frame_shift = 10; % Frame shift in ms

% Check the speech signal polarity
polarity = polarity_reskew(x,fs);
x=polarity*x;

% Extract the pitch and voicing information
[srh_f0,srh_vuv,srh_vuvc,srh_time] = pitch_srh(x,fs,F0min,F0max,frame_shift);

if isempty(srh_f0)
    % out
    glot.HRF = [];
    glot.NAQ = [];
    glot.QOQ = [];
else
    
% GCI estimation
    se_gci = se_vq(x,fs,median(srh_f0));           % SE-VQ
    
    [gf_iaif,gfd_iaif] = iaif_ola(x,fs);    % Glottal flow (and derivative) by the IAIF method
    
    [NAQ,QOQ,H1H2,HRF,PSP] = get_vq_params(gf_iaif,gfd_iaif,fs,se_gci); % Estimate conventional glottal parameters
    
    % out
    glot.HRF = HRF(:,2);
    glot.NAQ = NAQ(:,2);
    glot.QOQ = QOQ(:,2);
end



