1. System requirements
This code has been last tested on Matlab R2018b.
On a machine with the following specs:
Processor Intel(R) Core(TM) i7-6700 CPU @3.40GHz
RAM 16GB
64-bit OS, Windows 10 Pro, version 1809.

It is however compatible with previous versions, R2015b or further.
For system requirements check Mathworks's website
https://www.mathworks.com/content/dam/mathworks/mathworks-dot-com/support/sysreq/files/SystemRequirements-Release2015a_Windows.pdf

2. Installation guide
No installation is required. The code is plug-and-play on Matlab.
Matlab installation packages vary across different providers.
The following functions are part of optional toolboxes:
selforgmap : Deep Learning Toolbox
butter , filtfilt , gausswin : Signal Processing Toolbox
zscore : Statistics and Machine Learning Toolbox

3. Demo
Online code: Online_decoder_calibration.m
Open the file in Matlab and run each of the three sections.
The directory containing sample data (BrainAct.mat) must be open in the Matlab path.
BrainAct.mat contains online-detected MUA during an 8s trial where a rat crossed a runway.
The code will:
- train the M1 decoder used in the article (see Methods: Cortex-midbrain interface)
- display raw data
- display data labeled by states defined by computed SOM output
- calculate the estimated weight matrix w (w_est)
Online, the normalized control variable y=wn is used to trigger stimulation on and off.
- dispaly the output the online decoder would have produced if tested using w_est.
Expected overall runtime: <1s 

Offline code: code_neuraldata.m
Open the file in Matlab and run.
The directory containing sample data (SampleRecording.mat) must be open in the Matlab path.
SampleRecording.mat contains raw 12kHz multi-unit traces (48 channels: 32 M1 and 16 MLR) during a 4s trial where a rat crossed a runway.
The code will:
-extract MUA
-display binned spike rasters
-display M1 and MLR activation with respect to the time of the first foot-off.
Expected overall runtime: <1s 

4. Instructions for use
Real or synthetic data could be fed to the presented code.
The process is relatively simple:
- generate real or synthetic copies of the files BrainAct.mat or SampleRecording.mat
BrainAct.mat : BrainAct should be a c x t matrix, where 
c is the number of channels and t is in centiseconds.
SampleRecording.mat : 
wavb should be a 32 x t matrix, where t is the number of samples, 
representing 32 MUA electrical traces from the cortex
wav2 should be a 16 x t matrix, where t is the number of samples, 
representing 16 MUA electrical traces from the MLR
sampFreq is the sampling rate of the MUA traces
firststep is the time (in s) where the first foot-off occurs
synchdelay is a synchronizing delay between the video and the bioamp hardwares.

