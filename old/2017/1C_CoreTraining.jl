using Printf

######################################################################################################
### This is tougher.  We need to reason.
### 1) Let's try to figure out if it is better to choose to incrementally increase unit i or unit j.
###    WLOG, assume p1 > p2.
###    Define some variables.
###    -- X  = probability of success
###    -- X1 = probability of >= K of the *other* units working
###    -- X2 = probability of exactly K-1 of the *other* units work
###    -- X3 = probability of exactly K-2 of the *other* units work
###    Then X = X1 + X2 * (p1 + p2 - p1p2) + X3 * p1 * p2 
###    dX/dp1 = X2 * (1 - p2) + X3 * p2 = X2 + (X3 - X2) p2
###    dX/dp2 = X2 * (1 - p1) + X3 * p1 = X2 + (X3 - X2) p1
###   
###    This observation leads to 2 cases:
###        (X3 - X2) > 0 ---> we should increase p2 up to p1 == p2
###        (X3 - X2) < 0 ---> we should increase p1 all the way to 1.00 before we every consider increasing p2
###
###    Note that the top case is the one that happens when N == K, since there X2 = 0'
###
### 2) Now consider the case that p1 > p2 and p1 is the current "BEST" item to improve
###    Then we have dX/dp1 > dX/dp2 --> (X3-X2) p2 > (X3-X2) p1 --> (X3-X2) (p2 - p1) > 0 --> X3-X2 < 0
###    --> we should increase p1 all the way up to 1.00 before we even consider increasing p2. 
###
### 3) This suggests (but doesn't quite prove) the following algorithm.
###    While there are still units left to give
###    -- Figure out which index gives us the "best" return on our investment
###    -- Improve all of these up to the top just as we did in the small case.
###
### 4) (Had to look at the solutions for this part) The "working" algorithm is to choose to the "top N"
###    paths and improve them just as in the small case.  The "proof" offered in the analysis is far
###    from any sort of proof -- so many holes:
###    -- Falls apart with "zero" probabilities.
###    -- Doesn't adequately cover the "equals" case.
###    -- Doesn't cover the order that things should be improved.
###    Anyway, I think it is ambitious to discover this analytically -- perhaps by trial and error.
###    I'll implement it below.
######################################################################################################

function calcProb(P,N,K)
    A = zeros(N+1,N+1)
    A[1,1] = 1.0
    for i in 1:N
        A[i+1,1] = A[i,1] * (1 - P[i])
        for j = 1:N
            A[i+1,j+1] = A[i,j] * P[i] + A[i,j+1] * (1 - P[i])
        end
    end
    res = sum(A[N+1,i] for i in K+1:N+1 )
    return res
end

function allocate(P,U,N,sidx)
    xx = sum(x->1.00-x, P[sidx:end])
    if sidx > 1 && xx <= U
        P2 = copy(P)
        P2[sidx:end] .= 1.000
        P2[sidx-1] = min(1.000, P2[sidx-1] + (U-xx)) 
        return P2
    else
        lb = P[sidx]; ub = 1.000
        while (ub-lb) > 1e-10
            m = (ub+lb) * 0.5
            yy = sum(x->max(0.00,m-x),P[sidx:end])
            (lb,ub) = (yy < U) ? (m,ub) : (lb,m)
        end
        m = (ub+lb) * 0.5
        P2 = copy(P)
        P2[sidx:end] = [max(m,x) for x in P2[sidx:end]]
        return P2
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        U = parse(Float64,rstrip(readline(infile)))
        P = [parse(Float64,x) for x in split(rstrip(readline(infile)))]

        ## Not convinced theoretically why this work, but i'll code it Anyway
        Pref = copy(P)
        sort!(Pref)
        cumsum = zeros(N+1)
        best = 0.00
        for i in 1:N; cumsum[i+1] = cumsum[i] + (1.00-Pref[i]); end
        for i in 1:N
            if i > 1 && cumsum[end] - cumsum[i-1] < U; break; end ## Don't need to do better
            Pwork = allocate(Pref,U,N,i)
            best = max(best,calcProb(Pwork,N,K))
        end
        @printf("%.8f\n",best)
    end
end

main()
