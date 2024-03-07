# ISSM model runs

A simple example of a suite of ISSM-GlaDS runs for each of the sheet-flow parameterizations in [Hill et al., 2023](https://doi.org/10.1017/jog.2023.103).

The GlaDS setup consists of a 100 km x 25 km synthetic ice-sheet margin with constant basal melt (0.05 m/year) and seasonally-varying inputs to 50 randomly positioned moulins. The model is run for two years to reach an approximate dynamic steady state. Each run should only take a few minutes.

The script `00_synth_forcing/run_suite.sh` runs all five simulations based on the specification in `00_synth_forcing/table.dat`. You might have to change a few lines in the `run_suite.sh` script (e.g., pointing to your matlab executable), and this will only work on a linux system. Otherwise, you can run the lines in `table.dat` manually.

There are a few basic plotting scripts in the `analysis/` folder.

## Sheet-flow parameterizations

The sheet-flow parameterization is the only difference between the five cases. Parameters are set as follows

Case                | `sheet_alpha` | `sheet_beta` | `istransition` | `omega` | `sheet_conductivity`
------------------- | --------------| ------------ | -------------- | ------- | ------------------------
1 (Turbulent 5/4)   |  5/4          | 3/2          | 0              | 0       | 0.0071
2 (Turbulent 3/2)   |  3/2          | 3/2          | 0              | 0       | 0.0134
3 (Laminar)         |  3            | 2            | 0              | 0       | 0.05
1 (Transition 5/4)  |  5/4          | 2            | 1              | 1/2000  | 0.05
1 (Transition 5/4)  |  3/2          | 2            | 1              | 1/2000  | 0.05

Channel parameters do not vary between runs.