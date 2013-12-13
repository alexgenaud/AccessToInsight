#!/bin/tcsh -f
# executes the Digital Pali Reader php script and puts it into a .js file
set me=$0:t             		# the name of this script
set dpr_in = 'digital_pali_reader_suttas.php'
set dpr_out = 'digital_pali_reader_suttas.js'
set tmpDir = ~/tmp
set destDir = ~/Sites/ati.svn/_dpr
set destDir2 = ~/Sites/ati.svn/tech
set theDate = `date "+%Y.%m.%d.%H.%M.%S"`

# generate the static file from the dynamic php code
wget -P $tmpDir http://ati/tech/${dpr_in}

# rename the file to something useful
mv ${tmpDir}/${dpr_in} ${destDir}/${dpr_out}

# insert an informative comment at the top of the file
ed -s ${destDir}/${dpr_out} << EOT
1 i
// This static file was generated from ${dpr_in} on $theDate by $me
.
w
q
EOT

# copy it to the legacy /tech dir (eventually will be deprecated)
cp ${destDir}/${dpr_out} ${destDir2}/${dpr_out}
