
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
### A couple of key observations
### * The stack weight grows geometrically (at least by 7/6, and by quite a bit more than that early),
###   so the stack height limit is actually reasonably small (i.e. < 150).
### * We build a simple DP where we calculate the minimum weight of a stack of size i using using
###   elements in the prefix of the list.  This is still a O(150N) DP, but it seems to be the best we
###   can do.
######################################################################################################

function solve(N::I,W::VI)::I
    W6::VI  = [6*x for x in W]
    dp1::VI = fill(0,N)
    dp2::VI = fill(0,N)
    big::I = 10^18
    for i in 1:2000
        (dp1,dp2) = (dp2,dp1)
        if i > N; return N; end
        dp2[1] = i == 1 ? W[1] : big
        for j in 2:N
            dp2[j] = min(dp2[j-1], W6[j] >= dp1[j-1] ? dp1[j-1] + W[j] : big)
        end
        if dp2[N] >= big; return i-1; end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        W::VI = gis()
        ans = solve(N,W)
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

