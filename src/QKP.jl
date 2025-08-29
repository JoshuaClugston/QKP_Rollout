function solve_QKP(p,w,W,n, args)
    # model = Model(CPLEX.Optimizer)
    if args["cplex"] == true
        model = Model(CPLEX.Optimizer)
    else
        model = Model(HiGHS.Optimizer)
    end


    @variable(model, x[1:n], Bin)

    @constraint(model, sum(w[i]*x[i] for i in 1:n) <= W)

    @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in 1:n, j in 1:n))

    # println(model)

    optimize!(model)

    println("Solution to non-relaxed, standard QKP: ", objective_value(model))
    println("Solution for non-relaxed, standard QKP: ", value.(x))
    return objective_value(model)
end

function solve_McCormick_QKP_non_relaxed(p,w,W,n,args) # to get an initial point 
    if args["cplex"] == true
        model = Model(CPLEX.Optimizer)
        set_optimizer_attribute(model, "CPXPARAM_TimeLimit", 600.0) 
    else
        model = Model(HiGHS.Optimizer)
        set_time_limit_sec(model, 600.0)
    end

    
    @variable(model, u[1:n,1:n] >= 0)
    @variable(model, x[1:n], Bin)

    @constraint(model, [i=1:n,j=1:n], u[i,j] >= x[j] + x[i] - 1)
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[i])
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[j])

    @constraint(model, sum(w[i]*x[i] for i in 1:n) <= W)

    @objective(model, Max, sum(p[i,j]*u[i,j] for i in 1:n, j in 1:n)) 

    optimize!(model)
    
    return objective_value(model)
end

function solve_McCormick_QKP_relaxed(p,w,W,n, args) # to get an initial point 
    if args["cplex"] == true
        model = Model(CPLEX.Optimizer)
    else
        model = Model(HiGHS.Optimizer)
        # set_optimizer_attribute(model, "TimeLimit", 10.0) 
    end
    
    set_silent(model)
    
    @variable(model, u[1:n,1:n] >= 0)
    # @variable(model, x[1:n], Bin)
    @variable(model, 0 <= x[1:n] <= 1)
    @variable(model, s>=0) 

    @constraint(model, [i=1:n,j=1:n], u[i,j] >= x[j] + x[i] - 1)
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[i])
    @constraint(model, [i=1:n,j=1:n], u[i,j] <= x[j])

   c = @constraint(model, sum(w[i]*x[i] for i in 1:n) + s== W)

    @objective(model, Max, sum(p[i,j]*u[i,j] for i in 1:n, j in 1:n)) 

    optimize!(model)

    println("Solution to relaxed McCormick: ", objective_value(model))
    println(value.(x))

    println(dual(c))

    lambda_init = -dual(c)

    return lambda_init
end

# function solve_QKP_Lagrangian(p,w, n, (S, W), λ) # lagrangian function of quadratic relaxation
#     # function solve_QKP_Lagrangian(p,w, n, (k, W, include), λ) # lagrangian function of quadratic relaxation
#     x = Dict();
#     # model = Model(CPLEX.Optimizer)
#     model = Model(HiGHS.Optimizer)
#     set_silent(model)

#     # @variable(model, x[1:k], Bin)
#     for i in S
#         x[i] = @variable(model, base_name = "x[$(i)]", binary=true)
#     end

#     # if include == true 
#     #     @constraint(model, x[k] == 1)
#     # elseif include == false
#     #     @constraint(model, x[k] == 0)
#     # end

#     # @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in 1:k, j in 1:k) + λ * (W-sum(w[i]*x[i] for i  in 1:k)) )
#     @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in S, j in S) + λ * (W-sum(w[i]*x[i] for i  in S)) )

#     optimize!(model)

#     # println("Solution to quadratic relax Lagrangian ", objective_value(model))
    
#     objective_out = objective_value(model)

#     x_out = Dict()

#     for i in S
#         x_out[i] = value(x[i])
#     end

#     return objective_out, x_out
# end