# beacon odv exporter

## [Read the CHANGES.md](https://github.com/smieruch/beacon_odv_exporter/blob/master/CHANGES.md)

## General
Convert BEACON pre-ODV .txt ocean data files to ODV Generic
Spreadsheet Format, splitting the original file into up to three
individual files for ocean profiles, trajectories or timeseries.

## Usage
Call *BeaconODVExporter.bash --help* for more information how to use it.

## Requirements
- The input pre-ODV file must have the parameters
  **Cruise** **Station** **Type**
  **yyyy-mm-ddThh:mm:ss.sss** **Longitude [degrees_east]** **Latitude
  [degrees_north]** in the first 6 columns.

- The input file has to provide an identifier in one column, which is
  unique for every profile, timeseries or trajectory.
  
## Performance
- The script is fast. Depending on the number of data columns, it
  processes in the order of 100.000 to 400.000 lines of data per second.

- It processes the data sequentially, i.e. without
  loading the input data into memory. Therefore input data can be of
  arbitrary size (as long as enough hard disc space is available).
  
- Because nearly no memory is used, it can be run on light-weight hardware.

