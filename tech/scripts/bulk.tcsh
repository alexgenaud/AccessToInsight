#!/bin/tcsh -f
# Prepare the whole-site archive


set cmd='echo'

set theBulkVersion = `date "+%Y.%m.%d.%H"`
set theBulkPrefix = "ati-"
set theBulkName = ${theBulkPrefix}${theBulkVersion}.zip	# a file name containing the version no.
set theBulkDate = `date "+%A %e %b %Y"`
set theTmpDir = "~/tmp"

# path to the script that creates the static version of the site
set staticify = 'static.tcsh'

set dynamicPath = "~/Sites/ati.svn"
set destDir = "~/Sites/ati.svn/tech/download/bulk"
set bulkFile = "${destDir}/bulk.html"
set staticDir = "~/Sites/ati.static" 
set staticPath = "${staticDir}/ati_website/html"
set staticStartFile = "${staticDir}/ati_website/start.html"
set staticKludgeFile = "${dynamicPath}/tech/download/_wget_mode_static.tmp" # see comments in config.inc.php
set serverURL = "http://ati"


#################### KLUDGE ALARM!!!! ###################
# The config.inc.php file defines the name of a file whose presence tells wget
# (and the PHP server) that we're gonna be generating static pages. 
# The content of the file is the version number of this bulk edition.
# !!! The filename defined here must match that defined in config.inc.php !!!
set OFFLINE_VERSION_FILE = "{$dynamicPath}/tech/download/_OFFLINE_VERSION.txt"
echo $theBulkVersion > $OFFLINE_VERSION_FILE
echo $theBulkName >> $OFFLINE_VERSION_FILE
echo $theBulkDate >> $OFFLINE_VERSION_FILE
#################### KLUDGE ALARM!!!! ###################


set me=$0:t             		# the name of this program
goto Start
##############################
Usage:
cat << END_INPUT
usage: ${me}
Creates an archive of the entire site.
END_INPUT
goto ByeBye
##############################


Start:
if ($# != 0) then
	goto Usage
endif

echo "Preparing static archive of the website: ${theBulkName}"

echo "Updating static mirror..."
touch $staticKludgeFile  # for communicating to the PHP server that we're generating static pages
$staticify $dynamicPath $serverURL $staticPath
/bin/rm $staticKludgeFile # cleanup the static kludge
echo "Static mirror is up to date."
echo 

echo -n "creating start file..."
cat << END_INPUT > $staticStartFile
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head><meta http-equiv="Refresh" content="0; URL=html/index.html"></head>
<body bgcolor="#FFFFFF"></body>
</html>
END_INPUT

echo "done"

echo -n "creating zip archive..."
cd $staticDir
find . -name .DS_Store -exec /bin/rm {} \;
# jtb 20130924  PDFs are now included in the offline edition
# zip -r -q $theBulkName ati_website -x ati_website/html/cgi\* \*.pdf ati_website/html/rss\* \*.zip
zip -r -q $theBulkName ati_website -x ati_website/html/cgi\* ati_website/html/rss\* \*.zip
mv $theBulkName $destDir
echo "done."

echo -n "creating html redirect to new archive..."
cat << END_INPUT > $bulkFile
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head><meta http-equiv="Refresh" content="0; URL=${theBulkName}"></head>
<body bgcolor="#FFFFFF"></body>
</html>
END_INPUT
echo "done."


goto ByeBye;



##############################
ByeBye:
echo "${me}: done."
exit
