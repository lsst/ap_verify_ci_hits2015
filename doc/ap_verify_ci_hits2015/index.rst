.. _ap_verify_ci_hits2015-package:

#####################
ap_verify_ci_hits2015
#####################

The ``ap_verify_ci_hits2015`` package is a minimal collection of images from the DECam `HiTS`_ survey.

.. _HiTS: https://doi.org/10.3847/0004-637X/832/2/155

Project info
============

Repository
   https://github.com/lsst/ap_verify_ci_hits2015

.. Datasets do not have their own (or a collective) Jira components; by convention we include them in ap_verify

Jira component
   `ap_verify <https://jira.lsstcorp.org/issues/?jql=project %3D DM %20AND%20 component %3D ap_verify %20AND%20 text ~ "hits2015" %20AND%20 text ~ "CI">`_

Dataset Contents
================

This package provides six images covering three epochs from the 2015 `HiTS`_ survey.
It contains:

* CCDs 5 and 10 from visits 411420 and 419802, from the ``Blind15A_40`` survey field, in g band.
* CCDs 56 and 60 from visit 411371, from the ``Blind15A_42`` survey field. This visit partially overlaps with the ``Blind15A_40`` visits.
* biases (``zci``) and g-band flats (``fci``)
* defect masks (``bpm``) from December 5, 2014.
* reference catalogs for Gaia DR1 and Pan-STARRS1, covering the raw images' footprint.
* image differencing templates coadded from HiTS 2014 data, covering the raw images' footprint.

Intended Use
============

This dataset is intended for fast integration testing of difference imaging analysis, using "deep" coadd templates, by ``ap_verify``.
Because of the small data volume it is not recommended for "stress tests" or other large-scale testing.

