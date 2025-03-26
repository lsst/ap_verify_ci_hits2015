Dataset management scripts
==========================

This directory has scripts for (re)creating the `ap_verify_ci_hits2015` data set.

*Any* change to the repo requires running `make_preloaded_export.py` to ensure the export file is up-to-date.
The data set will not run correctly without this step, but it also makes it easy to see and review each commit's changes.

The scripts are designed to be modular, and can be called either all at once (through `generate_all_gen3.sh`), or individually.
However, `generate_fake_injection_catalog.sh` and `import_calibs.py` are not self-contained, and the user may need to manually edit chains before or after running them.
See each script's docstring for usage instructions; those scripts that take arguments also support `--help`.

Scripts
-------
path                               | description
:----------------------------------|:-----------------------------
generate_all_gen3.sh               | Rebuild everything from scratch.
generate_calibs_gen3.sh            | NOT executable. Defines functions used by generate_calibs_gen3_science.sh.
generate_calibs_gen3_science.sh    | Creates biases and flats in an external repo (such as `repo/main`) from a fixed list of raw HiTS calibs. Intended for use with `import_calibs_gen3.py`.
generate_ephemerides_gen3.py       | Download solar system ephemerides and register them in `preloaded/`.
generate_fake_injection_catalog.sh | Create source injection catalogs in the HiTS field. Requires templates.
generate_refcats_gen3.py           | Transfer refcats from an external repo (such as `repo/main`) and register them in `preloaded/`.
generate_self_preload.py           | Create preloaded APDB datasets by simulating a processing run with no pre-existing DIAObjects.
get_nn_models.py                   | Transfer a selected pretrained model from an external repo (such as `repo/main`) and register it in `preloaded/`.
import_calibs_gen3.py              | Transfer calibs from an external repo (such as `repo/main`) and register them in `preloaded/`.
import_templates_gen3.py           | Transfer templates from an external repo (such as `repo/main`) and register them in `preloaded/`.
make_preloaded.sh                  | Replace `preloaded/` with a repo containing only dimension definitions and standard "curated" calibs.
make_preloaded_export.py           | Create an export file of `preloaded/` that's compatible with `butler import`.
script.sh                          | For the FULL `ap_verify_hits2015` data set, download official HiTS raws and MasterCals into temporary directories.
trimFits.py                        | Reduce full focal plane DECam raws to only those detectors used by this data set. Assumes untrimmed files are in `_raw/`. Not compatible with calibs.

Data Files
----------

These data files cover the full-size `ap_verify_hits2015` data set, and only a small subset is included in `ap_verify_ci_hits2015`.

path                                   | description
:--------------------------------------|:-----------
list_EXPNUM_FILTER.tsv                 | A mapping from raw FITS files to their exposure ID and physical filter.
list_OBJECT.tsv                        | A mapping from FITS files to their HiTS field pointing (if raw) or their calibration target (if MasterCal).
list_PROCTYPE.tsv                      | A mapping from FITS files to their DECam type (raw or MasterCal).
rows_as_votable_1500407676_2451.vot.gz |
