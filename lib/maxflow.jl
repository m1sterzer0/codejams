
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

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

################################################################
## BEGIN Dinic's Max Flow
################################################################

function dinic(n::I, s::I, t::I, edgeList::Vector{TI})::I
    myinf = typemax(Int64)
    nume = size(edgeList,1)
    adj,newEdgeList = _dinicBuildAdj(n,edgeList)
    level::VI = [0 for i in 1:n]
    next::VI = [0 for i in 1:n]
    maxflow::I = 0
    while(_dinicBfs(s,t,newEdgeList,adj,level))
        fill!(next,1)
        f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        while(f > 0)
            maxflow += f
            f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        end
    end
    return maxflow
end

function _dinicBuildAdj(n::I,edgeList::Vector{TI})
    ne = length(edgeList)
    newEdgeList::Array{I,2} = fill(0,2*ne,3)
    adj::VVI = [VI() for x in 1:n]
    for i in 1:ne
        (n1,n2,c) = edgeList[i]
        newEdgeList[i,:] = [n1,n2,c]
        newEdgeList[ne+i,:] = [n2,n1,0]
        push!(adj[n1],i)
        push!(adj[n2],ne+i)
    end
    return adj,newEdgeList
end
    
function _dinicBfs(s::I, t::I, edgeList::Array{I,2}, adj::VVI, level::VI)
    fill!(level,-1)
    level[s] = 0
    q::VI = [s]
    while(!isempty(q))
        nn = pop!(q)
        for eid in adj[nn]
            n1,n2,c = edgeList[eid,:]
            if (c > 0 && level[n2] == -1)
                level[n2] = level[n1] + 1
                push!(q,n2)
            end
        end
    end
    return level[t] != -1
end

function _dinicDfs(n::I, t::I, nume::I, edgeList::Array{I,2}, adj::VVI, level::VI, next::VI, flow::I)::I
    if n == t; return flow; end
    ne = length(adj[n])
    while next[n] <= ne
        eid = adj[n][next[n]]
        n1,n2,c = edgeList[eid,:]
        if c > 0 && level[n2] == level[n1]+1
            bottleneck = _dinicDfs(n2,t,nume,edgeList,adj,level,next,min(flow,c))
            if bottleneck > 0
                edgeList[eid,3] -= bottleneck
                eid2 = eid > nume ? eid - nume : eid + nume
                edgeList[eid2,3] += bottleneck
                return bottleneck
            end
        end
        next[n] += 1
    end
    return 0
end

################################################################
## END Dinic's Max Flow
################################################################
