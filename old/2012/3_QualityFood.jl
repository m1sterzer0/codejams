####################################################################################################
## 0) We will binary search on the number of days we can afford.  This means that instead we solve
##    the problem for the cheapest cost to provide NN meals.
## 1) DEFINITIONS:
##    a) SD(x) be the minimum cost of a meal (w/o) delivery charges that is good for at least x
##       days.  Note that SD should be a non-decreasing (monotonic increasing, but not strictly
##       increasing) function.
##    b) SDC(n) is the minimum cost of n-days worth of meals is F+SD(0)+SD(1)+SD(2)+...+SD(n-1)
## 2) CLAIM 1: SDC(n) + SDC(n+a) >= SDC(n+1) + SDC(n+a-1) for a > 1.
##        Left side unique term  is SD(n+a).  Right side unique term is SD(n+1).  Then employ
##        SD monotonicity
##    Implication -- we only need to consider cases where the delivery sizes differ by at most 1
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
struct Meal; p::Int64; s::Int64; end
Base.isless(a::Meal,b::Meal) = a.p < b.p

function solve(NN::Int64,F::Int64,G::Vector{Meal})
    ##print("DBG: solve(NN:$NN, F:$F, G)\n")
    ans::Int128 = Int128(10)^36 + 1
    lastsize::Int64,lastcost::Int128 = 0,0
    for (i,mm) in enumerate(G)
        ## First cover the case where we are the "a+1" term
        minsize = lastsize
        maxsize = min(NN,mm.s+1)
        numdmin = (NN + maxsize - 1) ÷ maxsize
        numdmax = NN ÷ max(1,minsize)
        for numd in (numdmin,numdmax)
            if numd*lastsize > NN; continue; end
            if Int128(NN - numd*lastsize) > Int128(numd) * Int128(maxsize-minsize); continue; end
            cost::Int128 = (Int128(F) + lastcost) * Int128(numd) + Int128(mm.p) * Int128(NN - numd * lastsize)
            ans = min(cost,ans)
            ##print("DBG:  mm.p:$(mm.p) mm.s:$(mm.s) minsize:$minsize maxsize:$maxsize numdmin:$numdmin numdmax:$numdmax NN-numd*lastsize:$(NN-numd*lastsize) cost:$cost ans:$ans\n")
        end
        lastcost += mm.p * (maxsize-lastsize)
        lastsize = maxsize
        if lastsize >= NN; break; end
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        M,F,N = gis()
        Gorig::Vector{Meal} = []
        for i in 1:N; p,s = gis(); push!(Gorig,Meal(p,s)); end
        sort!(Gorig)
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
            cost::Int128 = solve(m,F,G)
            if cost > Int128(M); u = m; else l = m; end
        end
        print("$l\n")
    end
end

main()