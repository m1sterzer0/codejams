
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

################################################################
## BEGIN UnionFind
################################################################

struct UnionFind{T}
    parent::Dict{T,T}
    size::Dict{T,Int64}
    special::Dict{T,Int64} ## Replace this with the "special sauce" for your problem
    UnionFind{T}() where {T} = new{T}(Dict{T,T}(),Dict{T,Int64}(),Dict{T,Int64}())
end

function Base.push!(h::UnionFind,x,y) 
    if haskey(h.parent,x); error("ERROR: Trying to push an element into UnionFind that is already present"); end
    h.parent[x]=x; h.size[x] = 1; h.special[x] = y
end

function findset(h::UnionFind,x) 
    if h.parent[x] == x; return x; end
    return h.parent[x] = findset(h,h.parent[x])
end

function joinset(h::UnionFind,x,y)
    a = findset(h,x); b = findset(h,y)
    if a != b
        (a,b) = h.size[a] < h.size[b] ? (b,a) : (a,b)
        h.parent[b] = a; h.size[a] += h.size[b]
        h.special[a] |= h.special[b]  ## Special Sauce
    end
end

function getsize(h::UnionFind,x)::Int64
    a = findset(h,x); return h.size[a]
end

function getspecial(h::UnionFind,x)::Int64
    a = findset(h,x); return h.special[a]
end

################################################################
## END UnionFind
################################################################





## Board is bounded by following conditions
## * All coordinates between 1 and 2S-1
## * abs(x-y) limited to S-1

function findBridge(S::I,M::I,X::VI,Y::VI)
    uf::UnionFind{PI} = UnionFind{PI}()
    pts::Set{PI}      = Set{PI}()
    inf = 1_000_000_000_000_000_000
    badsp = (0,1,2,4,8,16,32)
    for i in 1:M
        x=X[i]; y=Y[i]
        sp::I = (x,y) == (1,1)       ? 1 : (x,y) == (S,1)    ?  2 : (x,y) == (2S-1,S) ? 4 :
                (x,y) == (2S-1,2S-1) ? 8 : (x,y) == (S,2S-1) ? 16 : (x,y) == (1,S)    ? 32 : 0
        push!(uf,(x,y),sp); push!(pts,(x,y))
        for (dx,dy) in ((-1,-1),(0,-1),(1,0),(1,1),(0,1),(-1,0))
            x2 = x+dx; y2 = y+dy
            if min(x2,y2) < 1 || max(x2,y2) > 2S-1 || abs(x2-y2) >= S; continue; end
            if (x2,y2) ∉ pts; continue; end
            joinset(uf,(x,y),(x2,y2))
        end
        nsp = getspecial(uf,(x,y))
        if nsp in badsp; continue; end
        return i
    end
    return inf
end

function findFork(S::I,M::I,X::VI,Y::VI)
    uf::UnionFind{PI} = UnionFind{PI}()
    pts::Set{PI}      = Set{PI}()
    inf = 1_000_000_000_000_000_000

    badsp::VI = [0]
    for i in (1,2,4,8,16,32)
        push!(badsp,i)
        for j in (1,2,4,8,16,32)
            if j <= i; continue; end
            push!(badsp,i+j)
        end
    end
    corners::VPI = [(1,1),(S,1),(1,S),(2S-1,S),(S,2S-1),(2S-1,2S-1)]

    for i in 1:M
        x=X[i]; y=Y[i]
        sp::I = (x,y) in corners ? 0 : x-y == S-1 ? 1 : y-x == S-1 ? 2 : x == 1 ? 4 : 
                          y == 1 ? 8 :  x==2S-1 ? 16 : y==2S-1 ? 32 : 0
        push!(uf,(x,y),sp); push!(pts,(x,y))
        for (dx,dy) in ((-1,-1),(0,-1),(1,0),(1,1),(0,1),(-1,0))
            x2 = x+dx; y2 = y+dy
            if min(x2,y2) < 1 || max(x2,y2) > 2S-1 || abs(x2-y2) >= S; continue; end
            if (x2,y2) ∉ pts; continue; end
            joinset(uf,(x,y),(x2,y2))
        end
        nsp = getspecial(uf,(x,y))
        if nsp in badsp; continue; end
        return i
    end
    return inf
