# Julia Gym DLL

## What?

I have a Reinforcement Learning Gym that is a complex C++ model. To use
it, I've created a .dll/.so with a C interface that makes calls into
the true C++ Model; The original goal was to be able to use the C++
model from Python, as a RL Gym.

I like Julia. So as a side project, this is a Julia variant that pushes
the interface up so it works with ReinforcementLearning.jl, from here:
https://juliareinforcementlearning.org/

Gary <chunky@icculus.org>
