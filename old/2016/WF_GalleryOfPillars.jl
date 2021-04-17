using Printf

######################################################################################################
### 1) In order for a pillar not to be blocked, it needs to be on a pair of relatively prime
###    coordinates.
###
### 2) The distance from a point (a,b) to a line from (0,0) to (x,y) is given by
###    d^2 = (ay-bx)^2 / (x^2+y^2).  In order for this not to intersect the pillar, we
###    must have d > (R/1e6) --> d^2 > (R/1e6)^2 --> (ay-bx)^2 / (x^2+y^2) >= (R/1e6)^2.
###
### 3) If we only consider relatively prime x,y, we can always find a,b such that ay-bx = 1.
###    Thus, we mst have that (x^2+y2) * R^2 < 1e12.  As a correlary, this means that we don'that
###    have to consider coordinates bigger than 1000000 (the 10^9 was a red herring)
###
### 4) Now to count all of the relatively prime pairs exactly once, we do a bit of inclusion/exclusion
###    * Count all the points that are multiples of 1
###    * Subtract all of the multiples of 2,3,5
###    * Add all of the multiples of 6
###    * Subtract all of the multiples of 7
###    * Add all of the multiples of 10
###    We can use the mobius function (using a sieve) to deal with the inclusion/exclusion
###    https://artofproblemsolving.com/wiki/index.php/Mobius_function
######################################################################################################

function mobiusSieve(n::Int64)
    mu = fill(Int8(1),n)
    isPrime = fill(true,n)

    ### Do the evens
    isPrime[4:2:n] .= false
    for i in 2:2:n; mu[i] = -mu[i]; end
    for i in 4:4:n; mu[i] = 0; end

    for i in 3:2:n
        if !isPrime[i]; continue; end
        for j in i*i:2*i:n; isPrime[j] = false; end
        for j in i:i:n;     mu[j] = -mu[j];     end
        for j in i*i:i*i:n; mu[j] = 0;          end
    end

    return mu
end

function intSqrt(k::Int64)
    if k == 0; return 0; end
    if k == 1; return 1; end
    lb::Int64,ub::Int64 = 1,1000001
    while ub-lb > 1
        mid = (lb+ub) ÷ 2
        (lb,ub) = mid*mid <= k ? (mid,ub) : (lb,mid)
    end
    return lb
end

function countPoints(sqlim::Int64,rsq::Int64)
    res = 0
    ymax = sqlim
    for x in 0:sqlim 
        ylim2 = rsq - x*x
        if ylim2 < 0; break; end
        while ymax*ymax > ylim2; ymax -=1; end
        res += (ymax+1)
    end
    return res-1 ## skip (0,0)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    mu = mobiusSieve(1000000)
    for qq in 1:tt
        print("Case #$qq: ")
        M = 1000000
        N,R = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        maxd2 = (M*M-1) ÷ (R*R)
        maxd = min(intSqrt(maxd2),N-1)
        ans = 0
        for d in 1:maxd
            if mu[d] != 0
                ans += countPoints(maxd ÷ d, maxd2 ÷ (d*d)) * mu[d]
            end
        end
        print("$ans\n")
    end
end

main()