
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

######################################################################################################
### END DIJKSTRA CODE (ADJ LIST)
######################################################################################################

function solve(N::I,M::I,P::I,MM::Array{I,2},PP::VI)::String
    edgeDict::Dict{PI,PI} = Dict{PI,PI}()
    for i in 1:M
        a,b,u,v = MM[i,:]
        if !haskey(edgeDict,(a,b))
            edgeDict[(a,b)] = (u,v)
        else
            (u1,v1) = edgeDict[(a,b)]
            edgeDict[(a,b)] = (min(u,u1),min(v,v1))
        end
    end

    adj::Vector{Vector{TI}} = [Vector{TI}() for i in 1:N]
    for ((a,b),(u,v)) in edgeDict; if a != b; push!(adj[a],(b,u,v)); end; end
    pathEdges::Dict{PI,I} = Dict{PI,I}()
    running = 0; dist::VI = fill(0,N); myinf::I = 10^18; minheap = MinHeapDijkstra(N); good = true
    for i in PP
        a,b,u,v = MM[i,:]
        if !haskey(pathEdges,(a,b)); pathEdges[(a,b)] = u; end
        pathEdges[(a,b)] = min(u,pathEdges[(a,b)])
        running += u
        fill!(dist,myinf)
        push!(minheap,MinHeapDijkstraNode(1,1))
        push!(minheap,MinHeapDijkstraNode(b,2*running))
        while !isempty(minheap)
            mhn = pop!(minheap)
            (n,v) = (mhn.n,mhn.t)
            dist[n] = v
            if v % 2 == 0  ##On the best case of the suggested path
                for (n2,u2,v2) in adj[n]
                    if dist[n2] == myinf; push!(minheap,MinHeapDijkstraNode(n2,v+2*u2)); end
                end
            else
                for (n2,u2,v2) in adj[n]
                    if haskey(pathEdges,(n,n2)); v2 = min(v2,pathEdges[(n,n2)]); end
                    if dist[n2] == myinf; push!(minheap,MinHeapDijkstraNode(n2,v+2*v2)); end
                end
            end
        end
        if dist[2] % 2 == 1; return "$i"; end
    end
    return "Looks Good To Me"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M,P = gis()
        MM::Array{I,2} = fill(0,M,4)
        for i in 1:M; MM[i,:] = gis(); end
        PP::VI = gis()
        ans = solve(N,M,P,MM,PP)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

