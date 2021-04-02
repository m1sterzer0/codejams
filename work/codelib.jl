###########################################################################
##  CODE LIBRARY FOR JULIA.  STUFF INCLUDED
##  -- Maximum Bipartite Matching
##  -- Twosat
##  -- Min Heap
##  -- Max Heap
##  -- UnionFind
###########################################################################

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

function maxBPMAdjMatrix(bpGraph::Array{Int8,2},m::Int,n::Int)
    adjL = [Vector{Vector{Int}}() for x in 1:m]
    for i in 1:m
        for j in 1:n
            if bpGraph[i,j] > 0; push!(adjL[i],j); end;
        end
    end
    return maxBPM(adjL,m,n)
end

###########################################################################
## END: Maximum Bipartite Matching
###########################################################################

################################################################
## BEGIN Twosat
## n variables.  1:n represent the true values, and n+1:2n represent the complements
## a and b are length m arrays with the OR terms.
################################################################
function twosat(n::Int64,m::Int64,a::Array{Int64},b::Array{Int64})
    adj = [[] for i in 1:2n]
    adjInv = [[] for i in 1:2n]
    visited = fill(false,2n)
    visitedInv = fill(false,2n)
    s = Int64[]
    scc = fill(0,2n)
    counter = 1

    function addEdges(x::Int64,y::Int64); push!(adj[x],y); end

    function addEdgesInverse(x::Int64,y::Int64); push!(adjInv[y],x); end

    function dfsFirst(u::Int64)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::Int64)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        scc[u] = counter
    end

    ### Start the main routine
    ### Build the impplication graph
    for i in 1:m
        na = a[i] > n ? a[i] - n : a[i] + n
        nb = b[i] > n ? b[i] - n : b[i] + n
        addEdges(na,b[i])
        addEdges(nb,a[i])
        addEdgesInverse(na,b[i])
        addEdgesInverse(nb,a[i])
    end

    ### Kosaraju 1
    for i in 1:2n
        if !visited[i]; dfsFirst(i); end
    end

    ### Kosaraju 2
    while !isempty(s)
        nn = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end

    assignment = fill(false,n)
    for i in 1:n
        if scc[i] == scc[n+i]; return (false,[]); end
        assignment[i] = scc[i] > scc[n+i]
    end

    return (true,assignment)
end

################################################################
## END Twosat
################################################################

################################################################
## BEGIN Min Heap
################################################################

function _bubbleUpMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    if i == 1; return; end
    j::Int64 = i >> 1
    if vt[j] > vt[i]; vt[i],vt[j] = vt[j],vt[i]; _bubbleUpMinHeap(vt,j); end
end

function _bubbleDownMinHeap(vt::AbstractVector{T},i::Int64) where {T}
    len::Int64 = length(vt)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || vt[i] <= vt[l]
    res2::Bool = r > len || vt[i] <= vt[r]
    if res1 && res2; return;
    elseif res1; vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    elseif res2; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    elseif vt[l] <= vt[r]; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMinHeap(vt,l)
    else   vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMinHeap(vt,r)
    end
end

function _minHeapify(vt::AbstractVector{T}) where {T}
    len = length(vt)
    for i in 2:len; _bubbleUpMinHeap(vt,i); end
end

mutable struct MinHeap{T}
    valtree::Vector{T}
    MinHeap{T}() where {T} = new{T}(Vector{T}())
    function MinHeap{T}(xs::AbstractVector{T}) where {T}
        valtree = copy(xs)
        _minHeapify(valtree)
        new{T}(valtree)
    end
end
Base.length(h::MinHeap)  = length(h.valtree)
Base.isempty(h::MinHeap) = isempty(h.valtree)
top(h::MinHeap{T}) where {T} = h.valtree[1]
function Base.sizehint!(h::MinHeap{T},s::Integer) where {T}
    sizehint!(h.valtree,s); return h
end

function Base.push!(h::MinHeap{T},v::T) where {T} 
    push!(h.valtree,v)
    _bubbleUpMinHeap(h.valtree,length(h.valtree))
    return h
end

function Base.pop!(h::MinHeap{T}) where {T}
    v = h.valtree[1]
    xx = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.valtree[1] = xx
        _bubbleDownMinHeap(h.valtree,1)
    end
    return v
end

################################################################
## END Min Heap
################################################################

################################################################
## BEGIN Max Heap
################################################################

function _bubbleUpMaxHeap(vt::AbstractVector{T},i::Int64) where {T}
    if i == 1; return; end
    j::Int64 = i >> 1
    if vt[j] < vt[i]; vt[i],vt[j] = vt[j],vt[i]; _bubbleUpMaxHeap(vt,j); end
end

