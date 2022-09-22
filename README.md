# Julia Gym DLL

## What?

I have a Reinforcement Learning Gym that is a complex C++ model. To use
it, I've created a .dll/.so with a C interface that makes calls into
the true C++ Model; The original goal was to be able to use the C++
model from Python, as a RL Gym.

I like Julia. So as a side project, this is a Julia variant that pushes
the interface up so it works with ReinforcementLearning.jl, from here:
https://juliareinforcementlearning.org/

## Usage

### Setup

```shell
# To build the test environments
make
```

```julia
# To recreate the necessary environment+dependencies
import Pkg
Pkg.activate(".")
Pkg.instantiate()
```

### Running

```julia
# To instatiate and run the Gym
using ReinforcementLearning

include("./DLLGymEnv.jl")

# To run it:
env = DLLGymEnv("../pendulum_gym.so")
A = action_space(env)
for i in 1:100
    env(rand(A), render=true)
    is_terminated(env) && break
end
```

## License

This code is made available under the MIT license.

Gary <chunky@icculus.org>
