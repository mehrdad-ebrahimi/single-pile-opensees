# ----------------------------------------------------------------------------------------------------------------------------------------------------------------
#                                                                      SINGLE PILE
#  needs (from run_single_pile.tcl): diameter Lpile SegmentPile pi fc0 nuc
#                                    linearZTransfTag pDeltaZTransfTag
#  pile head node 15001 is created in run_single_pile.tcl
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------

# material
set Ec [expr 4700. * sqrt($fc0 * 1.e-6) * 1.e6] ;# Elastic modulus of concrete in Pascals.
set Gc [expr $Ec / (1 + $nuc) / 2.] ;# Shear modulus of concrete in Pascals.
set DCol 0.914;# Column diameter in meters.
set ACol [expr 3.1415 * $DCol**2 / 4.] ;# Column cross-sectional area in square meters.
set ICol [expr 3.1415 * $DCol**4 / 64.] ;# Moment of inertia (z and y axes) of the column in meters^4.
set JCol [expr 3.1415 * $DCol**4 / 32.] ;# Polar moment of inertia of the column in meters^4.
set amplifyEle 100. ;# Element amplification factor.
set amplifyMat 100. ;# Material amplification factor.

# ----------------------------------------------------------
# Pile geometry and material properties
# ----------------------------------------------------------

set fc 33.8e6 ;# Concrete compressive strength in Pascals
set E [expr 4700 * sqrt($fc / 1.0e6) * 1.0e6] ;# Modulus of elasticity in Pascals
set nu 0.2 ;# Poisson's ratio for concrete
set G [expr $E / (2 * (1 + $nu))] ;# Shear modulus in Pascals
# length of pile head (above ground surface) (m)
set L1 0.0
set L2 $Lpile
set nElePile $SegmentPile
set eleSize [expr ($L1+$L2)/$nElePile]
set nNodePile [expr 1 + $nElePile]
set nNodeEmbed [expr {int($L2 / $eleSize) + 1}]
# ----------------------------------------------------------
#  soil properties
# ----------------------------------------------------------
set Areapile     [ expr $diameter/2 * $diameter/2  * $pi ]
set Nq 300
set firctionAngel1 28
set firctionAngel2 33
set firctionAngel3 38
set gamma1  21.0
set gamma2  19.0
set gamma3  17.0
set gwater 9.81
# soil unit weight (kN/m^3)
set gamma  17.0

# soil internal friction angle (degrees)
set phi    36.0
# soil shear modulus at pile tip (kPa)
set Gsoil  150000


# ------------------------------------------------------------------------------
#pile node
# ------------------------------------------------------------------------------

set XCap 0.
set YOffsets 0.
set baseZCoord [expr {-1.0 * ($Lpile) / $SegmentPile}]

    set nodeCount1 180001
    set nodeCount2 230001
    set nodeCount3 240001

    foreach xCoord $XCap {
        set i 1
        set ZIncrement $baseZCoord
        set count 0
        while {$count < $SegmentPile} {
            foreach yCoord $YOffsets {
                # Calculate Z coordinate
                set zCoord [expr {$ZIncrement * $i}]

                # Create three nodes at each coordinate with different node names
                node $nodeCount1 $xCoord $yCoord $zCoord
                node $nodeCount2 $xCoord $yCoord $zCoord
                node $nodeCount3 $xCoord $yCoord $zCoord

                incr nodeCount1
                incr nodeCount2
                incr nodeCount3
            }
            incr i
            incr count
        }
    }


# -------------------------------------------------------
# fixing node
# ------------------------------------------------------

proc applyFix {startNodeCount SegmentPile constraints} {
    for {set i $startNodeCount} {$i <= [expr {$startNodeCount - 1 + $SegmentPile}]} {incr i} {
        eval fix $i $constraints
    }
}

# spring nodes: rotations fixed; anchor nodes: fully fixed
set constraintsSeries2 "0 0 0 1 1 1"
set constraintsSeries3 "1 1 1 1 1 1"

applyFix 230001 $SegmentPile $constraintsSeries2
applyFix 240001 $SegmentPile $constraintsSeries3

# ------------------------------------------------------------------------------
# define rigid elemnt footage  to pile *vertical*
# ------------------------------------------------------------------------------

set eleTag 30001
set nodeTag 15001
set endNodeTag 180001
    element elasticBeamColumn $eleTag $nodeTag $endNodeTag $ACol [expr $amplifyEle * $Ec] [expr $amplifyEle * $Gc] $JCol $ICol $ICol $linearZTransfTag


# ----------------------------------------------------------
#  create spring material objects
# ----------------------------------------------------------

source get_tzParam.tcl
source get_qzParam.tcl

# Define the constant variables
set cu 11000.0
set y_prime [expr $gamma - 9.81]
set J 0.5
set e50 0.02

# p-y spring material
source get_pyParam.tcl
for {set i 1 } {$i < $nNodeEmbed} {incr i} {
    set pyDepth [expr $eleSize * ($i - 1)]
    set pyParam [get_pyParam $pyDepth $diameter $cu $y_prime $J $e50]
    set pult [lindex $pyParam 0]
    set y50 [lindex $pyParam 1]
    uniaxialMaterial PySimple1 [expr $i + 1000] 1 $pult $y50 0.0
}

    uniaxialMaterial PySimple1 60000  2 12.223  0.0000000000006  0.0
