# This script extracts the voice analysis info from Praat report.

# Input parameters
# wav_pth - path to the *.wav file
# out_pth - path to the output file
# time_lo - lower time range in seconds
# time_up - upper time range in seconds
# pitch_lo - lower pitch range in Hz
# pitch_up - upper pitch range in Hz
# max_per - maximum period factor
# max_ampl - maximum amplitude factor
# silence_th - silence threshold
# voicing_th - voicing threshold

form Extract Info
sentence wav_pth
sentence out_pth
real time_lo
real time_up
real pitch_lo
real pitch_up
real max_per
real max_ampl
real silence_th
real voicing_th
endform

soundID = Read from file... 'wav_pth$'
pointID = To PointProcess (periodic, cc)... pitch_lo pitch_up

select soundID
pitchID = To Pitch... 0.0 pitch_lo pitch_up

select all
voiceReport$ = Voice report... time_lo time_up pitch_lo pitch_up max_per max_ampl silence_th voicing_th

pitch_med = extractNumber(voiceReport$, "Median pitch:")
pitch_mean = extractNumber(voiceReport$, "Mean pitch:")
pitch_std = extractNumber(voiceReport$, "Standard deviation:")
pitch_min = extractNumber(voiceReport$, "Minimum pitch:")
pitch_max = extractNumber(voiceReport$, "Maximum pitch:")

voice_frac = extractNumber(voiceReport$, "Fraction of locally unvoiced frames:")
voice_nbreaks = extractNumber(voiceReport$, "Number of voice breaks:")
voice_degree = extractNumber(voiceReport$, "Degree of voice breaks:")

jitt_local = extractNumber(voiceReport$, "Jitter (local):")
jitt_localabs = extractNumber(voiceReport$, "Jitter (local, absolute):")
jitt_rap = extractNumber(voiceReport$, "Jitter (rap):")
jitt_ppq5 = extractNumber(voiceReport$, "Jitter (ppq5):")
jitt_ddp = extractNumber(voiceReport$, "Jitter (ddp):")

shimm_local = extractNumber(voiceReport$, "Shimmer (local):")
shimm_localdb = extractNumber(voiceReport$, "Shimmer (local, dB):")
shimm_apq3 = extractNumber(voiceReport$, "Shimmer (apq3):")
shimm_apq5 = extractNumber(voiceReport$, "Shimmer (apq5):")
shimm_apq11 = extractNumber(voiceReport$, "Shimmer (apq11):")
shimm_dda = extractNumber(voiceReport$, "Shimmer (dda):")

mean_aut = extractNumber(voiceReport$, "Mean autocorrelation:")
mean_nh = extractNumber(voiceReport$, "Mean noise-to-harmonics ratio:")
mean_hn = extractNumber(voiceReport$, "Mean harmonics-to-noise ratio:")

fileappend 'out_pth$' Pitch'newline$'
fileappend 'out_pth$' 'pitch_med' 'pitch_mean' 'pitch_std' 'pitch_min' 'pitch_max''newline$'

fileappend 'out_pth$' Voicing'newline$'
fileappend 'out_pth$' 'voice_frac' 'voice_nbreaks' 'voice_degree''newline$'

fileappend 'out_pth$' Jitter'newline$'
fileappend 'out_pth$' 'jitt_local' 'jitt_localabs' 'jitt_rap' 'jitt_ppq5' 'jitt_ddp''newline$'

fileappend 'out_pth$' Shimmer'newline$'
fileappend 'out_pth$' 'shimm_local' 'shimm_localdb' 'shimm_apq3' 'shimm_apq5' 'shimm_apq11' 'shimm_dda''newline$'

fileappend 'out_pth$' Harmonicity of the voiced parts only'newline$'
fileappend 'out_pth$' 'mean_aut' 'mean_nh' 'mean_hn''newline$'