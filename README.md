# Single pile with p-y, t-z and q-z springs (OpenSees)

3D OpenSees (Tcl) model of one 15 m concrete pile (D = 1.2 m) in soil, with
p-y (lateral), t-z (skin friction) and q-z (tip) springs. It has a switch for
the case with and without scour.

Units: N, m.

## Files

| File | What it does |
|---|---|
| `run_single_pile.tcl` | Main file: parameters, pile head node, gravity (self-weight), then a lateral load at the pile head |
| `pile.tcl` | Pile nodes, soil springs (p-y, t-z, q-z), pile elements, pile mass and self-weight. `scourCase` 1 = no scour, 2 = scour |
| `get_pyParam.tcl` | p-y parameters for clay |
| `get_pyParamSand.tcl` | p-y parameters for sand (not used at the moment) |
| `get_tzParam.tcl` | t-z parameters (Mosher 1984, Kulhawy 1991) |
| `get_qzParam.tcl` | q-z parameters at the pile tip (Meyerhof 1976, Vijayvergiya 1977) |

## Run

```
OpenSees run_single_pile.tcl
```

Run it from this folder. Results go to `output/` (ignored by git):
`headDisp.txt` (pile head displacement in x) and `pileDispX.txt`
(x displacement of all pile nodes).

## Model

- Pile: 150 linear elastic `elasticBeamColumn` elements (gross section).
- Soil: `zeroLength` springs with `PySimple1`, `TzSimple1` and `QzSimple1`.
- Pile head: node 15001, connected to the pile with a rigid element. Its
  rotation about z is fixed, because a single pile has no other torsion
  restraint.
