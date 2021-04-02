using Printf

######################################################################################################
### For this, we can solve by doing O(N) maximum bipartite matches that are each O(N^2)
######################################################################################################

######################################################################################################
### BEGIN MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################


function bpm(bpGraph::Array{Int8,2}, adjL::Vector{Vector{Int}}, u::Int, seen::Array{Bool,1}, matchR::Array{Int,1}, m::Int, n::Int)::Bool
    for v in adjL[u]
        if !seen[v]
            seen[v] = true
            if matchR[v] < 0 || bpm(bpGraph,adjL,matchR[v], seen, matchR, m, n)
                matchR[v] = u
                return true
            end
        end
    end
    return false
end

function maxBPM(bpGraph::Array{Int8,2},m::Int,n::Int)
    adjL = [Vector{Int}() for x in 1:m]
    for i in 1:m
        adjL[i] = [x for x in 1:n if bpGraph[i,x] == 1]
    end
    matchR = fill(-1,n)
    seen = fill(false,n)
    result = 0
    for u in 1:m
        fill!(seen,false)
        if bpm(bpGraph,adjL,u,seen,matchR,m,n); result += 1; end
    end
    matches = Set((matchR[x],x) for x in 1:n if matchR[x] > 0)
    return result,matches
end

######################################################################################################
### END MAXIMUM BIPARTITE MATCHING CODE
### Inspired by https://www.geeksforgeeks.org/maximum-bipartite-matching/
######################################################################################################

function findNextStart(st::Int64,lastGap::Int64,dgr::Vector{Vector{Int64}},maxdig::Int)
    while(st <= maxdig)
        while st <= maxdig && length(dgr[st]) == 0; st += 1; end
        en = st
        good = true
        for en in st:st+lastGap
            if en > maxdig; st = en+1; good=false; break; end
            if length(dgr[en]) == 0; st = en+1; good=false; break; end
        end
        if good; return (st,st+lastGap); end
    end
    return (maxdig+1,maxdig+1)
end

function tryMatch(st,en,dgr)
    gr = Set{Int64}()
    for i in st:en
        for j in dgr[i]; push!(gr,j); end
    end
    bpGraph = fill(zero(Int8),en-st+1,length(gr))
    nodecnt = 0
    lookup = Dict{Int64,Int64}()
    for n in gr
        if !haskey(lookup,n); nodecnt += 1; lookup[n] = nodecnt; end
    end
    for i in st:en
        for j in dgr[i]; bpGraph[i-st+1,lookup[j]] = Int8(1); end
    end
    res,matches = maxBPM(bpGraph,en-st+1,length(lookup))
    return res == (en-st+1)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        D = fill(-1,N,6)
        maxdig = 1
        for i in 1:N
            D[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            maxdig = max(maxdig,maximum(D[i,:]))
        end

        dgr = [Vector{Int64}() for i in 1:maxdig]

        for i in 1:N
            for j in 1:6
                push!(dgr[D[i,j]],i)
            end
        end
        best = 1
        (i,j) = findNextStart(1,best,dgr,maxdig)
        while (i < maxdig && j <= maxdig)
            if tryMatch(i,j,dgr)
                best += 1
                if j < maxdig && length(dgr[j+1]) > 0; j += 1
                else; (i,j) = findNextStart(j+2,best,dgr,maxdig);
                end
            else
                if j < maxdig && length(dgr[j+1]) > 0; j += 1; i += 1
                else;  (i,j) = findNextStart(j+2,best,dgr,maxdig);
                end
            end
        end
        print("$best\n")
    end
end

main()
