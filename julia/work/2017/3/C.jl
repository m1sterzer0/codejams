using Printf

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

function doInitialAssignment(C::Int64,E::Vector{Int64},L::Vector{Int64},D::Vector{Int64},camp1config::Int64)
    graph = fill(0,2C)
    free = fill(false,C)
    ## Figure out which paths lead to a given camp
    pre = [[] for i in 1:C]
    for i in 1:2C; push!(pre[E[i]],i); end

    graph[pre[1][1]] = camp1config == 0 ? 1 : 2
    graph[pre[1][2]] = camp1config == 0 ? 2 : 1

    for i in 2:C
        e1,e2 = pre[i][1],pre[i][2]
        a1,a2 = (L[e1]+D[e1]) % 24, (L[e2]+D[e2]) % 24
        d1,d2 = L[2*i-1],L[2*i]

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

function cycleHunt(C,graph)
    uf = UnionFind{Int64}()
    for i in 1:2C; push!(uf,i); end
    visited = fill(false,2C)
    for i in 1:2C
        if visited[i]; continue; end
        node = i
        while(true)
            node = graph[node]
            if node == i; break; end
            joinset(uf,i,node)
        end
    end
    return uf
end

function makeBigCycle(graph,C,E,uf,free)
    prev = fill(0,2C)
    for i in 1:2C; prev[graph[i]] = i; end
    for ff in [true,false]
        for c in 2:C
            if ff && !free[c]; continue; end
            e1,e2 = 2*c-1,2*c
            if findset(uf,e1) == findset(uf,e2); continue; end
            p1,p2 = prev[e1],prev[e2]
            graph[p1],graph[p2] = e2,e1
            prev[e1],prev[e2] = p2,p1 
            joinset(uf,e1,e2)
        end
    end
end

function simulate(graph,C,E,L,D,camp1start)
    big = typemax(Int64)
    visits = fill(0,C)
    d,h,c,nxt = 0,0,1,camp1start
    for i in 1:2C
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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C = parse(Int64,rstrip(readline(infile)))
        E = fill(0,2C)
        L = fill(0,2C)
        D = fill(0,2C)
        for i in 1:2C
            E[i],L[i],D[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        best = typemax(Int64)
        for camp1config in [0,1]
            ## Do initial config assignments
            graph,free = doInitialAssignment(C,E,L,D,camp1config)
            ## Hunt for cycles -- use unionFind to store them
            uf = cycleHunt(C,graph)
            ##  now we swap our connections to join the graph, first prioritizing the free nodes
            makeBigCycle(graph,C,E,uf,free)
            ## Start walking from the camp, and make a "costed switch" anytime we detect that the two paths are on different cycles.
            for camp1start in [1,2]
                x = simulate(graph,C,E,L,D,camp1start)
                best = min(x,best)
            end
        end
        print("$best\n")
    end
end

main()
