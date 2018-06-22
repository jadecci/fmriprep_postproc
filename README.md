# Further Processing following Fmriprep

**Full steps:**

- run recon-all first: `job_recon_all.sh`
- skip 4 frames (done in CBIG_preproc)
- run fmriprep (--output-space fsaverage6): `fmriprep_singleSub.sh`
- regression (GLM using motion, wm, csf, whole-brain regressors) with censoring: `fmriprep_regress.sh`
- interpolation and bandpass: `fmriprep_censor_bp.sh`
- smooth and downsample to fsaverage5

**Compute clusters:**
