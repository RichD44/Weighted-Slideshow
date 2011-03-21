#!/bin/bash
# Weighted Slideshow
#
# Creates a playlist file from image files in the current directory.
#	Edit the first line below to change default types: *.jpg *.png *.gif *.tif
#	The images included in the playlist are randomly selected using an algorithm
#	that strongly favors newer images, i.e., the newer the image, the higher 
#	its chance of being chosen.
#	The playlist file can then be used as input to your favorite utility.
#
#	Usage: weightedss.sh filename count
#		where:
#			filename - name of file to be built containing the weighted play list.
#				The default is "weightedssplaylist".
#			count - number of images to select for the show. The default is all
#				images in the current directory. However, if you have a lot of images
#				and only want the playlist to include a random subset, specifying a
#				count will speed up the selection/weighting/randomization process.
#	Example usage:
#		> cd ~/myfavimages
#		> weightedss.sh fehssplaylist 100
#		> feh -zFD20 --hide-pointer -f fehssplaylist

# Edit the next line if you want different file types
ftypes="*.jpg *.png *.gif *.tif"

fcnt=`ls -1 $ftypes 2>/dev/null | wc -l`
if [[ $fcnt -lt 1 ]]; then	# current directory has no image files
	echo "No image files found"
	exit 1
fi
if [[ $# -gt 2 ]]; then		# user supplied extra params
	echo "Too many parameters"
	exit 1
fi
if [[ $# -gt 0 ]]; then
	fplaylist=$1
else
	fplaylist="weightedssplaylist"
fi
if [[ $# -gt 1 ]]; then
	showcnt=$2
else
	showcnt=$fcnt
fi

echo "Selecting ${showcnt} pics from ${fcnt} images ..."
# Build index array. Each member is the highest random number that applies to that index.
declare -a idxary=()
totlen=0
for ((i=0;i<$fcnt;i+=1)); do
	let "icnt=($fcnt-$i)**2"
	let "totlen+=$icnt"
	idxary[$i]=$totlen
	#echo "idxary ${i} = ${totlen}"	# debugging only
done
#echo "index array size is ${#idxary[*]} / $totlen"	# debugging only

# build playlist array
ls -t1 $ftypes 2>/dev/null > $fplaylist
declare -a playlistary=()
playlistary=( $( cat $fplaylist ) )
rm -f $fplaylist
for ((i=0;i<$showcnt;i+=1)); do
	# range of $RANDOM is only 0-32767 so this is an alternative
	rand10=`head -c4 /dev/urandom| od -An -tu4`
	randno=$[ ($rand10 % $totlen) ]
	aridx=0
	while [[ $randno -gt ${idxary[$aridx]} ]]; do
		let aridx+=1
	done
	fnam=${playlistary[$aridx]}
	#echo "${i} : weighted random index is ${aridx}"	# debugging only
	echo ${fnam} >> $fplaylist
done

exit 0
