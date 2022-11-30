function [out] = F0_perturbations(s,fs,type)

% type = 'sustain phonation'
% type = 'speech'

[Fo, ~, time_marks] = irapt(s, fs, 'irapt1', type);  
    
% Segmentation of signal onto fundamental periods
[Fo_periods] = WM_phase_const(s,Fo,time_marks,fs);
[periods_Amp]= amp_extract(Fo_periods,s);
    
% Jitter
out.J_ppq5 = jitter_ppq5(Fo_periods);

% Shimmer
out.S_apq5  = shim_apq5(periods_Amp);

% F0
out.F0 = median(Fo);

end

