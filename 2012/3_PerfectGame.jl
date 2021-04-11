
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

## Let p_i denote the probability of failure on level.
## Let q_i denote the probability of success on level. q_i = 1 - p_i. Note q_i != 0 as per constraints.
## Let r_i = 1/q_i denote the probability of failure.
## Let l_i denote the length of level i
## Let E[i] = the expected time to get a sucessful run from the beginning
## to the end of level i.  Note that E[i] = r_i * (E[i-1] + l_i).
## Now lets consider two ordering of the levels
##     Case 1: Ordering: 1,2,3,...,k,m,n,... A = E[n] = r_m*r_n*E[k] + r_m*r_n*l_m + r_n*l_n
##     Case 2: Ordering: 1,2,3,...,k,n,m,... B = E[n] = r_m*r_n*E[k] + r_m*r_n*l_n + r_m*l_m
## Multiplying by q_m*q_n, and assuming everything is positive
##     A < B iff l_m + q_m*l_n < l_n + q_n*l_m iff l_m * (1-q_n) < l_n * (1-q_m)
## This provides the basis of a compare function to correctly order the levels.

struct Level; l::I; q::I; id::I; end
Base.isless(a::Level,b::Level) = a.l*(100-b.q) < b.l*(100-a.q) || a.l*(100-b.q) == b.l*(100-a.q) && a.id < b.id

function solve(N::I,L::VI,P::VI)::VI
    ll::Vector{Level} = [Level(L[i],100-P[i],i-1) for i in 1:N]
    sort!(ll); return [x.id for x in ll]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N::I = gi(); L::VI = gis(); P::VI = gis()
        ans = solve(N,L,P)
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

