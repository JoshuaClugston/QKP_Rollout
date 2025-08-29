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
        "--starting_point"
            arg_type = Float64
            default = 1.0
        "cplex" 
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


### testing feasibility 
# y = []
# for num in 1:50
#     if !(num in )
#         push!(y, 0)
#     else 
#         push!(y,1)
#     end
# end

# println("Is $(sum(w[k]*y[k] for k in 1:n)) <= $(W)? If not, then infeasible.")


r, profit, elapsed_time = QKP_Rollout.QKP_DP(p, w, W, n, λ, s, x0, args) 
objective = QKP_Rollout.solve_QKP(p,w,W,n, args)

println("Objective value from solving QKP directly is: $(objective). Solving using QKP_DP returns $(profit) after $(elapsed_time) seconds.")