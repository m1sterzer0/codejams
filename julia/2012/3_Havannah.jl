
################################################################
## BEGIN UnionFind
################################################################

struct UnionFind{T}
    parent::Dict{T,T}
    size::Dict{T,Int64}
    special::Dict{T,Int64}
    UnionFind{T}() where {T} = new{T}(Dict{T,T}(),Dict{T,Int64}(),Dict{T,Int64}())
    function UnionFind{T}(xs::AbstractVector{T}) where {T}
        myparent = Dict{T,T}()
        mysize = Dict{T,Int64}()
        for x in xs; myparent[x] = x; mysize[x] = 1; end
        new{T}(myparent,mysize)
    end
end

function Base.push!(h::UnionFind,x,y) 
    ## Assume that we don't push elements on that are already in the set
    if haskey(h.parent,x); error("ERROR: Trying to push an element into UnionFind that is already present"); end
    h.parent[x]=x
    h.size[x] = 1
    h.special[x] = y
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
        h.special[a] |= h.special[b]
    end
end

function getspecial(h::UnionFind,x)::Int64
    a = findset(h,x)
    return h.special[a]
end

################################################################
## END UnionFind
################################################################

function classify(S::Int64,x::Int64,y::Int64)::Int64
    ts = 2S-1
    ans = (x,y) == (1,1)   ? 1 : (x,y) == (S,1)  ? 2 : (x,y) == (ts,S) ? 3 :
          (x,y) == (ts,ts) ? 4 : (x,y) == (S,ts) ? 5 : (x,y) == (1,S)  ? 6 :
          y == 1 ? 7 : x-y == S-1 ? 8 : x == ts ? 9 :
          y == ts ? 10 : y-x == S-1 ? 11 : x == 1 ? 12 : 13
    return ans
end

function doit(S::Int64,M::Int64,MM::Vector{Tuple{Int64,Int64}})::Tuple{Int64,Int64,Int64}
    forkmasks = []
    bridgemasks = []
    for x in 1:5; for y in x+1:6; push!(bridgemasks, (1 << x) | (1 << y)); end; end
    for x in 7:10; for y in x+1:11; for z in y+1:12; push!(forkmasks, (1<<x) | (1<<y) | (1<<z)); end; end; end
    ringpats = [ (1,(2,),3,(4,5,6)), (1,(2,3),4,(5,6)), (1,(2,3,4),5,(6,)),
                 (2,(3,),4,(5,6,1)), (2,(3,4),5,(6,1)), (2,(3,4,5),6,(1,)),
                 (3,(4,),5,(6,1,2)), (3,(4,5),6,(1,2)), (4,(5,),6,(1,2,3))]
    uf = UnionFind{Tuple{Int64,Int64}}()
    sb = Set{Tuple{Int64,Int64}}()
    neighbors = Vector{Tuple{Int64,Int64}}()
    tsm1 = 2S-1
    k1 = k2 = k3 = M+1
    for (i,(x,y)) in enumerate(MM)
        tt = classify(S,x,y)
        special = tt == 13 ? 0 : 1 << tt
        push!(sb,(x,y))
        push!(uf,(x,y),special)

        empty!(neighbors)
        for (dx,dy) in ((1,1),(0,1),(-1,0),(-1,-1),(0,-1),(1,0))
            x2,y2 = (x+dx),(y+dy)
            if x2 < 1 || x2 > tsm1 || y2 < 1 || y2 > tsm1 || y2-x2 > S-1 || x2-y2 > S-1
                push!(neighbors,(-1,-1))
            elseif (x2,y2) ∉ sb
                push!(neighbors,(-1,-1))
            else
                push!(neighbors,findset(uf,(x2,y2)))
            end
        end

        for (a,b,c,d) in ringpats
            if neighbors[a][1] == -1; continue; end
            if neighbors[c][1] == -1; continue; end
            if neighbors[a] != neighbors[c]; continue; end
            cond1 = false; for bb in b; if neighbors[a] != neighbors[bb]; cond1 = true; end; end
            if !cond1; continue; end
            cond2 = false; for dd in d; if neighbors[a] != neighbors[dd]; cond2 = true; end; end
            if !cond2; continue; end
            k3 = i
        end

        for (x2,y2) in neighbors; if x2 > 0; joinset(uf,(x,y),(x2,y2)); end; end
        sp = getspecial(uf,(x,y))
        for m in bridgemasks; if m & sp == m; k1 = i; end; end
        for m in forkmasks;   if m & sp == m; k2 = i; end; end
        if k1 <= M || k2 <= M || k3 <= M; break; end
    end
    return (k1,k2,k3)
end     

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S,M = gis()
        MM::Vector{Tuple{Int64,Int64}} = []
        for i in 1:M; x1,x2 = gis(); push!(MM,(x1,x2)); end
        (k1,k2,k3) = doit(S,M,MM)
        ans = ""
        if min(k1,k2,k3) > M; ans = "none"
        elseif k1 < k2 && k1 < k3; ans = "bridge in move $k1"
        elseif k2 < k1 && k2 < k3; ans = "fork in move $k2"
        elseif k3 < k1 && k3 < k2; ans = "ring in move $k3"
        elseif k1 == k2 && k1 < k3; ans = "bridge-fork in move $k1"
        elseif k1 == k3 && k1 < k2; ans = "bridge-ring in move $k1"
        elseif k2 == k3 && k2 < k1; ans = "fork-ring in move $k2"
        else;                       ans = "bridge-fork-ring in move $k1"
        end

        print("$ans\n")
    end
end
main()
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