# t-z spring material
for {set i 1} {$i < $nNodeEmbed} {incr i} {
  # depth of current tz node
	set pyDepth [expr $eleSize*($i - 1)]
  # vertical effective stress at current depth
    set sigV    [expr $gamma*$pyDepth]
  # procedure to define tult and z50
    set tzParam  [get_tzParam $phi $diameter $sigV $eleSize]
    set tult [expr  1000.*[lindex $tzParam 0]]
    set z50  [lindex $tzParam 1]
	uniaxialMaterial TzSimple1 [expr $i+2000]  2  $tult  $z50  0.0
}
	uniaxialMaterial TzSimple1 60001  2  0.00000005526736565137967  1.9121866154527636e-8  0.0
# q-z spring material
  # vertical effective stress at pile tip, no water table (depth is embedded pile length)
    set sigVq   [expr $gamma*$L2]
  # procedure to define qult and z50
    set qzParam [get_qzParam $phi $diameter $sigVq $Gsoil]
    set qult [ expr 1000. *[lindex $qzParam 0]]
    set z50q [lindex $qzParam 1]

    uniaxialMaterial QzSimple1 3001  2  $qult  $z50q  0.0  0.0


# ----------------------------------------------------------
# Spring nodes and zero-length elements
# ----------------------------------------------------------

# element at the pile tip (has q-z spring)
element zeroLength 61100  [expr int(230000 + $SegmentPile)]  [expr int(240000 + $SegmentPile)]  -mat [expr {round($SegmentPile + 1000)}] [expr {round($SegmentPile + 1000)}] 3001  -dir 1 2 3


# #-------------------------------------------------------------------
# #                  switch code for scour
# #-------------------------------------------------------------------
# 1 for withour scour
# 2 for scour

set scourCase 1

switch -- $scourCase {

# #-------------------------------------------------------------------
# #                   without scour
# #-------------------------------------------------------------------

1 {
for {set i 1; set j 1} {$i < $SegmentPile && $j < $SegmentPile} {incr i; incr j} {
    set slaveNodeID [expr {$i + 230000}]
    set fixedNodeID [expr {$i + 240000}]
    set elementID   [expr {$i + 510000}]

    set matTag1     [expr {$j + 1000}]
    set matTag2     [expr {$j + 1000}]
    set matTag3     [expr {$j + 2000}]

    element zeroLength $elementID $slaveNodeID $fixedNodeID -mat $matTag1 $matTag2 $matTag3 -dir 1 2 3
}
}
# -------------------------------------------------------------------
#                        scour
# -------------------------------------------------------------------
2 {
set scourleft 5
# 0 resilience inside the scour hole
for {set i 1} {$i <= $scourleft } {incr i} {
    set slaveNodeID [expr {230000 + $i}]
    set fixedNodeID [expr {240000 + $i}]
    element zeroLength [expr {510000 + $i}] $slaveNodeID $fixedNodeID -mat 60000 60000 60001 -dir 1 2 3
}

# soil springs below the scour hole
for {set i [expr 1 + $scourleft]; set j 1} {$i < $SegmentPile && $j < [expr {$SegmentPile - $scourleft + 1}]} {incr i; incr j} {
    set slaveNodeID [expr {230000 + $i}]
    set fixedNodeID [expr {240000 + $i}]
    set elementID   [expr {510000 + $i}]
    set matTag1     [expr {$j + 1000}]
    set matTag2     [expr {$j + 1000}]
    set matTag3     [expr {$j + 2000}]

    element zeroLength $elementID $slaveNodeID $fixedNodeID -mat $matTag1 $matTag2 $matTag3 -dir 1 2 3
}
}
}

# ----------------------------------------------------------
#  pile section (elastic)
# ----------------------------------------------------------
set Apile [expr 3.1415 * $diameter**2 / 4.] ;# Area of the pile in meters^2.
set Ipile [expr 3.1415 * $diameter**4 / 64.] ;# Moment of inertia of the pile in meters^4.
set Jpile [expr 3.1415 * $diameter**4 / 32.] ;# Polar moment of inertia of the pile in meters^4.


# ----------------------------------------------------------
#  define equal dof between pile and spring nodes
# ----------------------------------------------------------

for {set i 0} {$i < [expr {int($SegmentPile)}]} {incr i} {
    set pileNodeID [expr {180001 + $i}]
    set slaveNodeID [expr {230001 + $i}]
    equalDOF $pileNodeID $slaveNodeID 1 2 3
}

# ----------------------------------------------------------
#  create pile elements
# ----------------------------------------------------------
for {set i 0} {$i < [expr {int($SegmentPile) - 1}] } {incr i} {
    set elementId [expr {320001 + $i}]
    set pileNodeStart [expr {180001 + $i}]
    set pileNodeEnd [expr {$pileNodeStart + 1}]
    element elasticBeamColumn $elementId $pileNodeStart $pileNodeEnd $Apile $E $G $Jpile $Ipile $Ipile $pDeltaZTransfTag
}

# --------------------------------------------
#               mass Pile
# --------------------------------------------
set gammaConc 25000; # N/m3
set g 9.81
set rhoConc [expr $gammaConc/$g];  # Kg/m3
set massP [expr   $Lpile/$SegmentPile*$rhoConc *$diameter/2. * $diameter / 2.* $pi]
for {set i 180001} {$i <= [expr {int($SegmentPile) + 180000}]} {incr i} {
    mass $i $massP $massP $massP 0. 0. 0.
}

set Wpile [expr {$diameter/2.0 * $diameter/2.0 * $pi * $gammaConc * 1.0}]

pattern Plain 2 Linear {
    for {set i 0} {$i < [expr {int($SegmentPile) - 1}] } {incr i} {
        eleLoad -ele [expr {320001 + $i}] -type -beamUniform 0. 0. $Wpile
    }
}
