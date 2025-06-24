module QKP_Rollout 
    # using JuMP, CPLEX, Distributions, StatsBase
    using JuMP, SCIP, Distributions, StatsBase

    include("base_policy.jl")
    include("generate_data.jl")
    include("QKP-DP.jl")
    include("QKP-RODP.jl")
    include("QKP.jl")
end