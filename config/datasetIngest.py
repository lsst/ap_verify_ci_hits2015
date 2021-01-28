config.refcats = {
    'gaia': 'gaia_HiTS_2015.tar.gz',
    'panstarrs': 'ps1_HiTS_2015.tar.gz'
}

# for ingester in [config.dataIngester, config.calibIngester]:
#     ingester.parse.extnames = ['S22', 'S26', 'N25', 'N29', ]
config.dataIngester.parse.extnames = ['S22', 'S26', 'N25', 'N29', ]
config.curatedCalibIngester.parse.extnames = []

# This option allows "community pipeline produced" calibrations to be
# ingested correctly, preventing the case in which some dates are
# unable to find the correct calibration.
config.calibIngester.register.incrementValidEnd = False
