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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        numNodes = N
        wordLookup = Dict{String,Int64}()
        edgeList = Vector{Tuple{Int64,Int64,Int64}}()
        for i in 1:N
            words = split(readline(infile))
            setWords = Set(words)
            for w in setWords
                if !haskey(wordLookup,w)
                    wordLookup[w] = numNodes+1
                    push!(edgeList,(numNodes+1,numNodes+2,1)) 
                    numNodes += 2
                end
                widx = wordLookup[w]
                push!(edgeList,(i,widx,1000000000))
                push!(edgeList,(widx+1,i,1000000000))
            end
        end

        ans = maxflow(1,2,numNodes,edgeList)
        print("$ans\n")
    end
end

main()
