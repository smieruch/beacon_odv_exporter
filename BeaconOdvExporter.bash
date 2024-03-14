#!/bin/bash
#
version="v1.0.0"
if [ "$1" == "--version" ]
then
    echo "BeaconOdvExporter.bash " $version
    exit
fi
#
####-----------------------------------------------------------------------####
##
## Copyright (C) 2024 Sebastian Mieruch. All rights reserved.
##                    Alfred Wegener Institute for Polar and Marine Research,
##                    Bremerhaven, Germany
##                    E-mail: sebastian.mieruch@awi.de
##
## This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
## WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
##
####-----------------------------------------------------------------------####
#
#
#
if [ "$1" == "--help" ]
then
    echo "usage: BeaconOdvExporter.bash infile outfile id_name"
    echo ""
    echo "example: /home/scripts/BeaconOdvExporter.bash /data/test.txt /results/test BEACON_DATASET_ID"
    echo ""
    echo "----infile: A merged BEACON pre-ODV .txt file, including profiles, trajectories, timeseries (full unix style filepaths are possible, e.g. /home/user/data.txt)"
    echo ""
    echo "----outfile: The prefix name of the output files (full unix style filepaths are possible, e.g. /home/user/output/mydata)"
    echo ""
    echo "----id_name: A string depicting the name of a column of a unique identifier, i.e. it must be unique for every profile, trajectory or timeseries"
    echo ""
    echo "----The output file names suffixes are: _pr.txt, _tr.txt, and _ti.txt,"
    echo ""
    echo "----This script seperates the input file by profiles, trajectories, timeseries and creates"
    echo ""
    echo "    up to 3 new files, respectively for profiles (pr), trajectories (tr), and timeseries (ti)"
    exit
fi

if [[ -z $1 || -z $2 || -z $3 ]]
then
    echo "usage: BeaconOdvExporter.bash infile outfile id_name"
    echo ""
    echo "get help: BeaconOdvExporter.bash --help"
    echo ""
    echo "get version: BeaconOdvExporter.bash --version"
    exit
fi
#

infile=$1
outfile=$2

time_name="yyyy-mm-ddThh:mm:ss.sss"
lon_name="Longitude [degrees_east]"
lat_name="Latitude [degrees_north]"
id_name=$3


for i in "_tr.txt" "_pr.txt" "_ti.txt"
do
    if [ -f "$outfile""$i" ]
    then
	rm "$outfile""$i"
    fi
done


