
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
### Observations
###    * Lets consider the 'L' blocks as "False", and the "G" blocks as "True"
###    * Looking at the 2, 3, cases gives us some intuition
###      2 case:
###          a,b -->
###          a|a, a|b, b|a, b|b --> 
###          a|a|a, a|a|b, ... --> 
###          a|a|a|a, a|a|a|b, ... -->
###
###      3 case:
###          a,b,c -->
###          a|a, a|b, a|c, b|a, b|b, b|c, c|a, c|b, c|c -->
###          a|a|a, a|a|b, a|a|c, a|b|a, a|b|b, a|b|c, a|c|a, a|c|b, a|c|c, ... -->
###          a|a|a|a, a|a|a|b, a|a|a|c, a|a|b|a, a|a|b|b, a|a|b|c, ... -->
###
###    * Key points
###      -- Each layer we add gives us blocks with potentially more information.  For example, Layer 2 gives us information on all ordered pairs of blocks,
###         layer 3 gives us information about all ordered triples of blocks.
###      -- We can each block index (starting with zero) of layer X as a base K number of length X.  The digits in this number tell us which blocks we are
###         getting information about in that index.
###
###  Thus, to solve the problem, we need to do two things
###      -- Check to see if S * C >= K.  If not, this is impossible.
###      -- It if is not impossible, we just emit ceil(K // C) numbers base k, ensuring that each digit is represented in the collection
###      -- we have to deal with "1-indexing", so we cannot forget to add 1
######################################################################################################

function solve(K::I,C::I,S::I)::String
    if S*C<K; return "IMPOSSIBLE"; end
    pvs::VI = [K^i for i in 0:C-1]
    totalnumbers::I = (K + (C-1)) ÷ C
    digits::VI = vcat(collect(0:K-1),zeros(Int64,totalnumbers*C - K))
    digits2::Array{I,2} = reshape(digits,C,totalnumbers)
    indices::VI = [c' * pvs + 1 for c in eachcol(digits2)]
    return join(indices," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        K,C,S = gis()
        ans = solve(K,C,S)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

