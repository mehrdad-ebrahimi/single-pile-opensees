# Define the procedure
proc get_pyParam {pyDepth diameter cu y_prime J e50} {
    # Calculate Np
    if {$pyDepth == 0} {
        set Np 3
    } else {
        set Np [expr {3 + (($y_prime * $pyDepth) / $cu) + ($J * $pyDepth / $diameter)}]
    }

    # Ensure that Np does not exceed 9
    if {$Np > 9} {
        set Np 9
    }

    # Calculate Pult
    set Pult [expr {$cu * $diameter * $Np}]

    # Calculate y50
    set y50 [expr {2.5 * $diameter * $e50}]

    # Return Pult and y50
    return [list $Pult $y50]
}

