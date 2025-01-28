# Changes

## 2025/01/28

- The *id_name*, which is the name of the column that serves as a
  unique dataset id, was producing errors if it was the last column in
  the file, because of the line break character, which was still
  connected to the last column name. Now this line break character is
  removed from the columnk name during processing.

## 2024/03/15

- New output file with suffix *_er.txt* is generated if the data type
  (trajectory, profile, timeseries) changes within a dataset. The
  involved data lines are written to this file ADDITIONALLY, so that
  the data in the output files can be further (manual) investigated.

## 2024/03/14

- New input parameter, *id_name* defining the name of a column of a
  unique dataset identifier, i.e. *id_name* is unique for every
  profile, timeseries, trajectory

