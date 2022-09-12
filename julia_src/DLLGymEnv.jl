export DLLGymEnv

using ReinforcementLearning
using IntervalSets

mutable struct DLLGymEnv <: AbstractEnv
    libpath::String
    setup_txt::String
    done::Bool
    
    function DLLGymEnv(libpath::String, setup_txt::String, done::Bool)
        new(libpath, setup_txt, done)
        ccall(("instantiate", "../empty_gym"), Cvoid, (Ptr{Cstring},), setup_txt)
        ccall(("reset", "../empty_gym"), Cvoid, ())
    end
end

DLLGymEnv(libpath, setup_txt) = DLLGymEnv(libpath, setup_txt, false)
DLLGymEnv(libpath) = DLLGymEnv(libpath, "setup.txt")
DLLGymEnv() = DLLGymEnv("../empty_gym")

function RLBase.reset!(env::DLLGymEnv)
    env.done = false
    ccall(("reset", "../empty_gym"), Cvoid, ())
end

function RLBase.action_space(env::DLLGymEnv)
    action_len = ccall(("get_action_len", "../empty_gym"), Cint, ())
    arr_high = Array{Cdouble}(undef, action_len)
    arr_low = Array{Cdouble}(undef, action_len)
    new_action_len = ccall(("get_action_space", "../empty_gym"), Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, action_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:action_len])
end

function RLBase.state_space(env::DLLGymEnv)
    state_len = ccall(("get_observation_len", "../empty_gym"), Cint, ())
    arr_high = Array{Cdouble}(undef, state_len)
    arr_low = Array{Cdouble}(undef, state_len)
    new_action_len = ccall(("get_observation_space", "../empty_gym"), Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, state_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:state_len])
end

function RLBase.state(env::DLLGymEnv)
    state_len = ccall(("get_observation_len", "../empty_gym"), Cint, ())
    s = Array{Cdouble}(undef, state_len)
    ccall(("get_rl_obs", "../empty_gym"), Cint, (Ptr{Cdouble}, Cint),
        s, state_len)
    return s
end

function RLBase.reward(env::DLLGymEnv)
    ccall(("reward", "../empty_gym"), Cdouble, ())
end

function (env::DLLGymEnv)(a)
    env.done = ccall(("step", "../empty_gym"), Cint, (Ptr{Cdouble}, Cint), a, length(a))
end

RLBase.is_terminated(env::DLLGymEnv) = env.done