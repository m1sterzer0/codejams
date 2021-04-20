
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
### This is a little tricky.  Each polled person contributes K + R/N to the unrounded percentage.
### We can ignore the K terms.  Then, our goal is to be as greedy as possible in how we allocate
### our remaining "R/N" adders to maximize the rounded total sum. A few cases
### -- If R/N == 0, then this whole thing is moot, as each person contributes exactly a whole number
###    of percentage points, and the answer will always be 100%
### -- If R/N >= 0.5, then our most efficient method to boost our score is just to make up new
###    languages for all of the remaining people, since each one will add one to the percentage. Getting
###    one point for each R/N term is the best we can ever hope for.
### -- If R/N is less than 0.5, we can make several more observations
###    * It never makes sense to add items to one that is already "rounded up", since in that case
###      it is at least as good to create new entries.  The new entries only need to make it to 0.5,
###      while the already rounded up terms need to make it to 0.5 + more.
###    * For the rounded down terms, we need to figure out how many we need to add to get to 0.5, and
###      we process these in sorted order of required elements.  Once we get to the same as the number
###      it takes to get a point from creating a new language, we switch over. 
######################################################################################################

function solve(N::I,L::I,C::VI)
    K::I = 100 ÷ N
    R::I = 100 % N ## Each added lines adds 1/N to the fraction == 100/N to the unrounded percentage = (K + R/N)
    if R == 0; return 100; end

    numLeft::I = N - sum(C)
    threshold::I = (N+1) ÷ 2
    baseline::I = sum(100x ÷ N for x in C) + count(x->100x % N >= threshold, C) + K * numLeft
    if 2R >= N; return baseline + numLeft; end ## Here we can get a full remainder point by creating a new language with one pollster.

    needed::VI = [ (threshold - (100x % N) + R - 1) ÷ R for x in C if (100x % N) < threshold ]
    sort!(needed)
    newLang::I = (threshold + R - 1) ÷ R
    for i in needed
        if numLeft < i || i >= newLang; break; end
        numLeft -= i
        baseline += 1
    end
    baseline += numLeft ÷ newLang
    return baseline
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = gis()
        C::VI = gis()
        ans = solve(N,L,C)
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

