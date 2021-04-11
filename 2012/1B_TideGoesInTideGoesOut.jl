
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

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
    res1::Bool = l > len || h.valtree[i] <= h.valtree[l]
    res2::Bool = r > len || h.valtree[i] <= h.valtree[r]
    if res1 && res2; return
    elseif res2 || !res1 && h.valtree[l] <= h.valtree[r]; _swap(h,i,l); _bubbleDown(h,l)
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

######################################################################################################
### END DIJKSTRA CODE (ADJ LIST)
######################################################################################################

## Solve in tenths of a second to avoid floating point
function solve(H::I,N::I,M::I,CC::Array{Int64,2},FF::Array{Int64,2})::F
    myinf::I = 1_000_000_000_000_000_000
    dist::VI = fill(myinf,N*M)
    mh::MinHeapDijkstra = MinHeapDijkstra(N*M)
    push!(mh,MinHeapDijkstraNode(1,0))
    nodestoeval::VPI = []
    while !isempty(mh)
        node::MinHeapDijkstraNode = pop!(mh)
        dist[node.n] = node.t
        j = 1 + (node.n-1) ÷ M
        i = 1 + ((node.n-1) % M)
        empty!(nodestoeval)
        if i > 1; push!(nodestoeval,(j,i-1)); end
        if i < M; push!(nodestoeval,(j,i+1)); end
        if j > 1; push!(nodestoeval,(j-1,i)); end
        if j < N; push!(nodestoeval,(j+1,i)); end
        for (j2,i2) in nodestoeval
            nodeid2 = 1 + (i2-1) + M * (j2-1)
            if dist[nodeid2] < myinf; continue; end
            c1::I,f1::I,c2::I,f2::I = CC[j,i],FF[j,i],CC[j2,i2],FF[j2,i2]
            ## Case 1 -- can I move there for free at the dawn of time
            if (node.t == 0 && max(H,f1,f2) <= c2-50 && f2 <= c1-50)
                push!(mh,MinHeapDijkstraNode(nodeid2,0))
            ## Case 2 -- can I ever move there once the water goes down
            elseif max(f1,f2) <= c2-50 && f2 <= c1-50
                hneeded::I = c2-50
                tstart::I = max(node.t,H-hneeded)
                hstart::I = H-tstart
                newv::I = tstart + ((hstart-f1 >= 20) ? 10 : 100)
                push!(mh,MinHeapDijkstraNode(nodeid2,newv))
            end
        end
    end
    return 0.1*dist[M*N]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        H,N,M = gis()
        CC::Array{Int64,2} = fill(0,N,M)
        FF::Array{Int64,2} = fill(0,N,M)
        for i in 1:N; CC[i,:] = gis(); end
        for i in 1:N; FF[i,:] = gis(); end
        ans = solve(H,N,M,CC,FF)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
