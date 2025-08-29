function base_policy_lagrangian(p,w, n, (S, W), λ, args) # lagrangian function of quadratic relaxation
    # function solve_QKP_Lagrangian(p,w, n, (k, W, include), λ) # lagrangian function of quadratic relaxation
    x = Dict();
    if args["cplex"] == true
        model = Model(CPLEX.Optimizer)
    else
        model = Model(HiGHS.Optimizer)
    end
    set_silent(model)

    # @variable(model, x[1:k], Bin)
    for i in S
        x[i] = @variable(model, base_name = "x[$(i)]", binary=true)
    end

    # if include == true 
    #     @constraint(model, x[k] == 1)
    # elseif include == false
    #     @constraint(model, x[k] == 0)
    # end

    # @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in 1:k, j in 1:k) + λ * (W-sum(w[i]*x[i] for i  in 1:k)) )
    @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in S, j in S) + λ * (W-sum(w[i]*x[i] for i  in S)) )

    optimize!(model)

    # println("Solution to quadratic relax Lagrangian ", objective_value(model))
    
    objective_out = objective_value(model)

    x_out = Dict()

    for i in S
        x_out[i] = value(x[i])
    end

    return objective_out, x_out
end

function base_policy_mccormick_relaxed(p,w,n,(S,W), args) ## TODO: finish ....

    x = Dict();
    if args["cplex"] == true
        model = Model(CPLEX.Optimizer)
    else
        model = Model(HiGHS.Optimizer)
    end
    set_silent(model)

    # @variable(model, x[1:k], Bin)
    for i in S
        u[i,i] = @variable(model, base_name = "u[$(i),$(i)]", lower_bound = 0.0) ### base_name provided for dictionary variable.. not sure if that will be needed here ... 
        x[i] = @variable(model, base_name = "x[$(i)]", lower_bound = 0.0, upper_bound = 1.0) ## relaxed 
    end

    @constraint(model, [i=1:n,j=1:n], u[i,j] >= x[j] + x[i] - 1)
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[i])
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[j])
    @constraint(model, sum(w[i]*x[i] for i in 1:n) <= W) 

    # @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in 1:k, j in 1:k) + λ * (W-sum(w[i]*x[i] for i  in 1:k)) )
    @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in S, j in S))

    optimize!(model)

    # println("Solution to quadratic relax Lagrangian ", objective_value(model))
    
    objective_out = objective_value(model)

    x_out = Dict()

    for i in S
        x_out[i] = value(x[i])
    end

    return objective_out, x_out
end