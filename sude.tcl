package provide sude 0.1

namespace eval ::sude:: {
	namespace export {getParameters formatParameters getDate getMode}
}

######################
# Private procedures #
######################

proc longestId {pList} {
	set longest 0
	foreach p $pList {
		set plength [string length [lindex $p 0]]
		if {$plength > $longest} {set longest $plength}
	}
	incr longest 3
	return $longest
}

proc pTable {pList} {
	set longest [longestId $pList]
	foreach p $pList {
		set id [lindex $p 0]
		append id " :"
		append formated [format "%-*s %*s %s\n" $longest $id 4 [lindex $p 1]  [lindex $p 2]]
	}
	return $formated
}

#####################
# Public procedures #
#####################

proc ::sude::haseadi {f} {
	set lines [split [read [open $f]] "\n"]
	for {set i 0} {$i < [llength $lines]} {incr i} {
		set line [lindex $lines $i]
		if {[string match "*DATA*" $line]} {
			incr i
			set pLine [lindex $lines $i]
			if {[string match "*Edi*" $pLine]} {return y} {return n}
		}
	}
}

proc ::sude::getParameters {f} {

	set lines [split [read [open $f]] "\n"]
	set ll [llength $lines]
	set p0 {}
	set p1 {}

	set i 1
	set endOfParams 0

	while {$endOfParams == 0 && $i < $ll} {
		set line [lindex $lines $i]
		if {[string match "*=====*" $line]} {
			set endOfParams 1
		} {lappend p0 [split $line "\t"]}
		incr i
	}

	set endOfParams 0

	while {$endOfParams == 0 && $i < $ll} {
		set line [lindex $lines $i]
		if {[string match "*DATA*" $line]} {
			set endOfParams 1
		} elseif {![string match "" $line]} {lappend p1 [split $line "\t"]}
		incr i
	}
	return [list $p0 $p1]
}

proc ::sude::getMode {f} {
	lassign [getParameters $f] p0 p1
	foreach p $p1 {
		lassign $p id value unit
		if {$id == "Mode de ventilation"} {return $value}
	}
}

proc ::sude::getDate {f} {
	lassign [getParameters $f] p0 p1
	foreach p $p1 {
		lassign $p id value unit
		if {$id == "Date de l'enregistrement"} {
			lassign $value dateString timeString
			lassign [split $dateString "/"] j m y
			return  "20$y/$m/$j $timeString"
		}
	}
}

proc ::sude::formatParameters {f} {
	lassign [getParameters $f] p0 p1

	set formated "\n"
	append formated [pTable $p0]
	append formated  "\n======================================================================\n\n"
	append formated [pTable $p1]
	return $formated
}

proc ::sude::display {f c} {
	if {[haseadi $f]} {set numWaveforms 4} {set numWaveforms 3}
	set cmd " set terminal tk 
set nokey
set autoscale xfix

set xdata time
set timefmt '%H:%M:%S'
set datafile separator '\t'

set multiplot layout $numWaveforms,1

set ylabel 'Pression (cmH₂O)'
plot '<sudef $f' using 1:3 with lines

set ylabel 'Débit.c (l/s)'
plot '<sudef $f' using 1:4 with lines
"
		append cmd "
set ylabel 'Volume courant (ml)'
plot '<sudef $f' using 1:5 with lines
"
	if {[haseadi $f]} {
		append cmd "
set ylabel 'Eadi (mcV)'
plot '<sudef $f' using 1:6 with lines
"
	} 

	append cmd "unset multiplot"
	eval [exec gnuplot << $cmd]
	gnuplot $c
}
