function QKP_DP(p, w, W, n, λ, s, x0, args)
    f = Dict(); 
    profit = 0
    for k in 1:n
        for r in 0:W 
            f[(k,r)] = -1e6
        end
    end
    f[(0,0)] = 0  ## initialize f0 (initial control)
    ## initialize the set S = "set associated with profit of f"
    S = Set() # empty list for indices ... subset of {1,...,k}
    ### initialize the timer
    elapsed_time = 0
    timer = time()
    for k in 1:n # number of states
        for r in 0:W ## total capacity W

            if f[(k-1,r)] > f[(k,r)]
                f[(k,r)] = f[(k-1,r)] ## weirdly done twice, but second is to keep track of values later 
                push!(S(k,r) , S(k-1,r)) ### TODO: FIX
            end

            if r + w[k] <= W ## current remaining capacity plus weight at current iteration less than total capacity
                β = f[(k-1,r)] + p[k,k] + 2*sum(p[i,k] for i in S(k-1,r)) ## need to derive this identity
                if β > solve_McCormick_QKP(k, r+w[k]) ## compare the solutions 
                    f[(k,r+w[k])] = β  
                    S(k,r+w[k]) = S(k-1,r) ∪ {k} ## append the new index
                end
            end

        end 
        elapsed_time = time() - timer
    end
    r = argmax{r in 0:W} f(n,r) ## maximize over all possible values of r... TODO: FIX

    for i in S
        for j in S
            profit += p[i,j]
        end
    end

    return r, profit, elapsed_time ## objective value evaluated after all items are considered with capacity used, r....... ?
end

##TODO: add logging 

function log_DP()

end