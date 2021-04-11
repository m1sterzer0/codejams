
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

function solve(N::I,A::VI,B::VI)
    ## Greedy algorithm
    ## 1) First,  prioritize any level where we can do the full pair
    ## 2) Second, prioritize any level where we have already done the first StatProfilerHTML
    ## 3) Last,   pick a level where we can do the first one, breaking ties with the highest second number (minimum chance of destroying a double)
    s::VI = fill(0,N)
    numStars::I = 0
    levPlayed::I = 0
    while (numStars < 2N)
        p1::I,p2::I,p3::I,p3b::I = 0,0,0,0
        for i in 1:N
            if s[i] == 0 && numStars >= B[i]; p1 = i; break; end
            if s[i] == 1 && numStars >= B[i]; p2 = i; continue; end
            if s[i] == 0 && numStars >= A[i] && (p3 == 0 || B[i] > p3b); p3 = i; p3b = B[i]; end
        end
        if p1 == 0 && p2 == 0 && p3 == 0; return -1; end
        levPlayed += 1
        if p1 > 0; numStars += 2; s[p1] = 2; continue; end
        if p2 > 0; numStars += 1; s[p2] = 2; continue; end
        numStars += 1; s[p3] = 1
    end
    return levPlayed
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        A::VI = fill(0,N)
        B::VI = fill(0,N)
        for i in 1:N; A[i],B[i] = gis(); end
        ans = solve(N,A,B)
        if ans < 0; print("Too Bad\n"); else; print("$ans\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

