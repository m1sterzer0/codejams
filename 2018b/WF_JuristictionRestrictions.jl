
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

function solve(R::I,C::I,S::I,RR::VI,CC::VI,DD::VI)
    ## Set up some coordinate compression
    cols::VI = []; rows::VI = []
    for i::I in 1:S
        left::I  = max(1,CC[i]-DD[i])
        right::I = min(C+1,CC[i]+DD[i]+1)
        bot::I   = max(1,RR[i]-DD[i])
        top::I   = min(R+1,RR[i]+DD[i]+1)
        push!(cols,left); push!(cols,right)
        push!(rows,top);  push!(rows,bot)
    end
    unique!(sort!(cols)); unique!(sort!(rows))

    ## Build the edge data structures
    bridgeEdges::Vector{TI} = []
    tailEdges::Vector{TI}   = []
    full::I = 0
    regionidx::I = 3+S
    myinf::I = 1_000_000_000_000_000_001
    numrows::I,numcols::I = length(rows),length(cols)
    for i in 1:numrows-1
        for j in 1:numcols-1
            left,right,top,bot = cols[j],cols[j+1]-1,rows[i+1]-1,rows[i]
            area = (top-bot+1) * (right-left+1)
            active = false
            ## Answer 2 questions here
            ## * Is this rectangle in the possible patrol region for this station?
            ##   Just need a test point
            ## * Does this region contain the station
            for k in 1:S
                if CC[k] - DD[k] <= left <= CC[k] + DD[k] && RR[k] - DD[k] <= top <= RR[k] + DD[k]
                    active = true
                    push!(bridgeEdges,(2+k,regionidx,myinf))
                end
                if left <= CC[k] <= right && bot <= RR[k] <= top
                    area -= 1
                end
            end
            if area > 0; push!(tailEdges,(regionidx,2,area)); end
            if active; full += area; end
            regionidx += 1
        end
    end

    ## Special case if there are no available assignments
    if full == 0; return 0; end

    numnodes = 2 + S + (numrows-1)*(numcols-1)
    ## Do the lower bound search
    l,u = 0,myinf
    while u-l > 1
        m = (u+l) ÷ 2
        prefixEdges = [(1,2+x,m) for x in 1:S]
        myEdges::Vector{TI} = vcat(prefixEdges,bridgeEdges,tailEdges)
        f = dinic(numnodes,1,2,myEdges)
        if f == m*S; l=m; else; u=m; end  ## Looking to make sure we get full flow
    end
    L = l

    ## Do the upper bound search
    l,u = 0,myinf
    while u-l > 1
        m = (u+l) ÷ 2
        #print("DBG: UPPER m:$m\n")
        prefixEdges = [(1,2+x,m) for x in 1:S]
        myEdges::Vector{TI} = vcat(prefixEdges,bridgeEdges,tailEdges)
        f = dinic(numnodes,1,2,myEdges)
        if f == full; u=m; else; l=m; end ## Looking to make sure we get full coverage
    end
    U=u
    return U-L
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,S = gis()
        RR::VI = fill(0,S)
        CC::VI = fill(0,S)
        DD::VI = fill(0,S)
        for i in 1:S; RR[i],CC[i],DD[i] = gis(); end
        ans = solve(R,C,S,RR,CC,DD)
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

