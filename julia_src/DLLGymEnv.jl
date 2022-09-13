export DLLGymEnv

using Base.Libc.Libdl
using ReinforcementLearning
using IntervalSets

struct DLLGymFuncs
    instantiate
    reset
    get_action_len
    get_action_space
    get_observation_len
    get_observation_space
    reward
    render
    step
    
    function DLLGymFuncs(libpath::String)
        hndl = dlopen(libpath)
        
        dll_instantiate = dlsym(hndl, "instantiate")
        dll_reset = dlsym(hndl, "reset")
        dll_get_action_len = dlsym(hndl, "get_action_len")
        dll_get_action_space = dlsym(hndl, "get_action_space")

        dll_get_observation_len = dlsym(hndl, "get_observation_len")
        dll_get_observation_space = dlsym(hndl, "get_observation_space")

        dll_reward = dlsym(hndl, "reward")
        dll_render = dlsym(hndl, "render")
        dll_step = dlsym(hndl, "step")
        
        new(dll_instantiate, dll_reset, dll_get_action_len, dll_get_action_space,
            dll_get_observation_len, dll_get_observation_space, dll_reward, dll_render, dll_step)
    end
end

mutable struct DLLGymEnv <: AbstractEnv
    libpath::String
    setup_txt::String
    done::Bool
    gymfuncs::DLLGymFuncs
    
    function DLLGymEnv(libpath::String, setup_txt::String, done::Bool)
        e = new(libpath, setup_txt, done, DLLGymFuncs(libpath))
        ccall(e.gymfuncs.instantiate, Cvoid, (Cstring,), setup_txt)
        ccall(e.gymfuncs.reset, Cvoid, ())
        return e
    end
end

DLLGymEnv(libpath, setup_txt) = DLLGymEnv(libpath, setup_txt, false)
DLLGymEnv(libpath) = DLLGymEnv(libpath, "setup.txt")
DLLGymEnv() = DLLGymEnv("../pendulum_gym")

function RLBase.reset!(env::DLLGymEnv)
    env.done = false
    ccall(env.gymfuncs.reset, Cvoid, ())
end

function RLBase.action_space(env::DLLGymEnv)
    action_len = ccall(env.gymfuncs.get_action_len, Cint, ())
    arr_high = Array{Cdouble}(undef, action_len)
    arr_low = Array{Cdouble}(undef, action_len)
    new_action_len = ccall(env.gymfuncs.get_action_space, Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, action_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:action_len])
end

function RLBase.state_space(env::DLLGymEnv)
    state_len = ccall(env.gymfuncs.get_observation_len, Cint, ())
    arr_high = Array{Cdouble}(undef, state_len)
    arr_low = Array{Cdouble}(undef, state_len)
    new_action_len = ccall(env.gymfuncs.get_observation_space, Cint, (Ptr{Cdouble}, Ptr{Cdouble}, Cint),
        arr_low, arr_high, state_len)
    Space([(arr_low[i] .. arr_high[i]) for i in 1:state_len])
end

function RLBase.state(env::DLLGymEnv)
    state_len = ccall(env.gymfuncs.get_observation_len, Cint, ())
    s = Array{Cdouble}(undef, state_len)
    ccall(env.gymfuncs.get_rl_obs, Cint, (Ptr{Cdouble}, Cint),
        s, state_len)
    return s
end

function RLBase.reward(env::DLLGymEnv)
    ccall(env.gymfuncs.reward, Cdouble, ())
end

function (env::DLLGymEnv)(a; render=false)
    env.done = ccall(env.gymfuncs.step, Cint, (Ptr{Cdouble}, Cint), a, length(a))
    if render
        ccall(env.gymfuncs.render, Cvoid, ())
    end
end

RLBase.is_terminated(env::DLLGymEnv) = env.done

