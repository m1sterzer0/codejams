
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

####################################################################################################
## 0) We will binary search on the number of days we can afford.  This means that instead we solve
##    the problem for the cheapest cost to provide NN meals.
## 1) DEFINITIONS:
##    a) SD(x) be the minimum cost of a meal (w/o) delivery charges that is good for at least x
##       days.  Note that SD should be a non-decreasing function.
##    b) SDC(n) is the minimum cost of n-days worth of meals is F+SD(0)+SD(1)+SD(2)+...+SD(n-1)
## 2) CLAIM 1: SDC(n) + SDC(n+a) >= SDC(n+1) + SDC(n+a-1) for a > 1.
##        This is a consequence of monotonicity.  The implication is that we only need to consider
##        cases where the delivery sizes differ by at most 1
## 4) CLAIM 2: If SD(a) == SD(a+1) == ... == SD(b), we can solve analytically for the optimal
##    number of deliveries at minimum cost with delivery sizes between a and b inclusive.
##    -- numd_max = NN/a.  numd_min = NN/b
##    -- Inside these extremes, we have
##       cost = numd * (F + sum(SD)_1_(a-1)) + (NN-numD*(a-1)) * SD(a) = c0 * numD + c1.
##       Since this is linear, we only need to check the endpoints.
## 5) CLAIM 2B: similarly, if SD(a) = A and SD(a+1) = B, we can also solve analytically for the
##    optimal number of deliveries at minimum cost
##    -- numd_max = NN/a.  numd_min = NN/(a+1)
##    -- Inside these extremes, we have
##       cast = numd * (F + sum(SD)_1_a) + (NN-numD*a) * SD(a+1) = c0 * numD + c1
##       which is again linear, so it suffices to check the endpoints
####################################################################################################

struct Meal; p::I; s::I; end
Base.isless(a::Meal,b::Meal) = a.p < b.p

function solve(M::I,F::I,N::I,P::VI,S::VI)::I
    Gorig::Vector{Meal} = []
    for i in 1:N; push!(Gorig,Meal(P[i],S[i])); end
    sort!(Gorig)

    ## Use a stack to reject clearly unoptimal meals
    G::Vector{Meal} = []
    for m in Gorig
        if !isempty(G) && m.s <= G[end].s; continue; end
        while !isempty(G) && m.p == G[end].p && m.s >= G[end].s; pop!(G); end
        push!(G,m)
    end

    ## Binary search for number of days of food
    l,u=0,1_000_000_000_000_000_001
    while (u-l) > 1
        m = (u+l) >> 1

        ## Calculate the cost of m days of food
        bestcost::Int128 = Int128(10)^36 + 1
        lastsize::I,lastcost::Int128 = 0,0
        for (i,mm) in enumerate(G)
            minsize = lastsize; maxsize = min(m,mm.s+1)
            numdmin = (m + maxsize - 1) ÷ maxsize; numdmax = m ÷ max(1,minsize)
            for numd in (numdmin,numdmax)
                if numd*lastsize > m; continue; end
                if Int128(m - numd*lastsize) > Int128(numd) * Int128(maxsize-minsize); continue; end
                cost::Int128 = (Int128(F) + lastcost) * Int128(numd) + Int128(mm.p) * Int128(m - numd * lastsize)
                bestcost = min(cost,bestcost)
            end
            lastcost += mm.p * (maxsize-lastsize)
            lastsize = maxsize
            if lastsize >= m; break; end
        end

        if bestcost > Int128(M); u = m; else l = m; end
    end
    return l
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        M,F,N = gis()
        P::VI = fill(0,N)
        S::VI = fill(0,N)
        for i in 1:N; P[i],S[i] = gis(); end
        ans = solve(M,F,N,P,S)
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

