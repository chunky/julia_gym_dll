export DLLGymEnv

using ReinforcementLearning
using IntervalSets

mutable struct DLLGymEnv <: AbstractEnv
    libpath::String
    setup_txt::String
    done::Bool
    
    function DLLGymEnv(libpath::String, setup_txt::String, done::Bool)
        e = new(libpath, setup_txt, done)
        ccall(("instantiate", "../pendulum_gym"), Cvoid, (Cstring,), setup_txt)
        ccall(("reset", "../pendulum_gym"), Cvoid, ())
        return e
    end
end

DLLGymEnv(libpath, setup_txt) = DLLGymEnv(libpath, setup_txt, false)
DLLGymEnv(libpath) = DLLGymEnv(libpath, "setup.txt")
DLLGymEnv() = DLLGymEnv("../pendulum_gym")

function RLBase.reset!(env::DLLGymEnv)
    env.done = false
    ccall(("reset", "../pendulum_gym"), Cvoid, ())
end

function RLBase.action_space(env::DLLGymEnv)
    action_len = ccall(("get_action_len", "../pendulum_gym"), Cint, ())
    arr_high = Array{Cdouble}(undef, action_len)
    arr_low = Array{Cdouble}(undef, action_len)
    new_action_len = ccall(("get_action_space", "../pendulum_gym"), Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, action_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:action_len])
end

function RLBase.state_space(env::DLLGymEnv)
    state_len = ccall(("get_observation_len", "../pendulum_gym"), Cint, ())
    arr_high = Array{Cdouble}(undef, state_len)
    arr_low = Array{Cdouble}(undef, state_len)
    new_action_len = ccall(("get_observation_space", "../pendulum_gym"), Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, state_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:state_len])
end

function RLBase.state(env::DLLGymEnv)
    state_len = ccall(("get_observation_len", "../pendulum_gym"), Cint, ())
    s = Array{Cdouble}(undef, state_len)
    ccall(("get_rl_obs", "../pendulum_gym"), Cint, (Ptr{Cdouble}, Cint),
        s, state_len)
    return s
end

function RLBase.reward(env::DLLGymEnv)
    ccall(("reward", "../pendulum_gym"), Cdouble, ())
end

function (env::DLLGymEnv)(a; render=false)
    env.done = ccall(("step", "../pendulum_gym"), Cint, (Ptr{Cdouble}, Cint), a, length(a))
    if render
        ccall(("render", "../pendulum_gym"), Cvoid, ())
    end
end

RLBase.is_terminated(env::DLLGymEnv) = env.done

