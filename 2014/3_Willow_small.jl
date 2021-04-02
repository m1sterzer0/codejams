######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    inf::Int64 = 1000000007  ## Biggset score should be 500 * 10k = 5M.

    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        C::Vector{Int64} = fill(0,N)
        for i in 1:N; C[i] = parse(Int64,readline(infile)); end
        edgesb::Array{Bool,2} = fill(false,N,N)
        adj::Vector{Vector{Int64}} = []
        for i in 1:N; push!(adj,[]); end
        for i in 1:N-1
            j = parse(Int64,readline(infile))
            edgesb[i,j] = edgesb[j,i] = true
            push!(adj[i],j)
            push!(adj[j],i)
        end

        function negamax(mypos::Int64,otherpos::Int64,myscoresofar::Int64,alpha::Int64,beta::Int64,mystuck::Bool,otherstuck::Bool)
            if mystuck && otherstuck; return myscoresofar; end
            if mystuck; return -negamax(otherpos,mypos,-myscoresofar,-beta,-alpha,otherstuck,mystuck); end
            value::Int64,incgold::Int64,n2::Int64 = -inf,C[mypos],0
            C[mypos] = 0
            myscoresofar += incgold
            mystuck = true
            for n2::Int64 in adj[mypos]
                if !edgesb[mypos,n2]; continue; end
                mystuck = false
                edgesb[mypos,n2] = edgesb[n2,mypos] = false
                value = max(value,-negamax(otherpos,n2,-myscoresofar,-beta,-alpha,otherstuck,mystuck))
                edgesb[mypos,n2] = edgesb[n2,mypos] = true
                alpha = max(alpha,value)
                if alpha >= beta; break; end
            end
            if mystuck; value = -negamax(otherpos,mypos,-myscoresofar,-beta,-alpha,otherstuck,mystuck); end
            C[mypos] = incgold
            return value
        end

        alpha = -inf
        for i in 1:N
            beta = inf
            for j in 1:N
                value = negamax(i,j,0,alpha,beta,false,false)
                beta = min(beta,value)
                if alpha > beta; break; end
            end
            alpha = max(alpha,beta)
        end
        print("$alpha\n")
    end
end

main()
