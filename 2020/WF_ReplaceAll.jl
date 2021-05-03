
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

function kosarajuAdj(n::I,adj::VVI)::VI
    visited::VB = fill(false,n)
    visitedInv::VB = fill(false,n)
    s::VI = []
    adjInv::VVI = [VI() for i in 1:n]
    scc::VI = fill(0,n)
    counter::I = 1
    for i::I in 1:n
        for j::I in adj[i]; push!(adjInv[j],i); end
    end

    function dfsFirst(u::I)
        if visited[u]; return; end
        visited[u] = true
        for x in adj[u]; dfsFirst(x); end
        push!(s,u)
    end

    function dfsSecond(u::I)
        if visitedInv[u]; return; end
        visitedInv[u] = true
        for x in adjInv[u]; dfsSecond(x); end
        scc[u] = counter
    end

    for i::I in 1:n; if !visited[i]; dfsFirst(i); end; end
    while !isempty(s)
        nn::I = pop!(s)
        if !visitedInv[nn]; dfsSecond(nn); counter += 1; end 
    end
    return scc
end

################################################################
## BEGIN Dinic's Max Flow
################################################################

function dinic(n::I, s::I, t::I, edgeList::Vector{TI})::I
    myinf = typemax(Int64)
    nume = size(edgeList,1)
    adj,newEdgeList = _dinicBuildAdj(n,edgeList)
    level::VI = [0 for i in 1:n]
    next::VI = [0 for i in 1:n]
    maxflow::I = 0
    while(_dinicBfs(s,t,newEdgeList,adj,level))
        fill!(next,1)
        f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        while(f > 0)
            maxflow += f
            f = _dinicDfs(s,t,nume,newEdgeList,adj,level,next,myinf)
        end
    end
    return maxflow
end

function _dinicBuildAdj(n::I,edgeList::Vector{TI})
    ne = length(edgeList)
    newEdgeList::Array{I,2} = fill(0,2*ne,3)
    adj::VVI = [VI() for x in 1:n]
    for i in 1:ne
        (n1,n2,c) = edgeList[i]
        newEdgeList[i,:] = [n1,n2,c]
        newEdgeList[ne+i,:] = [n2,n1,0]
        push!(adj[n1],i)
        push!(adj[n2],ne+i)
    end
    return adj,newEdgeList
end
    
function _dinicBfs(s::I, t::I, edgeList::Array{I,2}, adj::VVI, level::VI)
    fill!(level,-1)
    level[s] = 0
    q::VI = [s]
    while(!isempty(q))
        nn = pop!(q)
        for eid in adj[nn]
            n1,n2,c = edgeList[eid,:]
            if (c > 0 && level[n2] == -1)
                level[n2] = level[n1] + 1
                push!(q,n2)
            end
        end
    end
    return level[t] != -1
end

function _dinicDfs(n::I, t::I, nume::I, edgeList::Array{I,2}, adj::VVI, level::VI, next::VI, flow::I)::I
    if n == t; return flow; end
    ne = length(adj[n])
    while next[n] <= ne
        eid = adj[n][next[n]]
        n1,n2,c = edgeList[eid,:]
        if c > 0 && level[n2] == level[n1]+1
            bottleneck = _dinicDfs(n2,t,nume,edgeList,adj,level,next,min(flow,c))
            if bottleneck > 0
                edgeList[eid,3] -= bottleneck
                eid2 = eid > nume ? eid - nume : eid + nume
                edgeList[eid2,3] += bottleneck
                return bottleneck
            end
        end
        next[n] += 1
    end
    return 0
end

################################################################
## END Dinic's Max Flow
################################################################

function solve(S::String,N::I,R::VS)
    ## Make a quick dictionary to convert to integers
    d::Dict{Char,I} = Dict{Char,I}()
    for (i,c) in enumerate("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        d[c] = i
    end
    ## Scoreboard of which characters are present in S
    sb::VB = fill(false,62)
    for c::Char in S; sb[d[c]] = true; end

    ## Build the graph
    adj::VVI = [VI() for i in 1:62]
    for s::String in R; (i,j) = (d[s[1]],d[s[2]]); push!(adj[i],j); end

    ## Run Kosaraju
    scc::VI = kosarajuAdj(62,adj)
    numscc::I = maximum(scc)

    ## Count the size and the usedsize of each scc
    sccsize::VI = fill(0,numscc)
    sccusedsize::VI = fill(0,numscc)
    for i in 1:62
        sccsize[scc[i]] += 1
        if sb[i]; sccusedsize[scc[i]] += 1; end
    end

    ## Build a matrix that tells us which sccs are connected
    mat::Array{Bool,2} = fill(false,numscc,numscc)
    for i in 1:numscc; mat[i,i] = true; end
    for i in 1:62
        scci = scc[i]
        for j in adj[i]
            sccj = scc[j]
            mat[scci,sccj] = true
        end
    end

    ## Now use floyd-warshal to propagate the connectivity 
    for k in 1:numscc
        for i in 1:numscc
            for j in 1:numscc
                if mat[i,k] && mat[k,j]; mat[i,j] = true; end
            end
        end
    end

    ## Now we flag all sccs with a node with outdegree>0
    activescc::VB = fill(false,numscc)
    for i in 1:62
        scci = scc[i]
        if length(adj[i]) > 0; activescc[scci] = true; end
    end
    
    ##########################################################################################
    ## Now we build the maxflow graph (inspired by Gennady's code)
    ## ** Each scc is 2 nodes (i,numscc+i).  Source is 2*numscc+1, Sink is 2*numscc+2
    ## ** Starting characters come from source into i
    ## ** Ending characters go from numscc+i to sink
    ## ** Connected SCCs have inf edge from i to numscc+J
    ## ** Two cases for the bridge node within sccs
    ##    -- If the node size is 1 and it has no out degree, then it can become a final
    ##       resting spot, so the bridge size is 1
    ##    -- Otherwise, the internal bridge from source to sink is one less than the
    ##       component's size (representing having to create a "spot" to exercise all of the
    ##       edges within the scc)
    ##########################################################################################
    inf::I = 1_000_000_000
    mf::Vector{TI} = []
    for i in 1:numscc; 
        if sccusedsize[i] > 0
            push!(mf,(2*numscc+1,i,sccusedsize[i])) ## Source Node
        end
        push!(mf,(numscc+i,2*numscc+2,sccsize[i])) ## Sink node
        bridgeSize::I = (sccsize[i] == 1 && !activescc[i]) ? 1 : sccsize[i]-1
        if bridgeSize > 0
            push!(mf,(i,numscc+i,bridgeSize)) ## Bridge node
        end        
        for j in 1:numscc
            if i != j && mat[i,j]; push!(mf,(i,numscc+j,inf)); end  ## Connectivity nodes
        end
    end
    ans::I = dinic(2*numscc+2,2*numscc+1,2*numscc+2,mf)
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        xx = gss()
        S = xx[1]
        N = parse(Int64,xx[2])
        R = gss()
        ans = solve(S,N,R)
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

