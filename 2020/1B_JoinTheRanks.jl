
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

function solve(R::I,S::I)
    ans::VPI = []
    cards2move::I = (S-1)*R ## Merging cards 2 at a time into final suit
    finalsuit::VI = [1 for x in 1:R]
    nextrank::I = 1
    while cards2move > 0
        if cards2move <= 2  ## last move
            a::I = S - finalsuit[R] + (cards2move-1)
            b::I = R*S - a - finalsuit[R]
            push!(ans,(a,b))
            return ans
        end
        np1::I = nextrank == R ? 1 : nextrank + 1
        b = R*S-2-sum(finalsuit[np1:end])
        push!(ans,(2,b))
        if nextrank != R; finalsuit[nextrank] += 1; end
        finalsuit[np1] += 1
        cards2move -= 2
        nextrank += 2
        if nextrank > R; nextrank -= R; end
    end
    return ans    
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,S = gis()
        moves = solve(R,S)
        print("$(length(moves))\n")
        for (a,b) in moves; print("$a $b\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

