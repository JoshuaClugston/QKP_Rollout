using JuMP, CPLEX, Distributions, StatsBase, Ipopt

## generating data according to Fomeni & Letchford "A Dynamic Programming Heuristic for the QKP"
function get_data(n,density_percentage) # n is the dimension of the decision variables, what is density percentage?
    p = Int64[] ## price coefficients
    w = Dict() ## weights

    ### probabilities for p 
    probability = [1-density_percentage, density_percentage] ## probability of selecting

    p = [sample([0,rand(DiscreteUniform(1,100))], weights(probability)) for i in 1:n, j in 1:n] ## weights() is a function from StatsBase, as is sample()

    for i in 1:n 
        w[i] = rand(DiscreteUniform(1,n)) ## randomly select a value in [1, dimension = n ] 
    end

    Σw = sum(values(w))

    W = rand(DiscreteUniform(n,Σw)) ## capacity

    return p, w, Int(W) 
end

# n = 200
n = 200
prob = 0.80

p, w, W = get_data(n,prob)

########### testing
function solve_QKP(p,w,W,n)

    # println(p) 
    # println(w)
    # println(W)

    model = Model(CPLEX.Optimizer)

    @variable(model, x[1:n], Bin)

    @constraint(model, sum(w[i]*x[i] for i in 1:n) <= W)

    @objective(model, Max, sum(p[i,j]*x[i]*x[j] for i in 1:n, j in 1:n))

    # println(model)

    optimize!(model)

    println("Solution to non-relaxed ", objective_value(model))
    println(value.(x))
    return objective_value(model)
end

## TODO: read in data from the one instance file, if specified...  

# output_for_non_relaxed = solve_QKP(p,w,W,n)

function solve_McCormick_QKP_non_relaxed(p,w,W,n) # to get an initial point 
    model = Model(CPLEX.Optimizer)
    set_optimizer_attribute(model, "CPXPARAM_TimeLimit", 600.0) 
    
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

objective_mccormick = solve_McCormick_QKP_non_relaxed(p,w,W,n)


function solve_McCormick_QKP(p,w,W,n) # to get an initial point 
    model = Model(CPLEX.Optimizer)
    # set_optimizer_attribute(model, "TimeLimit", 10.0) 

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

    println("Solution to relaxed ", objective_value(model))
    println(value.(x))

    println(dual(c))

    lambda_init = -dual(c)

    return lambda_init
end

# λ = solve_McCormick_QKP(p,w,W,n)

# println(λ)

function solve_QKP_Lagrangian(p,w, n, (S, W), λ) # lagrangian function of quadratic relaxation
    # function solve_QKP_Lagrangian(p,w, n, (k, W, include), λ) # lagrangian function of quadratic relaxation
    x = Dict();
    model = Model(CPLEX.Optimizer)
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

# objective_out, x = solve_QKP_Lagrangian(p,w, (n, W), λ)


# function QKP_DP(p, w, W, n, λ, s, x0)
#     x = x0 ## get the x from solving the initial relaxation 
#     f = Dict(); # dictionary for controls
#     for k in 1:n
#         for r in 0:W 
#             f[(k,r)] = -1e6
#         end
#     end
#     f[(0,0)] = 0  ## initialize f0 (initial control)
#     ## initialize the set S ... which is? 
#     S = Set() # empty list for indices ... subset of {1,...,k}
#     ### initialize the timer
#     elapsed_time = 0
#     timer = time()
#     for k in 1:n # number of states
#         for r in 0:W ## total capacity W
#             if k-1 == 0 && r == 0 ## first iteration
#                 f[(k-1,r)] = f[(0,0)]
#             else
#                 f[(k-1,r)], xkr_1 = solve_QKP_Lagrangian(k-1,r)
#             end
#             # fkr, xkr = solve_QKP_Lagrangian(k,r)
#             if f[(k-1,r)] > f[(k,r)]
#                 f[(k,r)] = f[(k-1,r)] ## weirdly done twice, but second is to keep track of values later 
#                 x = xkr_1 ## thinking this because setting equal to fkr_1 ... ? 
#                 push!(S(k,r) , S(k-1,r)) ### TODO: FIX
#             end

#             if r + w[k] <= W ## current remaining capacity plus weight at current iteration less than total capacity
#                 β = f[(k-1,r)] + p[k,k] + 2*sum(p[i,k] for i in S(k-1,r)) ## need to derive this identity -- TODO: FIX
#                 if β > solve_McCormick_QKP(k, r+w[k]) ## compare the solutions 
#                     f[(k,r+w[k])] = β  
#                     S(k,r+w[k]) = S(k-1,r) ∪ {k} ## append the new index -- TODO: FIX
#                 end
#             end

