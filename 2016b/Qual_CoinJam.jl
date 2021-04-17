
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
###    * (x)^n % x+1 = ((x+1)-1)^n % (x+1) = (-1)^n % (x+1).
###      This is 1 -1 1 -1 1 -1 ,... for the various place values.
###    * This suggests that if we balance our 1's between the even
###      indices and odd indices, each number will be divisible by its (base + 1)
###
### Thus, we aim to construct our numbers with the same number of 1s in
### the even places vs. the odd places.
###    * For our solutions, We will used EXACTLY 6 1's.  This ensures we have enough
###      to meet the required 'J' numbers
###    * 3 ones need to come from the even numbered digits
###    * 3 ones need to come from the odd numbered digits
###
### SMALL CASE:
###    * We are forced to have a 1 in the first and 16th place.
###    * This means we need to pick 
###      -- two places amongst [2,4,6,8,10,12,14]
###      -- two places amongst [3,5,7,9,11,13,15]
###    * Note comb(7,2) = 21, so this gives us 21*21 = 441 -- plenty
###
### LARGE CASE:
###    * We are forced to have a 1 in the first and 32nd place
###    * This means we need to pick 
###      -- two places amongst [2,4,6,8,10,12,14,...,30]
###      -- two places amongst [3,5,7,9,11,13,15,...,31]
###    * Note comb(15,2) = 21, so this gives us 105*105 = 11025, which is certainly plenty
######################################################################################################

function solve(N::I,J::I)::VS
    ans::VS = []
    evenpairs = [(x,y) for x in 2:2:N-1 for y in x+2:2:N-1]
    oddpairs  = [(x,y) for x in 3:2:N-1 for y in x+2:2:N-1]    
    for (i,(ep,op)) in enumerate(Iterators.product(evenpairs,oddpairs))
        cj::String = prod([x in (1,N) || x in ep || x in op ? '1' : '0' for x in N:-1:1])
        push!(ans,"$cj 3 4 5 6 7 8 9 10 11")
        if i >= J; break; end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        N,J = gis()
        ans = solve(N,J)
        for s in ans; print("$s\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

