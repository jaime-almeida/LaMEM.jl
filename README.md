# LaMEM.jl
[![Build Status](https://github.com/JuliaGeodynamics/LaMEM.jl/workflows/CI/badge.svg)](https://github.com/JuliaGeodynamics/LaMEM.jl/actions)

This is the Julia interface to [LaMEM](https://bitbucket.org/bkaus/lamem) (Lithosphere and Mantle Evolution Model), which allows you to start a (parallel) LaMEM simulation from julia, and read back the output files to julia for further processing.

See [GeophysicalModelGenerator](https://github.com/JuliaGeodynamics/GeophysicalModelGenerator.jl) for tools to create input models for LaMEM, from data.

### 1. Installation
Go to the package manager & install it with:
```julia
julia>]
pkg>add LaMEM
```
It will automatically download a binary version of LaMEM which runs in parallel (along with the correct PETSc version). This will work on linux, mac and windows.

### 2. Starting a simulation
As usual, you need a LaMEM (`*.dat`) input file, which you can run in parallel (here on 4 cores) with:
```julia
julia> ParamFile="input_files/FallingBlock_Multigrid.dat";
julia> run_lamem(ParamFile, 4,"-time_end 1")
```
The last parameter are optional PETSc command-line options. By default it runs on one processor.

Please note that you will have to be in the correct directory (the same one as where the LaMEM parameter file is located). If you are in a different directory, the easiest way to change to the correct one is by using the build-in terminal/shell in julia.
You access this with:
```julia
julia>;
shell>cd ~/LaMEM/input_models/BuildInSetups/
```
use the Backspace key to return to the julia REPL.


### 3. Reading output files back into julia
There is an easy way to read the output of a LaMEM timestep back into julia. Make sure you are in the directory where the simulation was run and read a timestep back with:
```julia
julia> FileName="FB_multigrid.pvtr"
julia> DirName = "Timestep_00000001_6.72970343e+00"
julia> data    = Read_VTR_File(DirName, FileName)
CartData 
    size    : (33, 33, 33)
    x       ϵ [ 0.0 : 1.0]
    y       ϵ [ 0.0 : 1.0]
    z       ϵ [ 0.0 : 1.0]
    fields  : (:phase, :visc_total, :visc_creep, :velocity, :pressure, :strain_rate, :j2_dev_stress, :j2_strain_rate)
  attributes: ["note"]
```
The output is in a `CartData` structure (as defined in GeophysicalModelGenerator).

### 4. Dependencies
We rely on the following packages:
- PythonCall - installs a local python version and the VTK toolbox, used to read the outout files
- GeophysicalModelGenerator - Data structure in which we store the info of a LaMEM timestep 
