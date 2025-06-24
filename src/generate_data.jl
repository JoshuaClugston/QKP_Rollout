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


function get_data(path_to_file) 
    open(path_to_file) do io
        ## first entry should be n, second entry should be p matrix, third entry should be w vector, and fourth should be W.
        n = 0
        p = []
        w = []
        W = 0
        line_count = 1

        for line in eachline(io)
            if line_count == 1
                n = parse(Int64, line)
            elseif line_count == 2
                p = mapreduce(permutedims, vcat, [parse.(Int64,split(lines, ' ')) for lines in split(chop(line, head = 1, tail = 1), ';')]) ## assumes that there is not a space immediately following ';' 
            elseif line_count == 3
                w = parse.(Int, split(chop(line, head = 1, tail = 1), ',')) ## ensure that there is not a space after data line 
            elseif line_count == 4
                W = parse(Int64, line)
            end
            line_count += 1
        end
        return n,p,w,W
    end
end