# Config override for lsst.pipe.tasks.calibrate.CalibrateTask
# Ensure we're using the refcats that are actually in this dataset, regardless
# of what task defaults are.

# Use gaia for astrometry (phot_g_mean for everything, as that is the broadest
# band with the most depth)
config.connections.astrometry_ref_cat = "gaia_dr2_20200414"
config.astrometry_ref_loader.anyFilterMapsToThis = "phot_g_mean"

# Use panstarrs for photometry (grizy filters)
config.connections.photometry_ref_cat = "ps1_pv3_3pi_20170110"
config.photometry_ref_loader.filterMap = {
    "u": "g",
    "VR": "g"}
