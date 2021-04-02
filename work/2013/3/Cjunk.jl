######################################################################################################
### BEGIN DIJKSTRA CODE (ADJ LIST)
######################################################################################################

mutable struct MinHeapDijkstra
    valtree::Vector{Tuple{Int64,Int64}}
    pos::Vector{Int64}
    MinHeapDijkstra(N::Int64) = new([],fill(0,N))
end

function _bubbleUp(h::MinHeapDijkstra, i::Int64)
    if i == 1; return; end
    (n1::Int64,v1::Int64) = h.valtree[i]
    j::Int64 = i >> 1
    (n2::Int64,v2::Int64) = h.valtree[j]
    if v1 < v2
        h.pos[n2] = i
        h.pos[n1] = j
        h.valtree[i] = (n2,v2)
        h.valtree[j] = (n1,v1)
        _bubbleUp(h,j)
    end
end

function _bubbleDown(h::MinHeapDijkstra,i::Int64)
    ##print("DBG: _bubbleDown(h:$h,i:$i)\n")
    len::Int64 = length(h.valtree)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || h.valtree[i][2] <= h.valtree[l][2]
    res2::Bool = r > len || h.valtree[i][2] <= h.valtree[r][2]
    if res1 && res2; return;
    elseif res2 || !res1 && h.valtree[l][2] <= h.valtree[r][2]
        (n1,v1) = h.valtree[i]
        (n2,v2) = h.valtree[l]
        h.pos[n2] = i
        h.pos[n1] = l
        h.valtree[i] = (n2,v2)
        h.valtree[l] = (n1,v1)
        _bubbleDown(h,l)
    else
        (n1,v1) = h.valtree[i]
        (n2,v2) = h.valltree[r]
        h.pos[n2] = i
        h.pos[n1] = r
        h.valtree[i] = (n2,v2)
        h.valtree[r] = (n1,v1)
        _bubbleDown(h,r)
    end
end

function Base.push!(h::MinHeapDijkstra,n::Int64,v::Int64)
    idx::Int64 = h.pos[n]
    if idx == 0 
        push!(h.valtree,(n,v))
        idx = length(h.valtree)
        h.pos[n] = idx
    elseif h.valtree[idx][2] > v
        h.valtree[idx] = (n,v)
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MinHeapDijkstra)
    (n,v) = h.valtree[1]
    h.pos[n] = 0
    (n2,v2) = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.pos[n2] = 1
        h.valtree[1] = (n2,v2)
        _bubbleDown(h,1)
    end
    return (n,v)
end

Base.isempty(h::MinHeapDijkstra) = isempty(h.valtree)

function dijkstraAdjList(N::Int64,src::Int64,adj::Vector{Vector{Tuple{Int64,Int64}}})::Vector{Int64}
    myinf = 1_000_000_000_000_000_000
    dist = fill(myinf,N)
    minheap = MinHeapDijkstra(N)
    push!(minheap,src,0)
    while !isempty(minheap) 
        (n,v) = pop!(minheap)
        dist[n] = v
        for (n2,v2) in adj[n]
            if dist[n2] == myinf; push!(minheap,n2,v+v2); end
        end
    end
    return dist
end

######################################################################################################
### END DIJKSTRA CODE (ADJ LIST)
######################################################################################################

function test()
    function addEdge(adj,a,b,v)
        push!(adj[a+1],(b+1,v))
        push!(adj[b+1],(a+1,v))
    end
    adj::Vector{Vector{Tuple{Int64,Int64}}} = [Vector{Tuple{Int64,Int64}}() for i in 1:9]
    addEdge(adj, 0, 1, 4); 
    addEdge(adj, 0, 7, 8); 
    addEdge(adj, 1, 2, 8); 
    addEdge(adj, 1, 7, 11); 
    addEdge(adj, 2, 3, 7); 
    addEdge(adj, 2, 8, 2); 
    addEdge(adj, 2, 5, 4); 
    addEdge(adj, 3, 4, 9); 
    addEdge(adj, 3, 5, 14); 
    addEdge(adj, 4, 5, 10); 
    addEdge(adj, 5, 6, 2); 
    addEdge(adj, 6, 7, 1); 
    addEdge(adj, 6, 8, 6); 
    addEdge(adj, 7, 8, 7); 
    dist = dijkstraAdjList(9,1,adj)
    for i in 0:8
        print("$i $(dist[i+1])\n")
    end
end

test()