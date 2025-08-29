using ArgParse

include("../src/QKP_Rollout.jl")
using .QKP_Rollout

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin 
        "--from_file"
            arg_type = Bool
            default = false
        "--data_file"
            arg_type = String
            default  = "../data/instances/n-10-test-case.txt" ## "../data/instances/n-10-test-case.txt"
        "--base_policy"
            arg_type = String
            default = "lagrangian" ## mccormick, lagrangian 
        "--n"
            arg_type = Int64
            default = 200 ## number of pairs for consideration
        "--prob"
            arg_type = Float64
            default = 0.08 ## defines the "density": Δ 
        "--step_size"
            arg_type = Float64
            default = 1.0
        "--cplex"
            arg_type = Bool
            default = true ## true for cplex is available, false for cplex is not available
    end
    return parse_args(s)
end
args = parse_commandline() 

## TODO: perform checks on, e.g., options available for base_policy are not violated, etc. If data_file == true, direct to appropriate file
if args["base_policy"] != "lagrangian" && args["base_policy"] != "mccormick"
    throw(ArgumentError("Base policy must be 'lagrangian' or 'mccormick.'"))
end

if args["from_file"] == true
    n,p,w,W = QKP_Rollout.get_data(args["data_file"])
else
    n = args["n"]
    prob = args["prob"]
    p, w, W = QKP_Rollout.get_data(n,prob)
end

λ = args["step_size"]


# S, profit = QKP_rollout(p,w,W,n,1.0)
profit = QKP_Rollout.QKP_rollout(p,w,W,n, λ, args)

println("final profit is: ", profit)
# println(w)
# println(W)

### check approximate "gap"
# println(abs(profit - output_for_non_relaxed)/output_for_non_relaxed)

# println(" $(abs(profit - objective_mccormick)/objective_mccormick) is the 'gap' value compared with McCormick reformulation.")

## TODO: add comparison metrics, if desired ... this wil entail likely adding another flag to indicate whether or not a comparison is to be made...