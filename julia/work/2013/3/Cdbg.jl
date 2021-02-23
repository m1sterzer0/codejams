using Random
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
        (n2,v2) = h.valtree[r]
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

function gencase(n,m,umin,umax,vmin,vmax)
    innernodes = collect(3:n)
    shuffle!(innernodes)
    keepchance = 0.10 + rand() * (0.50-0.10)
    pathorder = [1]
    for s in innernodes; if rand() < keepchance; push!(pathorder,s); end; end
    push!(pathorder,2)
    edges = []
    for i in 2:length(pathorder)
        n1,n2 = pathorder[i-1],pathorder[i]
        u = rand(umin:umax)
        v = rand(vmin:vmax)
        if u>v; (u,v) = (v,u); end
        push!(edges,(i-1,n1,n2,u,v))
    end
    le = length(edges)
    for i in le+1:m
        n1 = rand(1:n)
        n2 = rand(1:n)
        u = rand(umin:umax)
        v = rand(vmin:vmax)
        push!(edges,(0,n1,n2,u,v))
    end
    shuffle!(edges)
    PP::Vector{Int64} = []
    for i in 1:length(pathorder)-1
        for j in 1:m
            if edges[j][1] == i; push!(PP,j); break; end
        end
    end
    MM = fill(0,m,4)
    for i in 1:m
        MM[i,:] = [edges[i][2],edges[i][3],edges[i][4],edges[i][5]]
    end
    return (n,m,length(PP),MM,PP)
end

function regress()
    Random.seed!(8675309)
    for i in 1:1000
        print("Case $i: ")
        (N,M,P,MM,PP) = gencase(rand(5:20),rand(10:20),1,30,20,100)
        ans = solve(N,M,P,MM,PP)
        print("$ans\n")
    end
end

function solve(N::Int64,M::Int64,P::Int64,MM::Array{Int64,2},PP::Vector{Int64})
    edgeDict::Dict{Tuple{Int64,Int64},Tuple{Int64,Int64}} = Dict{Tuple{Int64,Int64},Tuple{Int64,Int64}}()
    for i in 1:M
        a,b,u,v = [MM[i,j] for j in 1:4]
        if !haskey(edgeDict,(a,b)); edgeDict[(a,b)] = (u,v)
        else
            (u1,v1) = edgeDict[(a,b)]
            edgeDict[(a,b)] = (min(u,u1),min(v,v1))
        end
    end

    adj::Vector{Vector{Tuple{Int64,Int64,Int64}}} = [Vector{Tuple{Int64,Int64,Int64}}() for i in 1:N]
    for ((a,b),(u,v)) in edgeDict; if a != b; push!(adj[a],(b,u,v)); end; end
    pathEdges::Dict{Tuple{Int64,Int64},Int64} = Dict{Tuple{Int64,Int64},Int64}()
    running = 0
    dist = fill(0,N)
    myinf = 1_000_000_000_000_000_000
    minheap = MinHeapDijkstra(N)
    good = true
    for i in PP
        a,b,u,v = [MM[i,j] for j in 1:4]
        if !haskey(pathEdges,(a,b)); pathEdges[(a,b)] = u; end
        pathEdges[(a,b)] = min(u,pathEdges[(a,b)])
        running += u
        fill!(dist,myinf)
        push!(minheap,1,1)
        push!(minheap,b,2*running)
        while !isempty(minheap) 
            (n,v) = pop!(minheap)
            dist[n] = v
            if v % 2 == 0  ##On the best case of the suggested path
                for (n2,u2,v2) in adj[n]
                    if dist[n2] == myinf; push!(minheap,n2,v+2*u2); end
                end
            else
                for (n2,u2,v2) in adj[n]
                    if haskey(pathEdges,(n,n2)); v2 = min(v2,pathEdges[(n,n2)]); end
                    if dist[n2] == myinf; push!(minheap,n2,v+2*v2); end
                end
            end
        end
        if dist[2] % 2 == 1; return "$i"; end
    end
    return "Looks Good To Me"
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        MM::Array{Int64,2} = fill(0,M,4)
        for i in 1:M
            MM[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        PP = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        ansstr = solve(N,M,P,MM,PP)
        print("$ansstr\n")
    end
end

#regress()
main()
            
