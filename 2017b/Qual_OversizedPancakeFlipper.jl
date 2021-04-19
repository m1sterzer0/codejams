
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
### We can't just simulate the process linearly for the large dataset, but we can still simulate
### things in batches.  Observations:
###  -- Note that "choosing a stall" is just the process of "bisecting" the remaining largest "stall gap"
###  -- We can gain efficiency by treating all available "stall distances" in a batch.
###  -- As we bisect the stall distances, one might worry that the pool of available stall distances
###     will grow.  However, we note this isn't the case.
###     -- After the first biesction we will end up with 1-2 stall distances.  If we have 2, they
###        only have a gap of 1.
###     -- After bisecting BOTH of those, we will also have just 1-2 remaining stall distances
###        (with possible more then one instance of each distance).  If we have 2, the gap will be one
###        between them.
###     -- After bisecting ALL of those, we will also just have 1-2 remaining stall distances (with all
###        gap of at-most 1)
### This suggest that can very quickly do the calculations for a factor of 2, so we can process
### the stall lengths in log time.
######################################################################################################

function solve(S::String,K::I)::String
    N::I = length(S)
    row::VB = [x == '+' ? true : false for x in S]
    flipcnt::I = 0
    for i::I in 1:N-K+1
        if row[i]; continue; end
        flipcnt += 1
        row[i:i+K-1] = .!row[i:i+K-1]
    end
    res = reduce(&,row[N-K+2:N])
    return res ? "$flipcnt" : "IMPOSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        xx::VS = gss()
        S::String = xx[1]
        K::I = parse(Int64,xx[2])
        ans = solve(S,K)
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

