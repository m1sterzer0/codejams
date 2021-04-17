
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
### a) We define Q(N,K) as the probability of the room being VACANT at the end
### b) We can define a recurrance for Q(N,K) by considering the smaller subproblems that result
###    after placing exactly one entry
###
###    Q(N,K) = 1/(N-1) * sum_i_1_n-1 (i > K ? Q(i-1,K) : i < k-1 ? Q(N-i-1,K-i-1) : 0)
###
### c) Making a quick loop to print these out for all N < 20 (thank goodness for rational math in julia)
###    reveals some interesting numerators that keep showing up.  In fact, it doesn't take long to 
###    hypothesize that Q(N,K) = Q(K,1) * Q(N-k+1,1). Running said code over the first 20 entries
###    makes this check out.
###
### d) Now we need a quick way to calculate Q(N,1).  However, if we look at formula above, it simplifies
###    if we just care about the endpoints.
###    Q(N,1) = 1/N-1 * sum_i_2_n-1 Q(i-1,1).  Thus
###    Q(3,1) = 1/2 * (Q(1,1))
###    Q(4,1) = 1/3 * (Q(1,1) + Q(2,1))
###    Q(5,1) = 1/4 * (Q(1,1) + Q(2,1) + Q(3,1))
###    ...
###    Thus, we can just keep a running sum and calculate this for all N.
###
### e) To deal with the modular inverses, we just use fermat's little theorem, and node
###    a^(p-1) % p == 1, so a^(p-2) is the multiplicative modular inverse of a.  This can being
###    calculated in logarithmic time
######################################################################################################

function calcq(n::I,p::I)
    q::VI = [1,0,invmod(2,p)]
    sizehint!(q,10000000)
    s1::I,s0::I = 1, (1 + invmod(2,p)) % p
    for i::I in 4:n
        a::I = (s1 * invmod(i-1,p)) % p
        push!(q,a)
        s1,s0 = s0, (a+s0)%p
    end
    return q
end

function solve(n::I,k::I,working)::I
    (q::VI,) = working
    p::I = 10^9+7
    vacantProb = q[k] * q[n-k+1] % p
    ans = 1 - vacantProb
    return ans < 0 ? ans + p : ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    p::I = 10^9+7
    q::VI = calcq(10000000,p)
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        n,k = gis()
        ans = solve(n,k,(q,))
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

