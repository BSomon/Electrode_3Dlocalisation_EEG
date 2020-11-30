# Electrode_3Dlocalisation_EEG
This folder gives some tools to plot electrode localization after using a 3D scanning system. 
It uses EEGLAB functions to display in a 3D graphic the localisation of each electrode for all your participants.
All electrode location files for each participant (a CED file) must be put in separate folders.
The script at the root will go into each folder separately (".\Participant-1", ".\Participant-2", ..., ".\Participant-n") to read the electrode locations. 

The script computes several metrics as well as statistical comparisons to detect the distance to a reference template (inter-electrode distance, distance to the standard localisation, etc).
Everything is then saved into a file called "Localisation.mat".
The metrics are:
 - Loc_init: the initial (raw) electrode locations
 - Loc_stand: the standard (reference) electrode locations (e.g. from the 10-20 system)
 - Loc_norm: electrode location normalized according to the fiducials of the participant (Nasion at X=1; Left Helix-tragus Junction at Y=1; max(abs(z(i))) at Z = 1)
 - Loc_norm_max: electrode location normalized according to the furthest x, y and z (every value is between 0 and 1)
 - Dist_interelec: Interelectrode distance
 - Dist_interelec_norm: Interelectrode disctance after normalization
 - Dist_ref: Distance to the standard (reference) electrodes

T-tests give: the distribution of inter-electrode distances and of the distances to the standard electrodes.

The reference template needs to be provided as a CED file at the beginning.

If you have any error/difficulty contact me: bertillesomon@gmail.com