function _bubbleDownMaxHeap(vt::AbstractVector{T},i::Int64) where {T}
    len::Int64 = length(vt)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || vt[i] >= vt[l]
    res2::Bool = r > len || vt[i] >= vt[r]
    if res1 && res2; return;
    elseif res1; vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMaxHeap(vt,r)
    elseif res2; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMaxHeap(vt,l)
    elseif vt[l] >= vt[r]; vt[i],vt[l] = vt[l],vt[i]; _bubbleDownMaxHeap(vt,l)
    else   vt[i],vt[r] = vt[r],vt[i]; _bubbleDownMaxHeap(vt,r)
    end
end

function _maxHeapify(vt::AbstractVector{T}) where {T}
    len = length(vt)
    for i in 2:len; _bubbleUpMaxHeap(vt,i); end
end

mutable struct MaxHeap{T}
    valtree::Vector{T}
    MaxHeap{T}() where {T} = new{T}(Vector{T}())
    function MaxHeap{T}(xs::AbstractVector{T}) where {T}
        valtree = copy(xs)
        _maxHeapify(valtree)
        new{T}(valtree)
    end
end
Base.length(h::MaxHeap)  = length(h.valtree)
Base.isempty(h::MaxHeap) = isempty(h.valtree)
top(h::MaxHeap{T}) where {T} = h.valtree[1]
function Base.sizehint!(h::MaxHeap{T},s::Integer) where {T}
    sizehint!(h.valtree,s); return h
end

function Base.push!(h::MaxHeap{T},v::T) where {T} 
    push!(h.valtree,v)
    _bubbleUpMaxHeap(h.valtree,length(h.valtree))
    return h
end

function Base.pop!(h::MaxHeap{T}) where {T}
    v = h.valtree[1]
    xx = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.valtree[1] = xx
        _bubbleDownMaxHeap(h.valtree,1)
    end
    return v
end

################################################################
## END Max Heap
################################################################

################################################################
## BEGIN UnionFind
################################################################

mutable struct UnionFind{T}
    parent::Dict{T,T}
    size::Dict{T,Int64}
    
    UnionFind{T}() where {T} = new{T}(Dict{T,T}(),Dict{T,Int64}())
    
    function UnionFind{T}(xs::AbstractVector{T}) where {T}
        myparent = Dict{T,T}()
        mysize = Dict{T,Int64}()
        for x in xs; myparent[x] = x; mysize[x] = 1; end
        new{T}(myparent,mysize)
    end
end

function Base.push!(h::UnionFind,x) 
    ## Assume that we don't push elements on that are already in the set
    if haskey(h.parent,x); error("ERROR: Trying to push an element into UnionFind that is already present"); end
    h.parent[x]=x
    h.size[x] = 1
    return h
end

function findset(h::UnionFind,x) 
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function joinset(h::UnionFind,x,y)
    a = findset(h,x)
    b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a
        h.size[a] += h.size[b]
    end
end

################################################################
## END UnionFind
################################################################

################################################################
## BEGIN Dinic's Max Flow
################################################################

function dinic(n::Int64, s::Int64, t::Int64, edgeList::Array{Int64,2})::Int64
    myinf = typemax(Int64)
    nume = size(edgeList,1)
    adj,newEdgeList = _dinicBuildAdj(n,edgeList)
    level::Vector{Int64} = [0 for i in 1:n]
    next::Vector{Int64} = [0 for i in 1:n]
    maxflow::Int64 = 0
    while(_dinicBfs(s,t,newEdgeList,adj,level))
        next = fill!(1)
        f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        while(f > 0)
            maxflow += f
            f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        end
    end
    return maxflow
end

function _dinicBuildAdj(n::Int64,edgeList::Array{Int64,2})
    ne = size(edgeList,1)
    newEdgeList::Array{Int64,2} = fill(0,2*ne,3)
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for x in 1:n]
    for i in 1:ne
        n1,n2,c = edgeList[i,:]
        newEdgeList[i,:] = [n1,n2,c]
        newEdgeList[ne+i,:] = [n2,n1,0]
        push!(adj[n1],i)
        push!(adj[n2],ne+i)
    end
    return adj,newEdgeList
end
    
function _dinicBfs(s::Int64, t::Int64, edgeList::Array{Int64,2}, adj::Vector{Vector{Int64}}, level::Vector{Int64})
    fill!(level,-1)
    level[s] = 0
    q::Vector{Int64} = [s]
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

function _dinicDfs(nn::Int64, t::Int64, nume::Int64, edgeList::Array{Int64,3}, adj::Vector{Vector{Int64}}, level::Vector{Int64}, next::Vector{Int64}, flow::Int64)::Int64
    if n == t; return flow; end
    ne = length(adj[nn])
    for eid in adj[next[n]:end]
        next[n] += 1
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
    end
    return 0
end


################################################################
## END Dinic's Max Flow
################################################################
