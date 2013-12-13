/* suckerFish script for dropdown menus */
sfHover = function() {
	// jtb 2010.02.14
	// If no element named 'toolMenu' exists on the page, then IE throws a javascript error.
	// These checks save IE from itself. 
	if (!document.getElementsByTagName) return false; 
	if (!document.getElementById("toolMenu")) return false; 
	var sfEls = document.getElementById("toolMenu").getElementsByTagName("li");
	for (var i=0; i<sfEls.length; i++) {
		sfEls[i].onmouseover = function() {
			this.className += " sfhover";
		}
		sfEls[i].onmouseout = function() {
			this.className = this.className.replace(new RegExp(" sfhover\\b"), "");
		}
	}
}
if (window.attachEvent) {
	window.attachEvent("onload", sfHover);
}
