.. _ap_verify_ci_hits2015-package:

#####################
ap_verify_ci_hits2015
#####################

The ``ap_verify_ci_hits2015`` package is a minimal collection of images from the DECam `HiTS`_ survey, formatted for use with :doc:`/modules/lsst.ap.verify/index`.
It is intended for continuous integration.

.. _HiTS: https://doi.org/10.3847/0004-637X/832/2/155

.. _ap_verify_ci_hits2015-using:

Using ap_verify_ci_hits2015
===========================

This dataset is intended for fast integration testing of difference imaging analysis, using "goodSeeing" coadd templates, by ``ap_verify``.
Because of the small data volume it is not recommended for "stress tests" or other large-scale testing.

.. _ap_verify_ci_hits2015-contents:

Dataset contents
================

This package provides six images covering three epochs from the 2015 `HiTS`_ survey.
It contains:

* CCDs 5 and 10 from visits 411420 and 419802, from the ``Blind15A_40`` survey field, in g band.
* CCDs 56 and 60 from visit 411371, from the ``Blind15A_42`` survey field. This visit partially overlaps with the ``Blind15A_40`` visits.
* biases (``zci``) and g-band flats (``fci``)
* reference catalogs for Gaia and Pan-STARRS1, covering the raw images' footprint.
* image differencing templates coadded from HiTS 2014 data, covering the raw images' footprint.
* mock APDB catalogs based on processing the raw images in order.
* the rbResnet50-DC2 pretrained machine learning model for real/bogus classification

.. _ap_verify_ci_hits2015-contributing:

Contributing
============

``ap_verify_ci_hits2015`` is developed at https://github.com/lsst/ap_verify_ci_hits2015.
You can find Jira issues for this module under the `ap_verify <https://jira.lsstcorp.org/issues/?jql=project%20%3D%20DM%20AND%20component%20%3D%20ap_verify%20AND%20text~"hits2015"%20AND%20text~"CI">`_ component.

.. If there are topics related to developing this module (rather than using it), link to this from a toctree placed here.

.. .. toctree::
..    :maxdepth: 1
