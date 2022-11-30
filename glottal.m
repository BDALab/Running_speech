function [glot] = glottal(x,fs,F0_min,F0_max)

if nargin < 5 || isempty(F0_min)
    F0_min = 75; % minimum F0 for voicing
end

if nargin < 6 || isempty(F0_max)
    F0_max = 400; % maximum F0 for voicing
end

frame_shift = 10; % Frame shift in ms

% Check the speech signal polarity
polarity = polarity_reskew(x,fs);
x=polarity*x;

% Extract the pitch and voicing information
[srh_f0,srh_vuv,srh_vuvc,srh_time] = pitch_srh(x,fs,F0_min,F0_max,frame_shift);

if isempty(srh_f0)
    % out
    glot.HRF = [];
    glot.NAQ = [];
    glot.QOQ = [];
else
    
% GCI estimation
    se_gci = se_vq(x,fs,median(srh_f0));           % SE-VQ
    
    [gf_iaif,gfd_iaif] = iaif_ola(x,fs);    % Glottal flow (and derivative) by the IAIF method
    
    try
        [NAQ,QOQ,H1H2,HRF,PSP] = get_vq_params(gf_iaif,gfd_iaif,fs,se_gci); % Estimate conventional glottal parameters
        glot.HRF = HRF(:,2);
        glot.NAQ = NAQ(:,2);
        glot.QOQ = QOQ(:,2);
    catch Er
        disp(['No glottal features extracted: ' Er.message])
        glot.HRF = [];
        glot.NAQ = [];
        glot.QOQ = [];
    end

end



