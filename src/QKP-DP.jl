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