end

function findRingSmall(S::I,M::I,X::VI,Y::VI)
    ## Here we build the end state board and look for >= two disjoint
    ## sets (or potentially a ring around the whole board, but that
    ## case doesn't matter since we would deterministically encouter
    ## one of the other conditions first).  We join all of the remaining edge
    ## pieces to a "virtual node" to avoid the finding a "ring" when you
    ## merely divide the board up with a line.  We then add empty squares
    ## 1 by 1, joining regions and joining as appropriate.  We keep track of
    ## the last time where we had 2 or more regions.

    uf::UnionFind{PI} = UnionFind{PI}()
    pts::Set{PI}      = Set{PI}()
    res = 1_000_000_000_000_000_000
    last = (2S,2S)
    totadded = 1
    push!(uf,(2S,2S),0)  ## Special external node for edges
    for i in 1:M; push!(pts,(X[i],Y[i])); end

    ## Build up the board
    for i in 1:2S-1; for j in 1:2S-1
        if abs(i-j) >= S; continue; end
        if (i,j) in pts; continue; end
        push!(uf,(i,j),0); last = (i,j); totadded += 1
    end; end

    ## Join up the spaces to their neighbors
    for i in 1:2S-1; for j in 1:2S-1
        if abs(i-j) >= S; continue; end
        if (i,j) in pts; continue; end
        for (dx,dy) in ((-1,-1),(0,-1),(1,0),(1,1),(0,1),(-1,0))
            x2 = i+dx; y2 = j+dy
            if min(x2,y2) < 1 || max(x2,y2) > 2S-1 || abs(x2-y2) >= S; continue; end
            if (x2,y2) ∈ pts; continue; end
            joinset(uf,(i,j),(x2,y2))
        end
        if min(i,j) == 1 || max(i,j) == 2S-1 || abs(i-j) == S-1; joinset(uf,(2S,2S),(i,j)); end
    end; end

    ## Loop through the points in reverse order  
    for i in M:-1:1
        if getsize(uf,last) != totadded; res = i; end
        (x,y) = (X[i],Y[i])
        delete!(pts,(x,y))
        push!(uf,(x,y),0); totadded += 1
        for (dx,dy) in ((-1,-1),(0,-1),(1,0),(1,1),(0,1),(-1,0))
            x2 = x+dx; y2 = y+dy
            if min(x2,y2) < 1 || max(x2,y2) > 2S-1 || abs(x2-y2) >= S; continue; end
            if (x2,y2) ∈ pts; continue; end
            joinset(uf,(x,y),(x2,y2))
        end
        if min(x,y) == 1 || max(x,y) == 2S-1 || abs(x-y) == S-1; joinset(uf,(2S,2S),(x,y)); end
    end
    return res
end

## For the large, we notice that the key to completeing a ring is
## placing a cell that joins 2 cells from the same union-find set with
## an empty cell on each side of the connection.  

