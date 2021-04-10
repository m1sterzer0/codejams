
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

function solve(M::I,P::VI,N::VI)
    sieve = fill(true,500)
    sieve[1] = false
    for i in 4:2:500; sieve[i] = false; end
    for i in 3:2:500
        if sieve[i]
            for j in 3*i:2*i:500; sieve[j] = false; end
        end
    end
    primes::VI = [i for i in 1:500 if sieve[i]]

    ## sum(N) <= 10^15
    ## --> sum(P_i * N_i) <= 499 * 10^15 =~ 4.99 * 10^17
    ## Note 2^59 =~ 5.76 * 10^17, so there are no more than 59 cards in the product pile
    ## This means the sum of the numbers in the "product pile" is no more than 499*59 = 29441
    ## Thus, we only need to check the possible sums from sum(P_i*N_I) down to sum(P_I*N_I)-29441

    countarr::VI = fill(0,95)
    lcountarr::VI = fill(0,95)
    ptr::I = 1
    sump::I = 0
    for i in 1:M
        while primes[ptr] < P[i]; ptr += 1; end
        countarr[ptr] += N[i]; sump += P[i]*N[i]
    end
    for score::I in sump:-1:max(1,sump-29441)
        lcountarr .= countarr
        left::I = score
        lsump::I = 0
        primeptr::I = 1
        done::Bool = false
        while !done && primeptr <= 95 && left > 1
            p::I = primes[primeptr]
            while (left ÷ p) * p == left
                if lcountarr[primeptr] == 0; done = true; break; end
                lsump += p; lcountarr[primeptr] -= 1; left ÷= p
                if lsump + score > sump; done = true; break; end
                if left == 1
                    if lsump + score == sump; return score; end
                    done = true; break
                end
            end
            primeptr += 1
        end
    end
    return 0
end

function gencase(sumNmin::I,sumNmax::I,Mmin::I,Mmax::I)

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29,
              31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
              73, 79, 83, 89, 97, 101, 103, 107, 109, 113,
              127, 131, 137, 139, 149, 151, 157, 163, 167, 173,
              179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
              233, 239, 241, 251, 257, 263, 269, 271, 277, 281,
              283, 293, 307, 311, 313, 317, 331, 337, 347, 349,
              353, 359, 367, 373, 379, 383, 389, 397, 401, 409,
              419, 421, 431, 433, 439, 443, 449, 457, 461, 463,
              467, 479, 487, 491, 499 ]
    M = rand(Mmin:Mmax)
    pset = Set{Int64}(primes)
    while length(pset) > M; p = rand(pset); delete!(pset,p); end
    P::VI = sort([x for x in pset])
    N = fill(1,M)
    sumN = rand(sumNmin:sumNmax)-M
    pos::VI = []
    while (sumN > 0)
        empty!(pos)
        for i in 1:1000; push!(pos,min(i,sumN)); push!(pos,(sumN+i-1)÷i); end
        idx = rand(1:M)
        v = rand(pos)
        N[idx] += v
        sumN -= v
    end
    return (M,P,N)
end

function test(ntc::I,sumNmin::I,sumNmax::I,Mmin::I,Mmax::I)
    for ttt in 1:ntc
        (M,P,N) = gencase(sumNmin,sumNmax,Mmin,Mmax)
        ans = solve(M,P,N)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        M = gi()
        P::VI = fill(0,M)
        N::VI = fill(0,M)
        for i in 1:M; P[i],N[i] = gis(); end
        ans = solve(M,P,N)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(100,100,200,1,95)
#test(100,1000,10000,1,95)
#test(100,10000,100000,1,95)
#test(100,100000,1000000,1,95)
#test(100,1_000_000,1_000_000_000,1,95)
#test(100,100_000_000_000_000,1_000_000_000_000_000,1,95)
#test(100,100_000_000_000_000,1_000_000_000_000_000,1,10)
#test(100,100_000_000_000_000,1_000_000_000_000_000,90,95)



