
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

######################################################################################################### The key observation is to note that the height of each soldier is written down on two different
### lists, so if I look at the concatenation of all of the lists, the height will show up an even
### number of times.  If we are missing one list, the concatenation will have exactly N heights that
### appear an odd number of times.  This is the list that we want.
###
### Note that the heights are all less than or equal to 2500, so an array makes sense (vs. a dict).
######################################################################################################

function solve(N::I,h::Array{I,2})::String
    heights::VI = fill(0,2500)
    for hh in h; heights[hh] += 1; end
    missingHeights::VI = [x for x in 1:2500 if heights[x] & 1 != 0]
    return join(missingHeights," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        h::Array{I,2} = fill(0,N,2N-1)
        for i in 1:2N-1; h[:,i] = gis(); end
        ans = solve(N,h)
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

