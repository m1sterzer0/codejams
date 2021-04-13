
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

function feasible(cand::I,adj::Vector{SI},state::VI,stack::VI)::Bool
    mystack::VI = stack[:]
    mystate::VI = state[:]
    while !isempty(mystack) && mystack[end] ∉ adj[cand]
        mystate[mystack[end]] = 2
        pop!(mystack)
    end
    if isempty(mystack); return false; end

    function dfs(n::I)
        for c in adj[n]
            if mystate[c] == 0; mystate[c] = 1; dfs(c); end
        end
    end

    for n in mystack; dfs(n); end
    if 0 in mystate; return false; end
    return true;
end

function solve(N::I,M::I,zips::VI,edges::VPI)::String
    adj::Vector{SI} = [SI() for i in 1:N]
    for i in 1:M
        push!(adj[edges[i][1]],edges[i][2])
        push!(adj[edges[i][2]],edges[i][1])
    end
    prioritylist::VPI = [(zips[i],i) for i in 1:N]
    sort!(prioritylist)
    ## Process first node
    bestnode = prioritylist[1][2]
    nodeorder = [bestnode]
    state::VI = fill(0,N)
    state[bestnode] = 1
    stack::VI = [bestnode]

    for i in 1:N-1
        for (_zip,j) in prioritylist
            if state[j] != 0; continue; end
            if !feasible(j,adj,state,stack); continue; end
            while stack[end] ∉ adj[j]; state[stack[end]] = 2; pop!(stack); end
            state[j] = 1
            push!(stack,j)
            push!(nodeorder,j)
            break
        end
    end
    anszips = [zips[x] for x in nodeorder]
    return join(anszips)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = gis()
        zips::VI = []
        edges::VPI = []
        for i in 1:N
            push!(zips,gi())
        end
        for i in 1:M
            ii,jj = gis()
            push!(edges,(ii,jj))
        end
        ans = solve(N,M,zips,edges)
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

