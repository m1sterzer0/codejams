using Printf

######################################################################################################
### BEGIN MAX FLOW
######################################################################################################

function bfsMaxFlow(s::Int64, t::Int64, adj::Vector{Set{Int64}}, capacity::Vector{Dict{Int64,Int64}}, parent::Vector{Int64})::Int64
    fill!(parent,-1)
    parent[s] = -2
    q = Vector{Tuple{Int64,Int64}}()
    push!(q,(s,1000000000000000000))

    while !isempty(q)
        (cur::Int64,flow::Int64) = popfirst!(q)
        for next::Int64 in adj[cur]
            if parent[next] == -1 && capacity[cur][next] > 0
                parent[next] = cur
                newFlow = min(flow,capacity[cur][next])
                if next == t; return newFlow; end
                push!(q,(next,newFlow))
            end
        end
    end
    return 0
end

function maxflow(s::Int64, t::Int64, N::Int64, edgeList::Vector{Tuple{Int64,Int64,Int64}})::Int64

    ## Make the graph from the weighted edge list (source,dest,capacity)
    adj = Vector{Set{Int64}}()
    for i in 1:N; push!(adj,Set{Int64}()); end
    capacity = Vector{Dict{Int64,Int64}}()
    for i in 1:N; push!(capacity,Dict{Int64,Int64}()); end
    for e in edgeList
        push!(adj[e[1]], e[2])
        push!(adj[e[2]], e[1])
        capacity[e[1]][e[2]] = e[3]
        if !haskey(capacity[e[2]],e[1]); capacity[e[2]][e[1]] = 0; end
    end

    ## Now we do the max flow part
    flow::Int64 = 0
    parent = fill(-1,N)
    while(true)
        newFlow = bfsMaxFlow(s,t,adj,capacity,parent)
        if newFlow == 0; break; end
        flow += newFlow
        cur::Int64 = t
        while(cur != s)
            prev::Int64 = parent[cur]
            capacity[prev][cur] -= newFlow
            if !haskey(capacity[cur],prev); capacity[cur][prev] = 0; end
            capacity[cur][prev] += newFlow
            cur = prev
        end
    end
    return flow
end

######################################################################################################
### END MAX FLOW
######################################################################################################


######################################################################################################
### BEGIN MAIN PROGRAM
###
### Small can be tackled as follows
### * Get the distance from the source for each node
### * Create a directed graph where all possible shortest paths have directed edgeList
### * Replace each node with a pair of nodes with limited capacity of 1
### * Run max flow
### * Rely on min-cut/max-flow theorem to conclude if there is a way to delay by 2, otherwise assume delay by 1. 
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        N,M,K = [parse(Int64,x) for x in split(readline(infile))]
        edgeList::Vector{Tuple{Int64,Int64}} = []
        for i in 1:M
            x1,x2 = [parse(Int64,x) for x in split(readline(infile))]
            push!(edgeList,(x1+1,x2+1))
        end

        ## Do the BFS for distances
        darr = fill(-1,N)
        adj::Vector{Vector{Int64}} = [ [] for i in 1:N ]
        for e in edgeList
            push!(adj[e[1]],e[2])
            push!(adj[e[2]],e[1])
        end
        darr[1] = 0
        q = [1]
        while !isempty(q)
            n = popfirst!(q)
            for k in adj[n]
                if darr[k] == -1
                    darr[k] = darr[n]+1
                    push!(q,k)
                end
            end
        end

        ## Create the directed graph
        mfedgelist = Vector{Tuple{Int64,Int64,Int64}}()
        for i in 2:N-1; push!(mfedgelist,(i,N+i,1)); end
        for e in edgeList
            if darr[e[1]] + 1 == darr[e[2]]; push!(mfedgelist,(e[1]+N,e[2],1000000)); end
            if darr[e[2]] + 1 == darr[e[1]]; push!(mfedgelist,(e[2]+N,e[1],1000000)); end
        end

        ## Do the max flow thing
        minCut = maxflow(N+1,N,2*N,mfedgelist)
        ans = minCut <= K-1 ? darr[N]+2 : darr[N]+1
        print("$ans\n")
    end
end

main()
