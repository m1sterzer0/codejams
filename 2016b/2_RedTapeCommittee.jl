using Printf
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
### a) We observe that the answer involves picking from the extremes.  To see this, suppose the
###    optimum has a point X for with P(y) < P(X) < P(Z) where Y and Z are not in the optimal set.
###    Fix the other members of the set, and let a/b be the probability that there are "half-1"/"half"
###    votes from the fixed members.  Then the probability of a tie is a * P(X) + b * (1-P(X)) which is
###    linear in P(X).  Thus, at least one of {Y,Z} should a better answer (or at least as good of an
###    answer in the case if a == b).
###
### b) Given 1:N ordered members, each with probability P(i) to vote yes, we can calculate the probability
###    of k yes votes after the first i members have votes with the recurrance
###            P(i,k) = P(i) * P(i-1,k-1) + (1-P(i)) * P(i-1,k)
###
### c) Out of an abundance of paranoia, we will use BigFloat for the math to avoid precision errors.
###
### d) This means we simply need to iterate through (K+1) sets of K folks.  The algorithm is then
###    O(K^3) + O(NlogN) (ignoring the need to grow the precision with increasing)
######################################################################################################

function calcIt(aa::Vector{BigFloat}, m::I)
    one::BigFloat,zero::BigFloat = BigFloat(1.0),BigFloat(0.0)
    new::Vector{BigFloat} = [one]
    old::Vector{BigFloat} = []
    for p::BigFloat in aa 
        old = new
        new = vcat(old,[zero]) .* (one - p) + vcat([zero],old) .* p
    end
    return new[m+1]
end

function solve(N::I,K::I,preP::Vector{BigFloat})::BigFloat
    P::Vector{BigFloat} = copy(preP)
    sort!(P)
    best = BigFloat(0.0)
    m = K ÷ 2
    for numleft in 0:K
        numright = K-numleft
        aa = vcat(P[1:numleft],P[N-numright+1:N])
        best=max(best,calcIt(aa,m))
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        P = [parse(BigFloat,x) for x in gss()]
        ans = solve(N,K,P)
        @printf("%.8f\n",Float64(ans))
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

