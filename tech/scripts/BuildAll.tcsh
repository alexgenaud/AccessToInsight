#!/bin/tcsh -f
# build the complete svn-ready website
set me=$0:t             		# the name of this script


goto Start
##############################
Usage:
cat << END_INPUT
usage: ${me} 
Builds the complete svn-ready website.
END_INPUT
goto ByeBye
##############################


Start:
if ($#argv != 0) then	
	goto Usage
endif

# construct a message string from the arg list
set commitMessage = ""
foreach word ($argv)
	 set commitMessage = "${commitMessage} ${word}"
end



echo "======== ${me}: makeLists.tcsh start ========";
./makeLists.tcsh
echo "======== ${me}: makeLists.tcsh end ========";

echo; echo; echo "======== ${me}: buildRandomSutta.tcsh start ========";
./buildRandomSutta.tcsh
echo "======== ${me}: buildRandomSutta.tcsh end ========";

echo; echo; echo "======== ${me}: buildRandomArticle.tcsh start ========";
./buildRandomArticle.tcsh
echo "======== ${me}: buildRandomArticle.tcsh end ========";

# rebuild the file lists, just in case the previous scripts created some new files...
echo; echo; echo "======== ${me}: makeLists.tcsh (second pass) start ========";
./makeLists.tcsh
echo "======== ${me}: makeLists.tcsh (second pass) end ========";

echo; echo; echo "======== ${me}: BuildLegacy.tcsh start ========";
./BuildLegacy.tcsh ${commitMessage}
echo "======== ${me}: BuildLegacy.tcsh end ========";


ByeBye:
echo ; echo ;
