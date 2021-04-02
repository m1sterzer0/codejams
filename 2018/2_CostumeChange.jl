######################################################################################################
### * There are enough costumes to fix any problems with a row or column (i.e. we aren't further
###   limited by available costumes causing cascading effect)
### * This is just a "keep the most rooks" problem for each of the 2N costume types, which we can
###   solve with bipartite matching (a GCJ favorite)
######################################################################################################

###########################################################################
## BEGIN: Maximum Bipartite Matching
###########################################################################

function checkMatch(adjL::Vector{Vector{Int}}, matchR::Vector{Int}, seen::Vector{Int8}, n::Int)
    for v in adjL[n]
        if seen[v] > 0; continue; end
        seen[v] = 1
        if matchR[v] == -1; matchR[v] = n; return true; end
        if checkMatch(adjL,matchR,seen,matchR[v]); matchR[v] = n; return true; end
    end
    return false
end

function maxBPM(adjL::Vector{Vector{Int}}, m::Int, n::Int)
    matchR = fill(-1,n)
    seen = fill(zero(Int8),n)
    result = 0
    for u in 1:m
        fill!(seen,0)
        if checkMatch(adjL,matchR,seen,u); result += 1; end
    end
    matches = [(matchR[x],x) for x in 1:n if matchR[x] != -1]
    return result,matches
end

###########################################################################
## END: Maximum Bipartite Matching
###########################################################################

function findChanges(g::Array{Int64,2},adj::Vector{Vector{Int64}},N::Int64,p::Int64)
    for v in adj; resize!(v,0); end
    cnt = 0
    for i in 1:N
        for j in 1:N
            if g[i,j] == p
                cnt += 1
                push!(adj[i],j)
            end
        end
    end
    res,_matches = maxBPM(adj,N,N)
    return cnt-res
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        g = fill(0,N,N)
        for i in 1:N
            g[i,:] .= [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:N]

        changes = 0
        for i in (1:N);   changes += findChanges(g,adj,N,i); end
        for i in (-N:-1); changes += findChanges(g,adj,N,i); end
        
        print("$changes\n")
    end
end

main()
