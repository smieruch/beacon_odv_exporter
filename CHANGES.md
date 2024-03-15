# Changes

## 2024/03/15

- New output file with suffix *_er.txt* is generated if the data type
  (trajectory, profile, timeseries) changes within a dataset. The
  involved data lines are written to this file ADDITIONALLY, so that
  the data in the output files can be further (manual) investigated.

## 2024/03/14

- New input parameter, *id_name* defining the name of a column of a
  unique dataset identifier, i.e. *id_name* is unique for every
  profile, timeseries, trajectory

