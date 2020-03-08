#This script is created for ABE65100 lab06
#Last modified: 02/28/2020
#Author: Pin-Ching Li
#This script aims to find stations with  elevation >= 200 ft.
#Then copy those files into the HigherElevation directory

# create the directory HigherElevation
if [ -d "HigherElevation" ]
then
	echo "HigherElevation directory already exists"
else
	mkdir HigherElevation
fi
# write loop to copy the stations file which has elevation>200ft
# to directory HigherElevation
for file in StationData/*
do
	# name of the file in StationData folder
	name=$file
	# use awk to get altitude value
	al_val=$(awk 'NR==5,NR==5{print $4}' $name)
	threshod=200.0
	# write if statement of station elevation larger than 200
	# float number format for if statement with %%.*	
	if [ ${al_val%%.*} >=  ${threshold%%.*} ]
	then	
		# echo the filename
   		echo $name
		# copy the files to Higher Elevation
		cp $name HigherElevation
	# end of if
	fi
# end of for loop
done

# extract lat lon for each file in StationData folder
# store longitude of files in StationData folder to Long.list 
# times -1 because in USA the longitude is negative
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
# store lat information of files in StationData to Lat.list
awk '/Latitude/ {print  $NF}' StationData/Station_*.txt > Lat.list
# add two lists above to AllStations.xy file
paste Long.list Lat.list > AllStations.xy

# repeat the same thing for each file in HigherElevation folder
# store longitude of files in HigherElevation folder to HELong.list 
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
# store lat information of files in HigherElevation to HELat.list
awk '/Latitude/ {print  $NF}' HigherElevation/Station_*.txt > HELat.list
# add two lists above to HEStations.xy file
paste HELong.list HELat.list > HEStations.xy

# load gmt for plotting purpose
module load gmt
# generate a basic figyre
# draw rivers, coastalines and political boundaries
# Sblue fill lake with blue color; -Dh enhance the resolution
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Ia/blue -Na/orange -P -Sblue -K -V -Dh > SoilMoistureStations.ps
# add blac circles for Allstation.xy
gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
# add red  circles for HEStation.xy
gmt psxy HEStations.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps
# view the figure
gv SoilMoistureStations.ps & 

# Convert figure into tiff
# convert postscript file to .espi
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi
# view the .espi figure
gv SoilMoistureStations.epsi &
# use imageMagic convert to convert .epsi to tiff
convert -density 150 -units pixelsperinch SoilMoistureStations.epsi SoilMoistureStations.tif
