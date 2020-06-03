using Printf

######################################################################################################
### We need to cover the set of first and second words with as few entries as possible to maximize
### the list of potential fakers.  This cover is minimized when i MAXIMIZE the number of entries that
### "take out" two previoiusly untaken terms at onces.  This can be found with a maximum bipartite
### matching algorithm.
######################################################################################################


######################################################################################################
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function bpm(bpGraph::Array{Int8,2}, u::Int, seen::Array{Bool,1}, matchR::Array{Int,1}, m::Int, n::Int)::Bool
    for v in 1:n
        if bpGraph[u,v] == 1 && !seen[v]
            seen[v] = true
            if matchR[v] < 0 || bpm(bpGraph, matchR[v], seen, matchR, m, n)
                matchR[v] = u
                return true
            end
        end
    end
    return false
end

function maxBPM(bpGraph::Array{Int8,2},m::Int,n::Int)
    matchR = fill(-1,n)
    seen = fill(false,n)
    result = 0
    for u in 1:m
        fill!(seen,false)
        if bpm(bpGraph,u,seen,matchR,m,n); result += 1; end
    end
    return result
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        fw,lw = Dict{String,Int64}(),Dict{String,Int64}()
        graphTuples = []
        nfw,nlw = 0,0
        
        for i in 1:N
            w1,w2 = split(rstrip(readline(infile)))
            if !haskey(fw,w1); nfw+=1; fw[w1] = nfw; end
            if !haskey(lw,w2); nlw+=1; lw[w2] = nlw; end
            push!(graphTuples,(fw[w1],lw[w2]))
        end
        
        ## Make the adjacency matrix
        gr = zeros(Int8,nfw,nlw)
        for t in graphTuples
            gr[t[1],t[2]] = 1
        end

        doubles = maxBPM(gr,nfw,nlw)
        singles = nfw+nlw-2*doubles
        print("$(N-doubles-singles)\n")
    end
end

main()