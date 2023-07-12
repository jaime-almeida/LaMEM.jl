# Contains a number of useful functions
import LaMEM.IO_functions: Read_LaMEM_simulation, Read_LaMEM_timestep

export  add_phase!, rm_phase!, rm_last_phase!, replace_phase!,
        add_softening!, add_phasetransition!, 
        add_dike!, add_geom! 


"""
    add_phase!(model::Model, phase::Phase)
This adds a `phase` (with material properties) to `model`
"""
function add_phase!(model::Model, phase::Phase) 
    push!(model.Materials.Phases, phase);
    return nothing
end

"""
    add_phase!(model::Model, phases...) 
Add several phases @ once.
"""
function add_phase!(model::Model, phases...) 
    for phase in phases
        push!(model.Materials.Phases, phase);
    end
end


"""
    rm_last_phase!(model::Model, phase::Phase)
This removes the last added `phase` from `model`
"""
function rm_last_phase!(model::Model) 
    if length(model.Materials.Phases)>0
        model.Materials.Phases= model.Materials.Phases[1:end-1]
    end
    return nothing
end

"""
    rm_phase!(model::Model, ID::Int64)
This removes a phase with `ID` from `model`
"""
function rm_phase!(model::Model, ID::Int64) 
    id_vec = [phase.ID for phase in model.Materials.Phases]
    id = findall(id_vec .== ID)
    deleteat!(model.Materials.Phases,id)
    return nothing
end


"""
    replace_phase!(model::Model, phase_new::Phase; ID::Int64=nothing, Name::String=nothing)

This replaces a `phase` within a LaMEM Model Setup `model` with `phase_new` either based on its `Name` or `ID`. 
Note that it is expected that only one such phase is present in the current setup.
"""
function replace_phase!(model::Model, phase_new::Phase; ID::Union{Nothing,Int64}=nothing, Name::Union{Nothing,String}=nothing) 
    id_vec   = [phase.ID for phase in model.Materials.Phases]
    name_vec = [phase.Name for phase in model.Materials.Phases]
    if !isnothing(ID)
        id = findfirst(id_vec .== ID)
    elseif !isnothing(Name)
        id = findfirst(name_vec .== Name)
    end
    model.Materials.Phases[id] = phase_new

    return nothing
end


"""
    add_petsc!(model::Model, option::String) 

Adds one or more PETSc options to the model 

Example
===
```julia
julia> d = Model()
julia> add_petsc!(d,"-snes_npicard 3")
```

"""
function add_petsc!(model::Model, args...) 
    for arg in args
        push!(model.Solver.PETSc_options , arg);
    end
    return nothing
end


function add_softening!(model::Model, args...) 
    for arg in args
        push!(model.Solver.PETSc_options , arg);
    end
    return nothing
end

"""
    add_softening!(model::Model, soft::Softening)
This adds a plastic softening law `soft` to `model`
"""
function add_softening!(model::Model, soft::Softening) 
    push!(model.Materials.SofteningLaws, soft);
    return nothing
end

"""
    add_phasetransition!(model::Model, phase_trans::PhaseTransition)
This adds a phase transition `phase_trans` to `model`
"""
function add_phasetransition!(model::Model, phase_trans::PhaseTransition) 
    push!(model.Materials.PhaseTransitions, phase_trans);
    return nothing
end

"""
    add_dike!(model::Model, dike::Dike)
This adds a phase transition `phase_trans` to `model`
"""
function add_dike!(model::Model, dike::Dike)
    push!(model.Materials.Dikes, dike);
    return nothing
end


"""
    add_geom!(model::Model, geom_object)
This adds an internal geometric primitive object `geom_object` to the LaMEM Model Setup `model`.

Currently available primitive geom objects are:
- `geom_Sphere`
"""
function add_geom!(model::Model, geom_object)
    push!(model.ModelSetup.geom_primitives, geom_object);
    set_geom!(model, geom_object)
    return nothing
end


"""

This sets the geometry 
"""
function set_geom!(model::Model, d::geom_Sphere)
   
    cen = (d.center...,)
    radius = d.radius
    phase  =  ConstantPhase(d.phase)
    T = d.Temperature
    if !isnothing(T)
        T=ConstantTemp(T)
    end

    # call a GMG routine
    AddSphere!(model.Grid.Phases,model.Grid.Temp,model.Grid.Grid, cen=cen, radius=radius, phase=phase, T=T)

    return nothing
end


"""
    Timestep, FileNames, Time = Read_LaMEM_simulation(model::Model; phase=false, surf=false, passive_tracers=false)

Reads a LaMEM simulation as specified in `model` and returns the timesteps, times and filenames of that simulation once it is finished.
"""
Read_LaMEM_simulation(model::Model; kwargs...) = Read_LaMEM_simulation(model.Output.out_file_name,model.Output.out_dir; kwargs...)

"""
    data, time = Read_LaMEM_timestep(model::Model, TimeStep::Int64=0; fields=nothing, phase=false, surf=false, last=true)

Reads a specific `Timestep` from a simulation specified in `model`
"""
function Read_LaMEM_timestep(model::Model, TimeStep::Int64=0; kwargs...) 
    FileName    = model.Output.out_file_name

    cur_dir = pwd(); cd(model.Output.out_dir)

    data, time = Read_LaMEM_timestep(FileName,TimeStep; kwargs...)
    
    cd(cur_dir)

    return data, time
end