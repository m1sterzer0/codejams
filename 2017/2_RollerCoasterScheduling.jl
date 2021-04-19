
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
### We first figure out how many roller coaster rides we must have, and after that, we figure out
### how to accomplish that with the fewest promotions.
###
### It seems there for sure three things that can limit the number of rides that we must make
###    a) The number of tickets sold to any one person.
###    b) The number of tickets solt for the first seat
###    c) The total number of tickets sold for the "first N" seats
### If we can choose the minimum number of rides that satisfies all three of these constraints, then
### we are good.
###
### After we have these numbers, we simply fill our rides from back to front, and we promote only as
### much as needed.  This will count the promotions, and serve as a "check" on whether our math
### was right for the first part.
######################################################################################################

function solve(N::I,C::I,M::I,P::VI,B::VI)::String

    ## Constraint 1
    pc::VI  = fill(0,C)
    for i in 1:M; pc[B[i]] += 1; end
    rides::I = maximum(pc)

    ## Constraints 2 & 3
    bc::VI = fill(0,N)
    for i in 1:M; bc[P[i]] += 1; end
    s::I = 0
    for i in 1:N
        s += bc[i]
        rides = max(rides,(s+i-1) ÷ i)
    end

    ## Figure out how many promotions we need
    promotions::I = 0
    for i in N:-1:1
        promotions += max(0,bc[i]-rides)
    end

    return "$rides $promotions"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,C,M = gis()
        P::VI = fill(0,M)
        B::VI = fill(0,M)
        for i in 1:M; P[i],B[i] = gis(); end
        ans = solve(N,C,M,P,B)
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

