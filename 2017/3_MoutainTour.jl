
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
### BEGIN UNION FIND
######################################################################################################

mutable struct UnionFind{T}
    parent::Dict{T,T}
    size::Dict{T,Int64}
    
    UnionFind{T}() where {T} = new{T}(Dict{T,T}(),Dict{T,Int64}())
    
    function UnionFind{T}(xs::AbstractVector{T}) where {T}
        myparent = Dict{T,T}()
        mysize = Dict{T,Int64}()
        for x in xs; myparent[xs] = xs; mysize[xs] = 1; end
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

######################################################################################################
### END UNION FIND
######################################################################################################

######################################################################################################
### For the small, the key observation is that each of the camps have two possibilities for the 
### order in which we take the camps, so we just try them all and report the best one.
######################################################################################################

function simulate(cfg,C,E,L,D)::I
    big::I = typemax(Int64)
    visits::VI = fill(0,C)
    d::I,h::I,c::I = 0,0,1
    for i::I in 1:2C
        if visits[c] >= 2; return big; end
        visits[c] += 1
        hidx::I = (2*c - 2) + ((1 << (c-1) & cfg == 0) ? visits[c] : 3 - visits[c])  ## maps adder to 1/2 or 2/1 depending on the config
        if L[hidx] < h; d += 1; end  ## Have to wait an extra day at the camp
        h = L[hidx] + D[hidx]
        d += h ÷ 24
        h = h % 24
        c = E[hidx]
    end
    return c == 1 ? 24*d + h : big
end

function solveSmall(C::I,E::VI,L::VI,D::VI)::I
    best::I = typemax(Int64)
    for i in 1:2^C
        res::I = simulate(i-1,C,E,L,D)
        best = min(best,res)
    end
    return best
end

######################################################################################################
### a) Note that all we are really trying to do is to minimize the "wait time" at the camps. 
### b) We also notice that the difference between any two assignments at a camp either "doesn't matter"
###    to the total time (assuming both result in a full loop) or there is exactly one day of difference
###    between them.
### c) We have 6 cases of the relative order of the arrivals and departures.
###    AADD -- no assignments wait an extra day
###    ADAD -- depending on our choice, we either wait 0 or 1 days
###    ADDA -- we always wait one extra day
###    DAAD -- we always wait one extra day
###    DADA -- depending on our choice, we either wait 1 or 2 days
###    DDAA -- we always wait two extra days
### d) This leads to the following algorithm
###    iterate through the 4 pairs of (camp 1 config, camp 1 start)
###      -- Greedily put all of the nodes into their cheapest configuration
###      -- Identify all of the nodes on a particular cycle.
###      -- Use the "free squares" (i.e. the ones where there are no cost implications of choosing a different
###         in -> out config) to join cycles.
###      -- Use the 1 day cost nodes for the rest of the joins. 
### e) The process here is actually quite tolerant of choice, as we will need n-1 joins to connect n disjoint
###    cycles.
######################################################################################################

function doInitialAssignment(C::I,E::VI,L::VI,D::VI,camp1config::Int64)::Tuple{VI,VB}
    graph::VI = fill(0,2C)
    free::VB = fill(false,C)
    ## Figure out which paths lead to a given camp
    pre::VVI = [VI() for i in 1:C]
    for i in 1:2C; push!(pre[E[i]],i); end

    graph[pre[1][1]] = camp1config == 0 ? 1 : 2
    graph[pre[1][2]] = camp1config == 0 ? 2 : 1

    for i in 2:C
        e1::I,e2::I = pre[i][1],pre[i][2]
        a1::I,a2::I = (L[e1]+D[e1]) % 24, (L[e2]+D[e2]) % 24
        d1::I,d2::I = L[2*i-1],L[2*i]

        ## Look for ADAD
        if     a1 <= d1 < a2 <= d2; graph[e1] = 2*i-1; graph[e2] = 2*i; 
        elseif a2 <= d1 < a1 <= d2; graph[e1] = 2*i;   graph[e2] = 2*i-1; 
        elseif a1 <= d2 < a2 <= d1; graph[e1] = 2*i;   graph[e2] = 2*i-1; 
        elseif a2 <= d2 < a1 <= d1; graph[e1] = 2*i-1; graph[e2] = 2*i; 
        
        ## Look for DADA
        elseif d1 < a1 <= d2 < a2; graph[e1] = 2*i;   graph[e2] = 2*i-1; 
        elseif d2 < a1 <= d1 < a2; graph[e1] = 2*i-1; graph[e2] = 2*i; 
        elseif d1 < a2 <= d2 < a1; graph[e1] = 2*i-1; graph[e2] = 2*i; 
        elseif d2 < a2 <= d1 < a1; graph[e1] = 2*i;   graph[e2] = 2*i-1; 

        else free[i] = true; graph[e1] = 2*i-1; graph[e2] = 2*i;
        end
    end
    return graph,free
