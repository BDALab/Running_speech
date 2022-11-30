# This script extract the first three formants and
# appropriate bandwidths. These data are stored to
# the table.

# Input parameters
# wav_pth - path to the *.wav file
# out_pth - path to the output file
# real time_step - time step in seconds
# frm_num - max number of formants
# max_frm - maximum formant in Hz
# win_len - window length in s
# preem - pre-emphasis from Hz

form Extract HNR
sentence wav_pth
sentence out_pth
real time_step
real frm_num
real max_frm
real win_len
real preem
endform

soundID = Read from file... 'wav_pth$'
select soundID

frmID = To Formant (burg)... time_step frm_num max_frm win_len preem
select frmID

tabID = Down to Table... 0 0 6 0 3 0 3 1
select tabID

Save as tab-separated file... 'out_pth$'