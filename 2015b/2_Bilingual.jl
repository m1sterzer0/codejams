
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

function solveSmall(N::I,S::VS)
    ## First, convert sentences to list of unique numbers
    allwords::VS = []
    for i in 1:N; for w in split(S[i]); push!(allwords,w); end; end
    unique!(allwords)
    wordLookup::Dict{String,I} = Dict{String,I}()
    for (i,w) in enumerate(allwords); wordLookup[w]=i; end
    sentences::VVI = [ [wordLookup[w] for w in split(S[i])] for i in 1:N]
    wcnt = length(allwords)
    best = wcnt
    baseScoreboard::VI = fill(0,wcnt)
    for w in sentences[1]; baseScoreboard[w] |= 1; end
    for w in sentences[2]; baseScoreboard[w] |= 2; end
    if N == 2; return count(x->baseScoreboard[x]==3,1:wcnt); end
    for mask in 0:2^(N-2)-1
        scoreboard = copy(baseScoreboard)
        for sidx in 3:N
            amt = mask & (1 << (sidx-3)) > 0 ? 2 : 1
            for w in sentences[sidx]; scoreboard[w] |= amt; end
        end
        cnt::I = 0
        for i in 1:wcnt
            if scoreboard[i] == 3; cnt += 1; end
        end
        #print("DBG: mask=$mask cnt:$cnt scoreboard:$scoreboard\n")
        best = min(cnt,best)
    end
    return best
end

function solveLarge(N::I,S::VS)::I
    ## This is a min-cut problem, which we can solve w/ max flow
    allwords::VS = []
    edgeList::Vector{TI} = []
    for i in 1:N; for w in split(S[i]); push!(allwords,w); end; end
    unique!(allwords)
    wordLookup::Dict{String,I} = Dict{String,I}()
    for (i,w) in enumerate(allwords)
        push!(edgeList,(N+2i-1,N+2i,1))
        wordLookup[w]=N+2i-1
    end
    inf = 1_000_000_000_000_000_000
    for i in 1:N
        words::VI = [wordLookup[x] for x in split(S[i])]
        for w in words;
            push!(edgeList,(i,w,inf))
            push!(edgeList,(w+1,i,inf))
        end
    end
    ans = dinic(N+2*length(allwords),1,2,edgeList)
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        S::VS = [gs() for i in 1:N]
        #ans = solveSmall(N,S)
        ans = solveLarge(N,S)
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

