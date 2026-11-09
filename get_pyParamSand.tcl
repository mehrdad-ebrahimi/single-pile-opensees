    proc get_pyParamSand {H D gamma frictionAngle} {


    # Directly determine C3 based on the provided frictionAngle
    if {$frictionAngle == 20} {
        set C3 9
    } elseif {$frictionAngle == 21} {
        set C3 10.2
    } elseif {$frictionAngle == 22} {
        set C3 11.4
    } elseif {$frictionAngle == 23} {
        set C3 12.6
    } elseif {$frictionAngle == 24} {
        set C3 13.8
    } elseif {$frictionAngle == 25} {
        set C3 15
    } elseif {$frictionAngle == 26} {
        set C3 17.8
    } elseif {$frictionAngle == 27} {
        set C3 20.6
    } elseif {$frictionAngle == 28} {
        set C3 23.4
    } elseif {$frictionAngle == 29} {
        set C3 26.2
    } elseif {$frictionAngle == 30} {
        set C3 29
    } elseif {$frictionAngle == 31} {
        set C3 34.2
    } elseif {$frictionAngle == 32} {
        set C3 39.4
    } elseif {$frictionAngle == 33} {
        set C3 44.6
    } elseif {$frictionAngle == 34} {
        set C3 49.8
    } elseif {$frictionAngle == 35} {
        set C3 55
    } elseif {$frictionAngle == 36} {
        set C3 64
    } elseif {$frictionAngle == 37} {
        set C3 73
    } elseif {$frictionAngle == 38} {
        set C3 82
    } elseif {$frictionAngle == 39} {
        set C3 91
    } elseif {$frictionAngle == 40} {
        set C3 100
    } else {
        puts "No coefficient available for the given friction angle: $frictionAngle"
        return -1
    }

    # Calculate the ultimate resistance (Pult) with the determined C3
	if {$H == 0} {
    set Pult 50.9680
} else {
    set Pult  [expr {$C3 * $D * $gamma * $H*1000 }]
}
    set Pu   [expr {$C3 * $D * $gamma }]


#----------------------------------------------------------
#  define displacement at 50% lateral capacity, y50
#----------------------------------------------------------


    # Manually check and set khat value based on the frictionAngle
    if {$frictionAngle == 28.0} {
        set khat 10
    } elseif {$frictionAngle == 29.0} {
        set khat 20
    } elseif {$frictionAngle == 30.0} {
        set khat 33
    } elseif {$frictionAngle == 31.0} {
        set khat 42
    } elseif {$frictionAngle == 32.0} {
        set khat 50
    } elseif {$frictionAngle == 33.0} {
        set khat 60
    } elseif {$frictionAngle == 34.0} {
        set khat 70
    } elseif {$frictionAngle == 35.0} {
        set khat 85
    } elseif {$frictionAngle == 36.0} {
        set khat 95
    } elseif {$frictionAngle == 37.0} {
        set khat 107
    } elseif {$frictionAngle == 38.0} {
        set khat 122
    } elseif {$frictionAngle == 39.0} {
        set khat 141
    } elseif {$frictionAngle == 40.0} {
        set khat 155
    } else {
        puts "No khat value available for the given friction angle: $frictionAngle"
        return -1
    }




    # Change units from (lb/in^3) to (kN/m^3)
    set k [expr {$khat * 271.45}]

    # Calculate As (assuming it's shaft area as H/D)
    set As [expr {$H / $D}]
    # Calculate atanh(0.5)
    set atanh05 [expr {0.5 * log((1 + 0.5) / (1 - 0.5))}]
    # Calculate y50
# Check if H is 0, and set y50 accordingly

    set y50 [expr {($As * $Pu / ($k * $H)) * $atanh05* 10}]



# return pult and y50 parameters
set outResult [concat $Pult $y50 ]

return $outResult


}