#             ## need to somehow update the x to be used in the gradient ... 
#             # gx = sum(w[i]*x[i] for i in 1:k) - r # subgradient at iteration with capacity r -- termination based on size of gradient? 
#             # λ_new = λ + s * gx ## mutlipliers

#         end 
#         elapsed_time = time() - timer
#     end
#     r = argmax{r in 0:W} f(n,r) ## maximize over all possible values of r... TODO: FIX
#     return r, elapsed_time ## objective value evaluated after all items are considered with capacity used, r....... ?
# end

## main algorithm ... 
# function QKP_rollout(p,w,W,n,s)
#     λ = solve_McCormick_QKP(p,w,W, 1) # initialize λ0 -- obtain from solving McCormick relaxation
#     S = Set{Int64}() 
#     r = W # remaining capacity -- going to update within the loop to follow
#     profit = 0 # initialize the profit ... 
#     for k in 1:n 
#         obj_β, x_β = solve_QKP_Lagrangian(p,w, n, (k, r, false), λ)
#         # obj_β, x_β = solve_QKP_Lagrangian_y(p,w, (k-1, r), λ)
#         if w[k] <= r
#             # obj_α, x_α = solve_QKP_Lagrangian(p,w, n, (k, r-w[k]), λ)
#             obj_α, x_α = solve_QKP_Lagrangian(p,w, n, (k, r-w[k], true), λ)
#             V = p[k,k] + 2 * sum(p[i, k] for i in S) + obj_α
#             # V = p[k,k] + (isempty(S) ? 0.0 : 2 * sum(p[i, k] for i in S)) + obj_α
#         else
#             V = -Inf
#         end
#         println("r at iteration $(k) is $(r), while w[k] is $(w[k])")
#         # println(V)
#         # println(obj_β)

#         if V > obj_β
#             push!(S,k)
#             r -= w[k]
#             x = x_α
#         else
#             x = x_β
#         end

#         gx = sum(w[i]*x[i] for i in 1:k) - r ## TODO: fix...

#         λ_new = λ + s * gx
#         λ = λ_new  

#         s = s/k # demininshing stepsize

#         # println("iteration $(k)")
#     end

#     return sort!(collect(S)), sum(p[i,j] for i in S, j in S) 
# end


function QKP_rollout(p,w,W,n,s)
    λ = solve_McCormick_QKP(p,w,W, 1) # initialize λ0 -- obtain from solving McCormick relaxation (with only a single item currently) 
    S = Set{Int64}(vcat(1:n)) ## initial set with all indices included 
    U = Set{Int64}(vcat(1:n))
    r = W # remaining capacity -- going to update within the loop to follow
    profit = 0 # initialize the profit ... 
    counter = 0
    elapsed_time = 0
    timing = time()
    for iter in U
        S̄ = Set{Int64}()
        # println("beginning S at iteration $(counter) is $(S)")
        for i in S
            # println("at ieration $(counter) this is $(i)'s weight: $(w[i]). r at this iteration is $(r)")
            if w[i] <= r
                push!(S̄,i)
            end
        end

        
        Vk = Dict()
        xk = Dict() 
        for i in S̄
            S̃ = setdiff(S,i) ## S̄\{i}  
            obj, x = solve_QKP_Lagrangian(p,w, n, (S̃, r-w[i]), λ)
            xk[i] = x
            Vk[i] = p[i,i] + 2 * sum(p[i, k] for k in S̄) + obj
        end

        if isempty(Vk) == false
            î = reduce((x, y) -> Vk[y] ≤ Vk[x] ? x : y, keys(Vk)) # get the key associated with the maximum value of the Dictionary -- only works is non-empty ... may pose problems if empty... 
            xî = xk[î]

            S = delete!(S,î)

            r -= w[î] # update the remaining capacity 

            gx = sum(w[i]*xî[i] for i in S) - r ## TODO: need to get x to be used from above ... also k is not being used here....
            λ_new = λ + s * gx
            λ = λ_new  
        else
            continue 
        end
    
        counter +=1 
        # println("iteration number $(counter)")
    
        elapsed_time = time()-timing
        if isempty(S) || isempty(S̄) || r == 0
            break
        end  

    end

    for i in setdiff(U,S)
        for j in setdiff(U,S)
            profit += p[i,j]
        end
    end

    # println(sort!(collect(setdiff(U,S))))

    println(elapsed_time) 

    return profit
    # return sort!(collect(S)), sum(p[i,j] for i in S, j in S) 
end

# S, profit = QKP_rollout(p,w,W,n,1.0)
profit = QKP_rollout(p,w,W,n, 1.0)

println("final profit is: ", profit)
# println(w)
# println(W)

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

### check approximate "gap"
# println(abs(profit - output_for_non_relaxed)/output_for_non_relaxed)

println(" $(abs(profit - objective_mccormick)/objective_mccormick) is the 'gap' value compared with McCormick reformulation.")
