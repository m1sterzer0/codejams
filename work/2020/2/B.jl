
using Random

function solveSmall(C::Int64,D::Int64,X::Vector{Int64},U::Vector{Int64},V::Vector{Int64})::String
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:C]
    d::Dict{Tuple{Int64,Int64},Int64} = Dict{Tuple{Int64,Int64},Int64}()
    for i in 1:D; push!(adj[U[i]], V[i]); push!(adj[V[i]],U[i]); d[(U[i],V[i])] = 1000000; end
    nodetimes::Vector{Int64} = [-1 for i in 1:C]; nodetimes[1] = 0
    orderinfo::Vector{Tuple{Int64,Int64}} = []
    for i in 2:C; if X[i] >= 0; return ""; else; push!(orderinfo,(-X[i],i)); end; end
    sort!(orderinfo)
    numvisited = 1
    lasttime = 0
    for (numprev,n) in orderinfo
        if numprev == numvisited; lasttime += 1; end
        numvisited += 1
        nodetimes[n] = lasttime
        for nn in adj[n]
            if nodetimes[nn] >= 0 && nodetimes[nn] < lasttime
                d[(n,nn)] = d[(nn,n)] = lasttime - nodetimes[nn]
            end
        end
    end
    dd = [d[(U[i],V[i])] for i in 1:D]
    ansstr = join(dd," ")
    return ansstr
end

function solveLarge(C::Int64,D::Int64,X::Vector{Int64},U::Vector{Int64},V::Vector{Int64})::String
    adj::Vector{Vector{Int64}} = [Vector{Int64}() for i in 1:C]
    d::Dict{Tuple{Int64,Int64},Int64} = Dict{Tuple{Int64,Int64},Int64}()
    for i in 1:D; push!(adj[U[i]], V[i]); push!(adj[V[i]],U[i]); d[(U[i],V[i])] = 1000000; end
    nodetimes::Vector{Int64} = [-1 for i in 1:C]; nodetimes[1] = 0
    orderinfo::Vector{Tuple{Int64,Int64}} = []
    timeinfo::Vector{Tuple{Int64,Int64}} = []
    for i in 2:C; 
        if X[i] >= 0; push!(timeinfo,(X[i],i))
        else; push!(orderinfo,(-X[i],i))
        end
    end
    sort!(orderinfo)
    sort!(timeinfo)
    numvisited = 1
    lasttime = 0
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
    dd = [d[(U[i],V[i])] for i in 1:D]
    ansstr = join(dd," ")
    return ansstr
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C,D = gis()
        X::Vector{Int64} = fill(0,C)
        X[2:end] = gis()
        U::Vector{Int64} = fill(0,D)
        V::Vector{Int64} = fill(0,D)
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

