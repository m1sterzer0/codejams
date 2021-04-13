using Random
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

######################################################################################################
### BEGIN DIJKSTRA CODE (ADJ LIST)
######################################################################################################
struct MinHeapDijkstraNode; n::I; t::I; end ## n is nodeID, t is time (or dist)
Base.isless(a::MinHeapDijkstraNode,b::MinHeapDijkstraNode) = a.t < b.t

struct MinHeapDijkstra
    valtree::Vector{MinHeapDijkstraNode}; pos::VI
    MinHeapDijkstra(N::I) = new([],fill(0,N))
end

function _swap(h::MinHeapDijkstra,i::I,j::I)
    (n1::I,n2::I) = (h.valtree[i].n,h.valtree[j].n)
    h.pos[n2],h.pos[n1] = i,j
    h.valtree[i],h.valtree[j] = h.valtree[j],h.valtree[i]
end

function _bubbleUp(h::MinHeapDijkstra, i::I)
    if i == 1; return; end
    j::I = i >> 1; if h.valtree[i] < h.valtree[j]; _swap(h,i,j); _bubbleUp(h,j); end
end

function _bubbleDown(h::MinHeapDijkstra,i::I)
    len::I = length(h.valtree); l::I = i << 1; r::I = l + 1
    res1::Bool = l > len || !(h.valtree[i] > h.valtree[l])
    res2::Bool = r > len || !(h.valtree[i] > h.valtree[r])
    if res1 && res2; return
    elseif res2 || !res1 && !(h.valtree[l] > h.valtree[r]); _swap(h,i,l); _bubbleDown(h,l)
    else; _swap(h,i,r); _bubbleDown(h,r)
    end
end

function Base.push!(h::MinHeapDijkstra,node::MinHeapDijkstraNode)
    n::I = node.n; idx::I = h.pos[n]
    if idx == 0; push!(h.valtree,node); idx = length(h.valtree); h.pos[n] = idx
    elseif h.valtree[idx] > node; h.valtree[idx] = node
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MinHeapDijkstra)
    ans::MinHeapDijkstraNode = h.valtree[1]; h.pos[ans.n] = 0
    node2::MinHeapDijkstraNode = pop!(h.valtree)
    if length(h.valtree) >= 1; h.pos[node2.n] = 1; h.valtree[1] = node2; _bubbleDown(h,1); end
    return ans
end

Base.isempty(h::MinHeapDijkstra) = isempty(h.valtree)

function dijkstraAdjList(N::I,src::I,adj::Vector{VPI})::VI
    myinf::I = 1_000_000_000_000_000_000; dist::VI = fill(myinf,N)
    minheap::MinHeapDijkstra = MinHeapDijkstra(N); push!(minheap,MinHeapDijkstraNode(src,0))
    while !isempty(minheap) 
        node = pop!(minheap); dist[node.n] = node.v
        for (n2,v2) in adj[node.n]
            if dist[n2] == myinf; push!(minheap,MinHeapDijkstraNode(n2,node.v+v2)); end
        end
    end
    return dist
end

######################################################################################################
### END DIJKSTRA CODE (ADJ LIST)
######################################################################################################


## Adapted/translated from cp-algorithms -- this version is O(n^2) and assumes distances in an adj matrix
function denseDijkstra(s::I,d::VI,p::VI,adjm::Array{I,2})
    n = length(d)
    inf::I = 1000000006
    fill!(d,inf)
    fill!(p,-1)
    u::VB = fill(false,n)
    d[s] = 0
    for i in 1:n
        v::I = -1
        for j in 1:n
            if (!u[j] && (v==-1 || d[j] < d[v])); v = j; end
        end
        if d[v] == inf; break; end
        u[v] = true
        for j in 1:n
            if j == v; continue; end
            if d[j] > d[v] + adjm[v,j]
                d[j] = d[v] + adjm[v,j]
                p[j] = v
            end
        end
    end
end

