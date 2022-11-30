# This script extract the harmonicity from the input *.wav file
# and saves to simple matrix file.

# Input parameters
# wav_pth - path to the *.wav file
# hnr_pth - path to the output file
# real time_step - time step in seconds
# real minimum_pitch - minimum pitch in Hz
# real silence_thr - silence threshold
# real periods_per_win - periods per window

form Extract HNR
sentence wav_pth
sentence hnr_pth
real time_step
real minimum_pitch
real silence_thr
real periods_per_win
endform

Read from file... 'wav_pth$'

To Harmonicity (cc)... time_step minimum_pitch silence_thr periods_per_win

hnrID = selected("Harmonicity");
To Matrix

mtxID = selected("Matrix");
Save as matrix text file... 'hnr_pth$'