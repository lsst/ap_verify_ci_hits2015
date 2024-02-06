# Config override for lsst.meas.transiNet.RBTransiNetTask
# Ensure we're using the model that's actually in this dataset,
# regardless of what task defaults are.

config.modelPackageStorageMode = "butler"
config.modelPackageName = None
