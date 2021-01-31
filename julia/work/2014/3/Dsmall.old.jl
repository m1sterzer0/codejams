######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
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

        function alphabeta(p1pos::Int64,p2pos::Int64,alpha::Int64,beta::Int64,p1flag::Bool,p1gold::Int64,p2gold::Int64,p1stuck::Bool,p2stuck::Bool)::Int64
            if p1stuck && p2stuck; return p1gold-p2gold; end
            if p1flag
                if p1stuck; return alphabeta(p1pos,p2pos,alpha,beta,false,p1gold,p2gold,p1stuck,p2stuck); end
                value::Int64 = typemin(Int64)
                incgold::Int64 = C[p1pos]
                C[p1pos] = 0
                p1stuck = true
                for n2::Int64 in adj[p1pos]
                    if !edgesb[p1pos,n2]; continue; end
                    p1stuck = false
                    edgesb[p1pos,n2] = edgesb[n2,p1pos] = false
                    res::Int64 = alphabeta(n2,p2pos,alpha,beta,false,p1gold+incgold,p2gold,p1stuck,p2stuck)
                    edgesb[p1pos,n2] = edgesb[n2,p1pos] = true
                    value = max(value,res)
                    alpha = max(alpha,value)
                    if alpha >= beta; break; end
                end
                if p1stuck
                    value = alphabeta(p1pos,p2pos,alpha,beta,false,p1gold+incgold,p2gold,p1stuck,p2stuck)
                end
                C[p1pos] = incgold
                return value
            else
                if p2stuck; return alphabeta(p1pos,p2pos,alpha,beta,true,p1gold,p2gold,p1stuck,p2stuck); end
                value = typemax(Int64)
                incgold = C[p2pos]
                C[p2pos] = 0
                p2stuck = true
                for n2 in adj[p2pos]
                    if !edgesb[p2pos,n2]; continue; end
                    p2stuck = false
                    edgesb[p2pos,n2] = edgesb[n2,p2pos] = false
                    res = alphabeta(p1pos,n2,alpha,beta,true,p1gold,p2gold+incgold,p1stuck,p2stuck)
                    edgesb[p2pos,n2] = edgesb[n2,p2pos] = true
                    value = min(value,res)
                    beta = min(beta,value)
                    if alpha >= beta; break; end
                end
                if p2stuck
                    value = alphabeta(p1pos,p2pos,alpha,beta,true,p1gold,p2gold+incgold,p1stuck,p2stuck)
                end
                C[p2pos] = incgold
                return value
            end
        end
    
        best = typemin(Int64)
        for i in 1:N
            lbest = typemax(Int64)
            for j in 1:N
                trial = alphabeta(i,j,best,typemax(Int64),true,0,0,false,false)
                lbest = min(lbest,trial)
            end
            best = max(best,lbest)
        end
        print("$best\n")
    end
end

main()
