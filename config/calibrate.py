# Config override for lsst.pipe.tasks.calibrate.CalibrateTask
# Ensure we're using the refcats that are actually in this dataset, regardless
# of what task defaults are.

# Use gaia for astrometry (phot_g_mean for everything, as that is the broadest
# band with the most depth)
config.connections.astromRefCat = "gaia_dr2_20200414"
config.astromRefObjLoader.anyFilterMapsToThis = "phot_g_mean"

# Use panstarrs for photometry (grizy filters)
config.connections.photoRefCat = "ps1_pv3_3pi_20170110"
config.photoRefObjLoader.filterMap = {
    "u": "g",
    "VR": "g"}
