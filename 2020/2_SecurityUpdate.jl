
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

function solveSmall(C::I,D::I,X::VI,U::VI,V::VI)::String
    adj::VVI = [VI() for i in 1:C]
    d::Dict{PI,I} = Dict{PI,I}()
    for (u::I,v::I) in zip(U,V); push!(adj[u],v); push!(adj[v],u); d[(u,v)] = 1000000; end
    nodetimes::VI = [-1 for i in 1:C]; nodetimes[1] = 0
    orderinfo::VPI = []
    for i in 2:C; if X[i] >= 0; return ""; else; push!(orderinfo,(-X[i],i)); end; end
    sort!(orderinfo)
    numvisited::I = 1; lasttime::I = 0
    for (numprev::I,n::I) in orderinfo
        if numprev == numvisited; lasttime += 1; end
        numvisited += 1
        nodetimes[n] = lasttime
        for nn in adj[n]
            if nodetimes[nn] >= 0 && nodetimes[nn] < lasttime
                d[(n,nn)] = d[(nn,n)] = lasttime - nodetimes[nn]
            end
        end
    end
    return join([d[(u,v)] for (u::I,v::I) in zip(U,V)]," ")
end

function solveLarge(C::I,D::I,X::VI,U::VI,V::VI)::String
    adj::VVI = [VI() for i in 1:C]
    d::Dict{PI,I} = Dict{PI,I}()
    for (u::I,v::I) in zip(U,V); push!(adj[u],v); push!(adj[v],u); d[(u,v)] = 1000000; end
    nodetimes::VI = [-1 for i in 1:C]; nodetimes[1] = 0
    orderinfo::VPI = []
    timeinfo::VPI = []
    for i in 2:C; 
        if X[i] >= 0; push!(timeinfo,(X[i],i))
        else; push!(orderinfo,(-X[i],i))
        end
    end
    sort!(orderinfo); sort!(timeinfo)
    numvisited = 1; lasttime = 0
    while !isempty(orderinfo) || !isempty(timeinfo)
        n = -1
        if !isempty(orderinfo) && orderinfo[1][1] <= numvisited
            (numprev,n) = popfirst!(orderinfo)
            if numprev == numvisited; lasttime += 1; end
        else
            (mytime,n) = popfirst!(timeinfo)
            lasttime = mytime
        end
        numvisited += 1
        nodetimes[n] = lasttime
        for nn in adj[n]
            if nodetimes[nn] >= 0 && nodetimes[nn] < lasttime
                d[(n,nn)] = d[(nn,n)] = lasttime - nodetimes[nn]
            end
        end
    end
    return join([d[(u,v)] for (u::I,v::I) in zip(U,V)]," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        C,D = gis()
        X::VI = fill(0,C)
        X[2:end] = gis()
        U::VI = fill(0,D)
        V::VI = fill(0,D)
        for i in 1:D; U[i],V[i] = gis(); end
        #ans = solveSmall(C,D,X,U,V)
        ans = solveLarge(C,D,X,U,V)
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

