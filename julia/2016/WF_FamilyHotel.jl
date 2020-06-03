using Printf

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

function modadd(a::Int64,b::Int64,m::Int64)
    s = a + b
    return s > m ? s-m : s
end

function modsub(a::Int64,b::Int64,m::Int64)
    s = a - b
    return s < 0 ? s + m : s
end

function modmult(a::Int64,b::Int64,m::Int64)
    return (a*b) % m
end

### This version only works for a prime modulus
function modinv(a::Int64,p::Int64)
    ans::Int64, factor::Int64, e::Int64 = [1,a,p-2]
    while (e > 0) 
        if e & 1 ≠ 0; ans = modmult(ans,factor,p); end
        factor = modmult(factor,factor,p)
        e = e >> 1
    end
    return ans
end

function calcq(n,p)
    q = [1,0,modinv(2,p)]
    sizehint!(q,10000000)
    s1,s0 = [1, modadd(1,modinv(2,p),p)]
    for i in 4:n
        a = modmult(modinv(i-1,p),s1,p)
        push!(q,a)
        s1,s0 = s0,modadd(a,s0,p)
    end
    return q
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    p = 1000000007
    q  = calcq(10000000,p)
    for qq in 1:tt
        print("Case #$qq: ")
        n,k = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        vacantProb = modmult(q[k],q[n-k+1],p)
        ans = modsub(1,vacantProb,p)
        print("$ans\n")
    end
end

main()