# ----------------------------------------------------------
#  single pile: gravity (self-weight) + lateral load at pile head
#  units: N, m
#  run:  OpenSees run_single_pile.tcl
# ----------------------------------------------------------
wipe
model BasicBuilder -ndm 3 -ndf 6

# params
set diameter 1.2      ;# Diameter of pile in meters
set Lpile 15          ;# pile length (m)
set SegmentPile 150.  ;# number of pile segments
set pi 3.141592653589793
set fc0 33.8e6
set nuc 0.2

# geometric transformation
set linearZTransfTag 3
geomTransf Linear $linearZTransfTag -1 0 0

set pDeltaZTransfTag 4
geomTransf PDelta $pDeltaZTransfTag -1 0 0

# pile head node (ground level)
node 15001 0. 0. 0.
fix 15001 0 0 0 0 0 1   ;# no torsion restraint on a single pile otherwise (singular matrix)

source pile.tcl

# ----------------------------------------------------------
#  gravity analysis (pile self-weight, pattern 2 in pile.tcl)
# ----------------------------------------------------------
constraints Transformation
numberer RCM
system BandGeneral
test NormDispIncr 1e-6 100
algorithm Newton
integrator LoadControl 0.1
analysis Static
set ok [analyze 10]
puts "gravity ok=$ok   head settlement = [format %.4f [expr 1000.*[nodeDisp 15001 3]]] mm"
loadConst -time 0.

# ----------------------------------------------------------
#  lateral load at pile head (x)
# ----------------------------------------------------------
set Hload 100000.   ;# N
set dataDir output
file mkdir $dataDir
recorder Node -file $dataDir/headDisp.txt -time -node 15001 -dof 1 disp
recorder Node -file $dataDir/pileDispX.txt -nodeRange 180001 [expr {int(180000 + $SegmentPile)}] -dof 1 disp

pattern Plain 3 Linear {
    load 15001 $Hload 0. 0. 0. 0. 0.
}
integrator LoadControl 0.01
set ok [analyze 100]
puts "lateral ok=$ok   head ux = [format %.4f [expr 1000.*[nodeDisp 15001 1]]] mm  (H = [expr $Hload/1000.] kN)"
