#!/usr/bin/tclsh
source sude.tcl

foreach f [glob -directory Data "*.txt"] {
	puts [format "%s: %s" $f [::sude::haseadi $f]]
	#puts [exec head -n 31 $f]
}
