
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
## The key is to creatively use the overflow
## A) On day 226, the 1-day, 2-day, and 3-day rings will have overflown 2^64.
##    The 4 day rings will be multiplied by 2^56
##    The 5-day rings will be multiplied by 2^45
##    The 6-day rings will be multiplied by 2^37
##    Note that we only need 7 bits to hold each quantity, and the 3 figures here don't overlap, so
##    we can determine them exactly.
## b) Now on day 54
##    The 1 day rings will be multiplied by 2^54
##    The 2 day rings will be multiplied by 2^27
##    The 3 day rings will be multiplied by 2^18
##    The 4-day rings will be multiplied by 2^13
##    The 5-day rings will be multiplied by 2^10
##    The 6-day rings will be multiplied by 2^9
##    Thus, we can subtract off the 4/5/6-day contributions, and notice sufficient separatition to recover the
##    other 3 terms.
## Other date combinations work as well.  I just ran 
##     for i in 1:300; println("$i: $i  $(i÷2)  $(i÷3)  $(i÷4)  $(i÷5)  $(i÷6)"); end
## At a julia prompt to explore which days made sense to query.
###################################################################################################### 

function solve(W::I)
    print("226\n54\n"); flush(stdout)
    x1 = gi(); x2 = gi()
    day6 = (x1 >> 37) & 127
    day5 = (x1 >> 45) & 127
    day4 = (x1 >> 56) & 127
    x2 -= (day6*2^9+day5*2^10+day4*2^13)
    day3 = (x2 >> 18) & 127
    day2 = (x2 >> 27) & 127
    day1 = (x2 >> 54) & 127
    println("$day1 $day2 $day3 $day4 $day5 $day6"); flush(stdout)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,W::I = gis()
    for qq in 1:tt
        ans = solve(W)
        res = gi(); if res != 1; exit(0); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

