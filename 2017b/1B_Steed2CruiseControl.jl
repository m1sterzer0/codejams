
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
### Since horses can't pass each other, we need to reach the finish line when the last horse
### would reach the line if it were unimpeded.  Thus, all we have to do is to calculate the finish
### time of all of the other horses, pick the last one, and calculate our speeed.
######################################################################################################

function solve(D::I,N::I,K::VI,S::VI)::F
    finishTimes::VF = [(D-K[i])/S[i] for i in 1:N]
    worstFinish::F = maximum(finishTimes)
    return D / worstFinish
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        D,N = gis()
        K::VI = fill(0,N)
        S::VI = fill(0,N)
        for i in 1:N; K[i],S[i] = gis(); end
        ans = solve(D,N,K,S)
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

