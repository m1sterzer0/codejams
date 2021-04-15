
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

function solveSmall(N::I,M::I,K::I,X::VI,Y::VI)
    ### BFS for distances
    darr::VI = fill(-1,N)
    adj::VVI = [VI() for i in 1:N]
    for i::I in 1:M
        push!(adj[X[i]+1],Y[i]+1)
        push!(adj[Y[i]+1],X[i]+1)
    end
    darr[1] = 0; q::VI = [1]
    while !isempty(q)
        n::I = popfirst!(q)
        for k::I in adj[n]
            if darr[k] >= 0; continue; end
            darr[k] = darr[n]+1
            push!(q,k)
        end
    end

    ## Create the directed graph
    el::Vector{TI} = []
    inf::I = 1_000_000_000_000_000_000
    for i::I in 2:N-1; push!(el,(i,N+i,1)); end
    for i::I in 1:N
        for j::I in adj[i]
            if darr[i] + 1 == darr[j]; push!(el,(N+i,j,inf)); end
            if darr[j] + 1 == darr[i]; push!(el,(N+j,i,inf)); end
        end
    end

    minCut::I = dinic(2N,N+1,N,el)
    return minCut <= K-1 ? darr[N]+2 : darr[N]+1
end

## When we need to resume after edge modifications, this
## Edmonds Karp implementation is much easier to hack than
## Dinic's
function bfsMaxFlow(s::I, t::I, adj::VVI, capacity::Dict{PI,I}, parent::VI)::I
    inf::I = 10^18
    fill!(parent,-1)
    parent[s] = -2
    q::VPI = []
    push!(q,(s,inf))
    while !isempty(q)
        (cur::I,flow::I) = popfirst!(q)
        for next::I in adj[cur]
            if parent[next] == -1 && capacity[(cur,next)] > 0
                parent[next] = cur
                newFlow::I = min(flow,capacity[(cur,next)])
                if next == t; return newFlow; end
                push!(q,(next,newFlow))
            end
        end
    end
    return 0
end

function pushEdges(adj::VVI, capacity::Dict{PI,I}, n1::I, n2::I, cap::I, ncap::I)
    push!(adj[n1],n2); push!(adj[n2],n1);
    capacity[(n1,n2)] = cap; capacity[(n2,n1)] = ncap;
end

function solveLarge(N::I,M::I,K::I,X::VI,Y::VI)
    ##Following answer as envisioned in the official solutions
    ##Node-id for (v,x,bool) is 2*N*(x+1) + N*bool + v, where v goes from 1..N
    ##Note there are no bidrectional links
    edgeList::VPI = [(X[i]+1,Y[i]+1) for i in 1:M]    
    adj::VVI = []
    capacity::Dict{PI,I} = Dict{PI,I}()

    ## Do the initial stuff for X == 0
    for i in 1:2*N; push!(adj,VI()); end
    for i in 1:N; pushEdges(adj,capacity,i,i+N,1,0); end
    x::I,flow::I = 0,0

    myinf::I = 10^18
    while flow <= K
        x += 1
        offset::I = 2*N*x
        for i in 1:2*N; push!(adj,VI()); end
        for i in 1:N; pushEdges(adj,capacity,offset+i,offset+i+N,1,0); end                  ## These are the fragile edges where there is no guard
        for i in 1:N; pushEdges(adj,capacity,offset+i-2*N,offset+i,myinf,0); end            ## These are the wait paths
        for i in 1:N; pushEdges(adj,capacity,offset+i-2*N,offset+i+N,myinf,0); end          ## These are the path through the guard
        for (n1,n2) in edgeList; 
            pushEdges(adj,capacity,offset+n1-N,offset+n2,myinf,0);
            pushEdges(adj,capacity,offset+n2-N,offset+n1,myinf,0);
        end ## These are the paths from the graph

        ## Now do the maxflow
        parent::VI = fill(-1,2*N*(x+1))
        while(true)
            newFlow::I = bfsMaxFlow(1,N+offset,adj,capacity,parent)
            if newFlow == 0; break; end
            flow += newFlow
            if flow > K; break; end
            cur::I = N+offset
            while(cur != 1)
                prev::I = parent[cur]
                capacity[(prev,cur)] -= newFlow
                capacity[(cur,prev)] += newFlow
                cur = prev
            end
        end
    end
    return x
end

function gencase(Nmin::I,Nmax::I,Mfracmin::F,Mfracmax::F,Kmin::I,Kmax::I)
    N::I = rand(Nmin:Nmax)
    Mfrac::F = Mfracmin + rand()*(Mfracmax-Mfracmin)
    Mabsmax::I = N*(N-1) ÷ 2
    M = Int(floor(Mfrac*Mabsmax))
    K = min(N,rand(Kmin:Kmax))

    edgeSet::Set{PI} = Set{PI}()
    ## Need to force the path to be connected, so we force one path
    lifelineNumNodes = rand(2:max(2,min(M+1,N)))
    ln::Set{I} = Set{I}()
    push!(ln,0); push!(ln,N-1)
    while length(ln) < lifelineNumNodes; push!(ln,rand(0:N-1)); end
    delete!(ln,0); delete!(ln,N-1)
    if length(ln) == 0
        push!(edgeSet,(0,N-1))
    else
        lln::VI = shuffle([x for x in ln])
        last = 0
        for x in lln; push!(edgeSet,(min(last,x),max(last,x))); last = x; end
        push!(edgeSet,(last,N-1))
    end
    while length(edgeSet) < M
        a = rand(0:N-1)
        b = rand(0:N-1)
        if a == b; continue; end
        if b < a; (a,b) = (b,a); end
        if a == 0 && b == N-1; continue; end
        push!(edgeSet,(a,b))
    end
    M = length(edgeSet)
    edges::VPI = shuffle([x for x in edgeSet])
    X::VI = [x[1] for x in edges]
    Y::VI = [x[2] for x in edges]
    return (N,M,K,X,Y)
end

function test(ntc::I,Nmin::I,Nmax::I,Mfracmin::F,Mfracmax::F,Kmin::I,Kmax::I)
    for ttt in 1:ntc
        (N,M,K,X,Y) = gencase(Nmin,Nmax,Mfracmin,Mfracmax,Kmin,Kmax)
        ans = solveLarge(N,M,K,X,Y)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M,K = gis()
        X::VI = fill(0,M)
        Y::VI = fill(0,M)
        for i in 1:M; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,M,K,X,Y)
        ans = solveLarge(N,M,K,X,Y)
        print("$ans\n")
    end
end



Random.seed!(8675309)
main()
#test(1000,2,100,0.1,0.9,1,6)
#test(1000,2,100,0.1,0.9,1,100)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

