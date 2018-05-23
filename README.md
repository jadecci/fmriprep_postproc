# Further Processing following Fmriprep

**Full steps:**

- skip 4 frames
- run fmriprep (--output-space fsaverage)
- regression (GLM using motion, wm, csf, whole-brain regressors) with censoring
- bandpass
