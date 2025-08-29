# output_for_non_relaxed = solve_QKP(p,w,W,n)

# objective_mccormick = solve_McCormick_QKP_non_relaxed(p,w,W,n)

# λ = solve_McCormick_QKP(p,w,W,n)

# println(λ)

# objective_out, x = solve_QKP_Lagrangian(p,w, (n, W), λ)

## main algorithm ... 
function QKP_rollout(p,w,W,n,s, args) 
    λ = solve_McCormick_QKP_relaxed(p,w,W, 1, args) # initialize λ0 -- obtain from solving McCormick relaxation (with only a single item currently) 
    S = Set{Int64}(vcat(1:n)) ## initial set with all indices included 
    U = Set{Int64}(vcat(1:n))
    r = W # remaining capacity -- going to update within the loop to follow
    profit = 0 # initialize the profit 
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
            obj, x = base_policy_lagrangian(p,w, n, (S̃, r-w[i]), λ, args)
            xk[i] = x
            Vk[i] = p[i,i] + 2 * sum(p[i, k] for k in S̄) + obj
        end

        if isempty(Vk) == false
            î = reduce((x, y) -> Vk[y] ≤ Vk[x] ? x : y, keys(Vk)) # get the key associated with the maximum value of the Dictionary -- only works if non-empty, may pose problems if empty.
            xî = xk[î]

            S = delete!(S,î)

            r -= w[î] # update the remaining capacity 

            gx = sum(w[i]*xî[i] for i in S) - r
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

##TODO: add logging 

# function log_RODP()

# end
