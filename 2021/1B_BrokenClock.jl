
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

function solve(A::I,B::I,C::I)::String
    if A == B == C; return "0 0 0 0"; end
    numticks::Int128 = 10^9 * 3600 * 12
    for (h,m,s) in [(A,B,C),(A,C,B),(B,A,C),(B,C,A),(C,A,B),(C,B,A)]
        ## Track the angle between the hour and minute hands
        ## Need 12x - x == targ (mod numticks)
        ## 11x == targ (mod numticks)
        ## x == targ * inv(11) mod numticks

        ## Similarly, for the angle between the hour and second hands
        ## Need 720x - x == targ (mod numticks)
        ## 719x == targ (mod numticks)
        ## x == targ * inv(719) mod numticks
        targ1 = m-h < 0 ? m-h+numticks : m - h
        targ2 = s-h < 0 ? s-h+numticks : s - h
        x1::Int128 = Int128(invmod(11,numticks))  * Int128(targ1) % Int128(numticks)
        x2::Int128 = Int128(invmod(719,numticks)) * Int128(targ2) % Int128(numticks)
        if x1 == x2
            ansh = x1 ÷ (10^9*3600); x1 -= ansh * 10^9 * 3600
            ansm = x1 ÷ (10^9*60);   x1 -= ansm * 10^9 * 60
            anss = x1 ÷ (10^9);      x1 -= anss * 10^9
            ansn = x1
            return "$ansh $ansm $anss $ansn"
        end
    end
    return "IMPOSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        A,B,C = gis()
        ans = solve(A,B,C)
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