end

function cycleHunt(C::I,graph::VI)::UnionFind{I}
    uf::UnionFind{I} = UnionFind{I}()
    for i in 1:2C; push!(uf,i); end
    visited::VB = fill(false,2C)
    for i in 1:2C
        if visited[i]; continue; end
        node::I = i
        while(true)
            node = graph[node]
            if node == i; break; end
            joinset(uf,i,node)
        end
    end
    return uf
end

function makeBigCycle(graph::VI,C::I,E::VI,uf::UnionFind{I},free::VB)
    prev::VI = fill(0,2C)
    for i in 1:2C; prev[graph[i]] = i; end
    for ff::Bool in [true,false]
        for c::I in 2:C
            if ff && !free[c]; continue; end
            e1::I,e2::I = 2*c-1,2*c
            if findset(uf,e1) == findset(uf,e2); continue; end
            p1::I,p2::I = prev[e1],prev[e2]
            graph[p1],graph[p2] = e2,e1
            prev[e1],prev[e2] = p2,p1 
            joinset(uf,e1,e2)
        end
    end
end

function simulateLarge(graph::VI,C::I,E::VI,L::VI,D::VI,camp1start::I)
    big::I = typemax(Int64)
    visits::VI = fill(0,C)
    d::I,h::I,c::I,nxt::I = 0,0,1,camp1start
    for i::I in 1:2C
        if visits[c] >= 2; return big; end
        visits[c] += 1
        if c != (nxt+1) >> 1; print("ERROR: Should not get here\n"); return big; end
        if L[nxt] < h; d += 1; end
        h = L[nxt] + D[nxt]
        d += h ÷ 24
        h = h % 24
        c = E[nxt]
        nxt = graph[nxt]
    end
    return c == 1 ? 24*d + h : big
end

function solveLarge(C::I,E::VI,L::VI,D::VI)::I
    best::I = typemax(Int64)
    for camp1config::I in [0,1]
        ## Do initial config assignments
        graph::VI,free::VB = doInitialAssignment(C,E,L,D,camp1config)
        ## Hunt for cycles -- use unionFind to store them
        uf::UnionFind{I} = cycleHunt(C,graph)
        ##  now we swap our connections to join the graph, first prioritizing the free nodes
        makeBigCycle(graph,C,E,uf,free)
        ## Start walking from the camp, and make a "costed switch" anytime we detect that the two paths are on different cycles.
        for camp1start in [1,2]
            x = simulateLarge(graph,C,E,L,D,camp1start)
            best = min(x,best)
        end
    end
    return best
end

function gentestE(C::I)
    perm = vcat(collect(1:C),collect(1:C))
    while(true)
        shuffle!(perm)
        good = true
        for i in 1:2C
            j = i == 2C ? 1 : i+1
            if perm[i] == perm[j]; good = false; break; end
        end
        if good; break; end
    end
    dests::VVI = [VI() for i in 1:C]
    for i in 1:2C
        j = i == 2C ? 1 : i+1
        push!(dests[perm[i]],perm[j])
    end
    E::VI = []
    for i in 1:C
        if rand() < 0.5; reverse!(dests[i]); end
        append!(E,dests[i])
    end
    return E
end

function gencase(Cmin::I,Cmax::I)
    C = rand(Cmin:Cmax)
    E = gentestE(C)
    L = rand(0:23,2C)
    D = rand(1:1000,2C)
    return (C,E,L,D)
end

function test(ntc::I,Cmin::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (C,E,L,D) = gencase(Cmin,Cmax)
        ans2 = solveLarge(C,E,L,D)
        if check
            ans1 = solveSmall(C,E,L,D)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(C,E,L,D)
                ans2 = solveLarge(C,E,L,D)
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
        C = gi()
        E::VI = fill(0,2C)
        L::VI = fill(0,2C)
        D::VI = fill(0,2C)
        for i in 1:2C; E[i],L[i],D[i] = gis(); end
        #ans = solveSmall(C,E,L,D)
        ans = solveLarge(C,E,L,D)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,2,15)
#end
#test(200,2,100,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