function findRingLarge(S::I,M::I,X::VI,Y::VI)
    ringpats = [ (1,(2,),3,(4,5,6)), (1,(2,3),4,(5,6)), (1,(2,3,4),5,(6,)),
                 (2,(3,),4,(5,6,1)), (2,(3,4),5,(6,1)), (2,(3,4,5),6,(1,)),
                 (3,(4,),5,(6,1,2)), (3,(4,5),6,(1,2)), (4,(5,),6,(1,2,3))]

    uf::UnionFind{PI} = UnionFind{PI}()
    pts::Set{PI}      = Set{PI}()
    inf = 1_000_000_000_000_000_000
    neighbors::VPI = []
    for i in 1:M
        x = X[i]; y = Y[i]
        push!(uf,(x,y),0); push!(pts,(x,y))
        empty!(neighbors)
        for (dx,dy) in ((1,1),(0,1),(-1,0),(-1,-1),(0,-1),(1,0))
            x2,y2 = (x+dx),(y+dy)
            if min(x2,y2) < 1 || max(x2,y2) > 2S-1 || abs(x2-y2) >= S; push!(neighbors,(-1,-1))
            elseif (x2,y2) ∉ pts; push!(neighbors,(-1,-1))
            else; push!(neighbors,findset(uf,(x2,y2)))
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
            return i
        end
         
        for (x2,y2) in neighbors; if x2 > 0; joinset(uf,(x,y),(x2,y2)); end; end
    end
    return inf      
end

function solveSmall(S::I,M::I,X::VI,Y::VI)
    inf = 1_000_000_000_000_000_000
    x1 = findBridge(S,M,X,Y)
    x2 = findFork(S,M,X,Y)
    x3 = findRingSmall(S,M,X,Y)
    k = min(x1,x2,x3)
    res = (k == inf)  ? "none"        : (x1==x2==x3) ? "bridge-fork-ring" : 
          (k==x1==x2) ? "bridge-fork" : (k==x1==x3)  ? "bridge-ring" :
          (k==x2==x3) ? "fork-ring"   : (k==x1)      ? "bridge" :
          (k==x2)     ? "fork"        :                "ring"
    return (res,k)
end

function solveLarge(S::I,M::I,X::VI,Y::VI)
    inf = 1_000_000_000_000_000_000
    x1 = findBridge(S,M,X,Y)
    x2 = findFork(S,M,X,Y)
    x3 = findRingLarge(S,M,X,Y)
    k = min(x1,x2,x3)
    res = (k == inf)  ? "none"        : (x1==x2==x3) ? "bridge-fork-ring" : 
          (k==x1==x2) ? "bridge-fork" : (k==x1==x3)  ? "bridge-ring" :
          (k==x2==x3) ? "fork-ring"   : (k==x1)      ? "bridge" :
          (k==x2)     ? "fork"        :                "ring"
    return (res,k)
end


function gencase(Smin::I,Smax::I,Mmin::I,Mmax::I)
    S = rand(Smin:Smax)
    M = rand(Mmin:Mmax)
    moves::VPI = []
    for i in 1:2S-1
        for j in 1:2S-1
            if abs(i-j) >= S; continue end
            push!(moves, (i,j))
        end
    end
    shuffle!(moves)
    M = min(M,length(moves))
    X::VI = []; Y::VI = []
    for i in 1:M; push!(X,moves[i][1]); push!(Y,moves[i][2]); end
    return (S,M,X,Y)
end

function test(ntc::I,Smin::I,Smax::I,Mmin::I,Mmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (S,M,X,Y) = gencase(Smin,Smax,Mmin,Mmax)
        ans2 = solveLarge(S,M,X,Y)
        if check
            ans1 = solveSmall(S,M,X,Y)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(S,M,X,Y)
                ans2 = solveLarge(S,M,X,Y)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S::I,M::I = gis()
        X::VI = fill(0,M)
        Y::VI = fill(0,M)
        for i in 1:M; X[i],Y[i] = gis(); end
        #ans = solveSmall(S,M,X,Y)
        ans = solveLarge(S,M,X,Y)
        if ans[1]  == "none"; print("none\n"); else; print("$(ans[1]) in move $(ans[2])\n"); end
    end
end

Random.seed!(8675309)
main()
#test(1,2,50,0,100)
#test(10,2,50,0,100)
#test(100,2,50,0,100)
#for i in 1:10
#    print("Iteration $i: ")
#    test(1000,2,50,0,100)
#end
#test(100,2500,3000,0,10000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,2,50,0,100)
#Profile.clear()
#@profilehtml test(10,2500,3000,0,10000,false)

