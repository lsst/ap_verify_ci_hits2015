config.refcats = {
    'gaia': 'gaia_HiTS_2015.tar.gz',
    'pan-starrs': 'ps1_HiTS_2015.tar.gz'
}

for ingester in [config.dataIngester, config.calibIngester]:
    ingester.parse.extnames = ['S22', 'S26', 'N25', 'N29', ]
config.defectIngester.parse.extnames = []
