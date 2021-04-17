
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
### Observations
###    * Because there is only one edge out of each node, each element may only belong to 0
###      or 1 cycles.
###    * The end result will be either
###      a) The largest cycle we can make
###      b) The largest collection of chains we can assemble that loop back on themselves
###
### To this end, we should endeavor to find three "structures" in the graphs
###  a) Cycles with >= 3 elements
###  b) Cycles with exactly 2 elements
###  c) Chains that end in a 2 element cycle.  For this one, we can search from non-sink nodes in
###     the graph.
###
### We then output either the maximum cycle size, or the sum of the disjoint chains, including
### all of the 2 cycles.  One hiccup is that we can up to 2 chains that end in the same two cycle
### provided they come into the chain from different elements there.
######################################################################################################

function biggestChains(chains::VVI,twoCycles::VVI)::I
    endpoints::SI = SI()
    chainPoints::SI = SI()
    for c in twoCycles
        for x in c
            push!(endpoints,x)
        end
    end
    sort!(chains,rev=true,by=length)
    for c in chains
        if c[end] in endpoints
            for x in c; push!(chainPoints,x); end
            pop!(endpoints,c[end])
        end
    end
    return length(union(endpoints,chainPoints))
end

function solve(N::I,F::VI)
    bigCycles::VVI,twoCycles::VVI,chains::VVI = [],[],[]
    for i in 1:N
        path::VI = [i]
        while F[path[end]] ∉ path; push!(path,F[path[end]]); end
        if F[path[end]] == path[1] 
            if length(path) == 2
                push!(twoCycles,path)
            else
                push!(bigCycles,path)
            end
        elseif F[path[end]] == path[end-1]
            push!(chains,path)
        end
    end
    best::I = length(bigCycles) == 0 ? 0 : maximum([length(x) for x in bigCycles])
    return max(best, biggestChains(chains,twoCycles))
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        F::VI = gis()
        ans = solve(N,F)
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

