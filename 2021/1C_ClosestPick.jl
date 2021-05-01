
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

## Choices
## -- If we spend both of our tickets on the endpoints of the same interval, we get the whole interval
## -- If we spend one ticket on one endpoint and one ticket on another,  then we get approx half of the interval
## -- The beginning/end are special -- we can claim the full beginning or end with one ticket.
## Idea
## -- Keep track of best ways to spend singletons and doubles.  At the end, choose which we want
function solve(N::I,K::I,preP::VI)::F
    V::VI = unique(sort(copy(preP)))
    sing::VI = []
    doub::VI = []
    ## Do the endpoints
    push!(sing,V[1]-1); push!(sing,K-V[end]); push!(doub,0)
    for i in 1:length(V)-1
        push!(doub,V[i+1]-V[i]-1)
        push!(sing,(V[i+1]-V[i])÷2)
    end
    sort!(sing,rev=true); sort!(doub,rev=true)
    return max(sing[1]+sing[2],doub[1])/K
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        P::VI = gis()
        ans = solve(N::I,K::I,P::VI)
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

