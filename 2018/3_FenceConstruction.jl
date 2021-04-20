
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
## Key observation is to build the fences backwards
## Main Idea
## * First build the dual graph
## * For each possible starting cell
##   * for each fence in the reverse K order
##     -- bust down as many fences as possible without touching the fixed order ones.
##     -- see if we can bust down the target fence, if not, fail
##   * bust down all of the remaining fences
##    
######################################################################################################


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



function solve(F::I,K::I,A::VI,B::VI,C::VI,D::VI)::String
    ## Data structures
    ##------------------------------------------------------------------------------------
    ## PP maps a pointId to a point
    ## PPP maps a point to a pointId
    ## FF maps fenceId to a pair of pointIds 
    ## FFF maps a pair of poindIds to a fenceId
    ## KK has the list of special fences
    ## adj contains the graph between point ids
    ## regionSb is a scoreboard for the accessible regions
    ## fenceSb is a scoreboard for the fences
    ## specialEdges maps fenceIds to bool to indicate if they are in the special list
    ## q = list of regionIds left to traverse
    ## ans = the final answer list
    ## regRight maps an ordered pair of pointIds to the regionId on the right of that edge
    ## regEdges maps regionIds to a list of bordering fenceIds
    FF::VPI = []
    PP::VPI = []
    FFF::Dict{PI,I} = Dict{PI,I}()
    PPP::Dict{PI,I} = Dict{PI,I}()
    pcnt::I = 0
    for i::I in 1:F
        a::I,b::I,c::I,d::I = A[i],B[i],C[i],D[i]
        if !haskey(PPP,(a,b)); pcnt += 1; PPP[(a,b)] = pcnt; push!(PP,(a,b)); end
        if !haskey(PPP,(c,d)); pcnt += 1; PPP[(c,d)] = pcnt; push!(PP,(c,d)); end
        pid1,pid2 = PPP[(a,b)],PPP[(c,d)]
        push!(FF,(pid1,pid2))
        FFF[(pid1,pid2)] = i
        FFF[(pid2,pid1)] = i
    end
    KK::VI = collect(1:K)
    regionSb::VB = fill(false,2F)
    fenceSb::VB = fill(false,F)
    specialEdges::VB = fill(false,F)
    for k in KK; specialEdges[k] = true; end
    q::VI = []
    ans::VI = []
    regRight::Array{I,2} = fill(0,pcnt,pcnt)
    regEdges::Vector{SI} = [SI() for i in 1:2*F]
    adj::Vector{SI} = [SI() for i in 1:pcnt]
    for (a,b) in FF; push!(adj[a],b); push!(adj[b],a); end

    function sortccw!(psort::VI,pid::I)
        (xoff,yoff) = PP[pid]
        function mylt(a::I,b::I)
            ax,ay = PP[a][1]-xoff,PP[a][2]-yoff
            bx,by = PP[b][1]-xoff,PP[b][2]-yoff
            q1 = ay >= 0 ? (ax >= 0 ? 1 : 2) : (ax >= 0 ? 4 : 3)
            q2 = by >= 0 ? (bx >= 0 ? 1 : 2) : (bx >= 0 ? 4 : 3)
            return q1 != q2 ? q1 < q2 : ax*by-bx*ay > 0;
        end
        sort!(psort,lt=mylt)
    end

    function buildDualStructures()
        P = length(PP)
        uf::UnionFind{I} = UnionFind{I}(collect(1:2F))
        for i in 1:F
            (p1,p2) = FF[i]
            regRight[p1,p2] = i
            regRight[p2,p1] = F+i
        end
        for i in 1:P
            np = length(adj[i])
            psort = [x for x in adj[i]]
            sortccw!(psort,i)
            for j in 1:np
                p1,p2 = psort[j],(j==np ? psort[1] : psort[j+1])
                rid1,rid2 = regRight[p1,i],regRight[i,p2]
                joinset(uf,rid1,rid2)
            end
        end
        for i in 1:F
            (p1,p2) = FF[i]
            rid1 = findset(uf,regRight[p1,p2]); regRight[p1,p2] = rid1
            rid2 = findset(uf,regRight[p2,p1]); regRight[p2,p1] = rid2
            push!(regEdges[rid1],i)
            if rid2 != rid1; push!(regEdges[rid2],i); end
        end
    end
    function processEdge(e::Int64)
        if fenceSb[e] || specialEdges[e]; return; end
        push!(ans,e)
        fenceSb[e] = true
        (p1,p2) = FF[e]
        r1,r2 = regRight[p1,p2],regRight[p2,p1]
        if !regionSb[r1]; regionSb[r1] = true; push!(q,r1); end
        if !regionSb[r2]; regionSb[r2] = true; push!(q,r2); end
    end

    function processQueue()
        while !isempty(q)
            r = pop!(q)
            for e in regEdges[r]
                processEdge(e)
            end
        end
    end

    function doFinalTraversal()
        KKrev = reverse(KK)
        (p1,p2) = FF[KKrev[1]]
        rid = regRight[p1,p2]
        regionSb[rid] = true
        specialEdges = fill(false,F)
        for k in KK; specialEdges[k] = true; end
        q = [rid]
        ans = []
        for k in KKrev
            processQueue()
            specialEdges[k] = false
            processEdge(k)
        end
        processQueue()
        reverse!(ans)
    end

    buildDualStructures()
    doFinalTraversal()
    return join(ans," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        F,K = gis()
        A::VI = fill(0,F)
        B::VI = fill(0,F)
        C::VI = fill(0,F)
        D::VI = fill(0,F)
        for i in 1:F; A[i],B[i],C[i],D[i] = gis(); end
        ans = solve(F,K,A,B,C,D)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

