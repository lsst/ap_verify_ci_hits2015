from astropy.io import fits


def trimFits(inFile, outFile, ccds):
    # For some reason update doesn't work
    with fits.open(inFile, mode='readonly') as hdus:
        toRemove = []
        # Can only remove HDUs by index... really???
        for i in range(1, len(hdus)):
            if hdus[i].header['CCDNUM'] not in ccds:
                toRemove.append(i)
        toRemove.sort(reverse=True)
        for i in toRemove:
            hdus.pop(i)
        print('Remaining HDUs: %s' % [hdu.header.get('CCDNUM', 'Primary') for hdu in hdus])
        hdus.writeto(outFile)


trimFits('_raw/c4d_150309_055748_ori.fits.fz', 'raw/c4d_150309_055748_ori.fits.fz', ccds=[5, 10])
trimFits('_raw/c4d_150218_070619_ori.fits.fz', 'raw/c4d_150218_070619_ori.fits.fz', ccds=[5, 10])
trimFits('_raw/c4d_150218_052850_ori.fits.fz', 'raw/c4d_150218_052850_ori.fits.fz', ccds=[56, 60])
# Warning: cannot trim calibs because Butler code assumes each CCD appears in order