awk '
BEGIN{
    FS="\t"
    ###this will be the line number (NR) of the line including the column names
    column_name_line=9999999999999999
    ###as long as this is true the header is printed out into the 3 files
    print_header="true"
    ###
    time_col=""
    lon_col=""
    lat_col=""
    id_col=""
    ###this is just a counter for the stations of timeseries and trajectories
    station=1
    ###this is for timeseries to fix the meta time at the start of the ti
    dataset_start_time=""
    ###if one of these is still false at the end of the script the respective file pr, tr, or ti will be removed
    exist_pr="false"
    exist_tr="false"
    exist_ti="false"
    ###default is pr, which is important especially if we have single row datasets at the beginning of the file
    current_type="pr"
    ###create 3 output files and first header lines
    print "//<DataField>Ocean</DataField>" > "'"$outfile"_tr.txt'"
    print "//<DataType>Trajectories</DataType>" > "'"$outfile"_tr.txt'"
    print "//<DataField>Ocean</DataField>" > "'"$outfile"_ti.txt'"
    print "//<DataType>TimeSeries</DataType>" > "'"$outfile"_ti.txt'"
    print "//<DataField>Ocean</DataField>" > "'"$outfile"_pr.txt'"
    print "//<DataType>Profiles</DataType>" > "'"$outfile"_pr.txt'"
}
{
    if ( print_header == "true")
    {
	###save every row in tmp
	tmp1 = $0
	tmp2 = $0
	###replace primary_var in time_ISO8601 for tr and ti
	if ( match(tmp1, /time_ISO8601/) )
	{
	    gsub(/is_primary_variable=\"F\"/, "is_primary_variable=\"T\"",tmp1)
	}
	###replace primary_var in DEPTH for pr
	if ( match(tmp2, /DEPTH/) )
	{
	    gsub(/is_primary_variable=\"F\"/, "is_primary_variable=\"T\"",tmp2)
	}
	print tmp1 > "'"$outfile"_tr.txt'"
	print tmp1 > "'"$outfile"_ti.txt'"
	print tmp2 > "'"$outfile"_pr.txt'"
    }
    ###find column name line
    if ( $1 == "Cruise" )
    {
	print_header="false"
        ###print NR
	column_name_line=NR
	###find column numbers of time, lon, lat, id
	for (i=1;i<=NF;i++)
	{
	    if ($i == "'"$time_name"'")
	    {
		time_col=i
		# print "time_col=" time_col
		# print $time_col
	    }
	    if ($i == "'"$lon_name"'")
	    {
		lon_col=i
		# print "lon_col=" lon_col
		# print $lon_col
	    }
	    if ($i == "'"$lat_name"'")
	    {
		lat_col=i
		# print "lat_col=" lat_col
		# print $lat_col
	    }
	    if ($i == "'"$id_name"'")
	    {
		id_col=i
		# print "id_col=" id_col
	        # print $id_col
	    }
	}
    }
    ###if we are in data line 2 and we have data line 1 in X
    if ( NR > column_name_line + 1 )
    {
	###print NR
	###we are now in data line 2 -> $
	###and we check against the data line 1 -> X
	###---- if $1 != X[1] at the beginning of the file ---###
	###---- we consider the sample as pr type ---###
	###---- see below ---###
	###default is profile for every new dataset
	#
	if ( $id_col == X[id_col] )
	{
	    ###we are in the same dataset
	    ###check type
	    ###4=time, 5=lon, 6=lat
	    ###profile
	    if ($time_col == X[time_col] && $lon_col == X[lon_col] && $lat_col == X[lat_col])
	    {
		current_type="pr"
	    }
	    ###timeseries / trajectory
	    if ($time_col != X[time_col])
	    {
		###timeseries
		if ($lon_col == X[lon_col] && $lat_col == X[lat_col])
		{		    
		    current_type="ti"
		}
		###trajectory
		if ($lon_col != X[lon_col] || $lat_col != X[lat_col])
		{		    
		    current_type="tr"
		}
	    }
	}
	###now we are in the same dataset or in a new
	###set the type and write X to output
	if ( current_type == "pr" )
	{
	    exist_pr="true"
	}
	if ( current_type == "tr" )
	{
	    exist_tr="true"
	    ###if trajectory every sample is a new station
	    X[2] = station
	}
	if ( current_type == "ti" )
	{
	    exist_ti="true"
	    ###if time series fix meta time
	    X[time_col] = dataset_start_time
	}
	for (i=1;i<NF;i++)
	{
	    printf "%s\t", X[i] > "'"$outfile"_'" current_type "'.txt'"
	}
	printf "%s\n", X[NF] > "'"$outfile"_'" current_type "'.txt'"
	###increment station
	station++

	###new dataset
	if ( $id_col != X[id_col])
	{
	    ###reset station to 1
	    station=1
	    ###fix this for ti
	    dataset_start_time = $time_col
	    ###default for any new dataset: important for single row datasets
	    ###those are considered as pr
	    current_type="pr"
	}
    }
    # fill line into array X
    w=split($0,X)
}
END{
    ###last sample 
    ###if it is a new dataset
    if ( station == 1 )
    {
	current_type="pr"
    }
    if ( current_type == "tr" )
    {
	###if trajectory every sample is a new station
	X[2] = station
    }
    if ( current_type == "ti" )
    {
	###if time series fix meta time
	X[time_col] = dataset_start_time
    }
    ###write
    for (i=1;i<NF;i++)
    {
	printf "%s\t", X[i] > "'"$outfile"_'" current_type "'.txt'"
    }
    printf "%s\n", X[NF] > "'"$outfile"_'" current_type "'.txt'"

    
    ###remove empty files
    if ( exist_pr == "false" )
    {
	system("rm '$outfile'_pr.txt")
    }
    if ( exist_tr == "false" )
    {
	system("rm '$outfile'_tr.txt")
    }
    if ( exist_ti == "false" )
    {
	system("rm '$outfile'_ti.txt")
    }
}' $infile #> /dev/null


