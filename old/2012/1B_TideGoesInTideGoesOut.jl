######################################################################################################
### BEGIN DIJKSTRA CODE (ADJ LIST)
######################################################################################################
struct MinHeapDijkstraNode
    n::Int64    ##Node ID
    t::Int64  ##Time
end
Base.isless(a::MinHeapDijkstraNode,b::MinHeapDijkstraNode) = a.t < b.t

struct MinHeapDijkstra
    valtree::Vector{MinHeapDijkstraNode}
    pos::Vector{Int64}
    MinHeapDijkstra(N::Int64) = new([],fill(0,N))
end

function _swap(h::MinHeapDijkstra,i::Int64,j::Int64)
    (n1::Int64,n2::Int64) = (h.valtree[i].n,h.valtree[j].n)
    h.pos[n2],h.pos[n1] = i,j
    h.valtree[i],h.valtree[j] = h.valtree[j],h.valtree[i]
end

function _bubbleUp(h::MinHeapDijkstra, i::Int64)
    if i == 1; return; end
    j::Int64 = i >> 1
    if h.valtree[i] < h.valtree[j]
        _swap(h,i,j)
        _bubbleUp(h,j)
    end
end

function _bubbleDown(h::MinHeapDijkstra,i::Int64)
    len::Int64 = length(h.valtree)
    l::Int64 = i << 1; r::Int64 = l + 1
    res1::Bool = l > len || h.valtree[i] <= h.valtree[l]
    res2::Bool = r > len || h.valtree[i] <= h.valtree[r]
    if res1 && res2; return;
    elseif res2 || !res1 && h.valtree[l] <= h.valtree[r]
        _swap(h,i,l)
        _bubbleDown(h,l)
    else
        _swap(h,i,r)
        _bubbleDown(h,r)
    end
end

function Base.push!(h::MinHeapDijkstra,node::MinHeapDijkstraNode)
    n = node.n
    idx::Int64 = h.pos[n]
    if idx == 0 
        push!(h.valtree,node)
        idx = length(h.valtree)
        h.pos[n] = idx
    elseif h.valtree[idx] > node
        h.valtree[idx] = node
    end
    _bubbleUp(h,idx)
end

function Base.pop!(h::MinHeapDijkstra)
    ans::MinHeapDijkstraNode = h.valtree[1]
    h.pos[ans.n] = 0
    node2::MinHeapDijkstraNode = pop!(h.valtree)
    if length(h.valtree) >= 1
        h.pos[node2.n] = 1
        h.valtree[1] = node2
        _bubbleDown(h,1)
    end
    return ans
end

Base.isempty(h::MinHeapDijkstra) = isempty(h.valtree)

#function dijkstraAdjList(N::Int64,src::Int64,adj::Vector{Vector{Tuple{Int64,Int64}}})::Vector{Int64}
#    myinf = 1e99
#    dist = fill(myinf,N)
#    minheap = MinHeapDijkstra(N)
#    push!(minheap,MinHeapDijkstraNode(src,0.00))
#    while !isempty(minheap) 
#        node = pop!(minheap)
#        dist[node.n] = node.v
#        for (n2,v2) in adj[node.n]
#            if dist[n2] == myinf; push!(minheap,MinHeapDijkstraNode(n2,node.v+v2)); end
#        end
#    end
#    return dist
#end

######################################################################################################
### END DIJKSTRA CODE (ADJ LIST)
######################################################################################################

## Solve in tenths of seconds to avoid floating point issues

function myDijkstra(H::Int64,N::Int64,M::Int64,CC::Array{Int64,2},FF::Array{Int64,2})::Vector{Int64}
    myinf = 1_000_000_000_000_000_000
    dist = fill(myinf,N*M)
    mh = MinHeapDijkstra(N*M)
    push!(mh,MinHeapDijkstraNode(1,0))
    nodestoeval::Vector{Tuple{Int64,Int64}} = []
    while !isempty(mh)
        node = pop!(mh)
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
            c1,f1,c2,f2 = CC[j,i],FF[j,i],CC[j2,i2],FF[j2,i2]
            ## Case 1 -- can I move there for free at the dawn of time
            if (node.t == 0 && max(H,f1,f2) <= c2-50 && f2 <= c1-50)
                push!(mh,MinHeapDijkstraNode(nodeid2,0))
            elseif max(f1,f2) <= c2-50 && f2 <= c1-50
                hneeded = c2-50
                tstart = max(node.t,H-hneeded)
                hstart = H-tstart
                newv = tstart + ((hstart-f1 >= 20) ? 10 : 100)
                push!(mh,MinHeapDijkstraNode(nodeid2,newv))
            end
        end
    end
    return dist
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        H,N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        CC = fill(0,N,M)
        FF = fill(0,N,M)
        for i in 1:N
            CC[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        for i in 1:N
            FF[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ans = myDijkstra(H,N,M,CC,FF)
        print("$(0.1*ans[M*N])\n")
    end
end

main()

