
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

function mobiusSieve(n::I)::Vector{Int8}
    mu::Vector{Int8} = fill(Int8(1),n)
    isPrime::Vector{Bool} = fill(true,n)

    ### Do the evens
    isPrime[4:2:n] .= false
    for i::I in 2:2:n; mu[i] = -mu[i]; end
    for i::I in 4:4:n; mu[i] = 0; end

    for i::I in 3:2:n
        if !isPrime[i]; continue; end
        for j::I in i*i:2*i:n; isPrime[j] = false; end
        for j::I in i:i:n;     mu[j] = -mu[j];     end
        for j::I in i*i:i*i:n; mu[j] = 0;          end
    end

    return mu
end

function intSqrt(k::I)::I
    if k == 0; return 0; end
    if k == 1; return 1; end
    lb::I,ub::I = 1,1000001
    while ub-lb > 1
        mid::I = (lb+ub) ÷ 2
        (lb,ub) = mid*mid <= k ? (mid,ub) : (lb,mid)
    end
    return lb
end

function countPoints(sqlim::I,rsq::I)::I
    res::I = 0
    ymax::I = sqlim
    for x::I in 0:sqlim 
        ylim2::I = rsq - x*x
        if ylim2 < 0; break; end
        while ymax*ymax > ylim2; ymax -=1; end
        res += (ymax+1)
    end
    return res-1 ## skip (0,0)
end

function solve(N::I,R::I,working)::I
    (mu::Vector{Int8},) = working
    M = 1000000
    maxd2::I = (M*M-1) ÷ (R*R)
    maxd::I = min(intSqrt(maxd2),N-1)
    ans::I = 0
    for d in 1:maxd
        if mu[d] != 0
            ans += countPoints(maxd ÷ d, maxd2 ÷ (d*d)) * mu[d]
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    mu = mobiusSieve(10^6)
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,R = gis()
        ans = solve(N,R,(mu,))
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

