#!/bin/tcsh -f

set me=$0:t             		# the name of this script
goto Start
##############################
Usage:
cat << END_INPUT
usage: ${me} DYNAMIC_PATH DYNAMIC_URL STATIC_PATH
Generate a static mirror of a dynamic website.
The following arguments are required:
	DYNAMIC_PATH     absolute filesystem path to the dynamic site (e.g., ~/Sites/svn.ati)	
	DYNAMIC_URL      local server's URL to the synamic site (e.g., http://ati)	
	STATIC_PATH      absolute filesystem path to the static site (e.g., ~/Sites/static.ati)	
END_INPUT
goto ByeBye
##############################
Start:

if ($# != 3) then
	goto Usage
endif


#################### BEWARE!!!! ###################
#
#	wget goes into an infinite loop if it encounters any html links that
# 	contain malformed relative paths, like so:
#
#		<a href="..//bad.html">This is bad!</a>
#		<a href=".././bad.html">This is bad!</a>
#		<a href="../good.html">This is ok.</a>
#
#	Before running wget:
#
#		1. Check HTML syntax
#		2. Search (grep) for any occurrences of "\.\.//" and "/\./"
#		3. Make sure bad paths aren't being generated in your PHP code!
#
#	If you still can't track it down, run wget with the debug flag (-d) to identify the first file that
#	causes the loop. (Send all the ouput to a file, cuz the debug option spews out mucho megabytes of
#	diagnostic stuff.)
#################### BEWARE!!!! ###################


# Path to the dynamic website.
# This is an svn working copy of the site.
	set dynamicSitePath = $1 	# ~/Sites/svn.ati

# URL of the dynamic website
	set dynamicSiteURL = $2 	# http://ati

# path to the static website,
# This is where a (server parsed) mirror of the dynamic site will live
	set staticPath = 	$3		# ~/Sites/ati.static

#Exclude the following dirs from wget 
# (we don't want wget actually spidering through them and executing them)
set excludeDirs=".svn,rss,cgi";	# (comma-separated list)

# these dirs should be copied with 'cp' instead of wget
set cpDirs=""; # (comma-separated list)

set wgetExclude="${excludeDirs}"

echo "####################"
echo "${me}: beginning update of static mirror"
echo "	 src: ${dynamicSitePath} (${dynamicSiteURL})"
echo "	dest: ${staticPath}"


# update the DPR javascript file
${dynamicSitePath}/tech/scripts/dpr_update.tcsh
# NB: the previous line generates a time stamped javascript (.js) file. 
# The wget command, below, also invokes the DPR PHP file, generating the javascript in place. 
# That file (.php) is really not needed in the static site. Someday I'll add some cleanup code
# that will remove that .php file -- along with any links to it from static pages.

# update the working copy
echo -n "svn update... "
cd $dynamicSitePath 
#svn up

# create the dest dir if it doesn't exist
if (-e $staticPath) then
	echo "Good! ${staticPath} already exists."
else
	echo -n "Can't find ${staticPath}."
	mkdir -p $staticPath
	echo " No problem! I just created it." 
endif


# go to the mirror 
cd $staticPath

#wget -N -r -l inf -P prefix --no-remove-listing --no-host-directories -nv ${dynamicSiteURL}

# 20131125: Make sure that wget fetches ALL the files, irrespective of last mod dates (necessary because, e.g.,
# if we change something in functions.php that affects all the html files, wget won't be aware of that
# dependency and will therefore not refetch the affected files)
#wget -m -nv \
set wgetArgs = " -r -l inf --no-remove-listing --no-cache"

wget ${wgetArgs} \
	-P ${staticPath} \
	--no-host-directories \
	--cache=off \
	--exclude-directories=${wgetExclude} \
#	-d \
	${dynamicSiteURL} 
#>& ~/wget_junk.txt

foreach d ($cpDirs)
	cp -R $dynamicSitePath/$d $staticPath/.
end


echo "${me}: finished update of static mirror"
echo "	src: ${dynamicSitePath} (${dynamicSiteURL})"
echo "	dest: ${staticPath}"
echo "####################"



##############################
ByeBye:
exit

