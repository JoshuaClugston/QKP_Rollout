using Distributions, StatsBase

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