
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
    #print("DBG: len(primes) = $(length(primes))\n")
    countarr::VI = fill(0,95)
    lcountarr::VI = fill(0,95)
    ptr::I = 1
    sump::I = 0
    for i in 1:M
        while primes[ptr] < P[i]; ptr += 1; end
        countarr[ptr] += N[i]; sump += P[i]*N[i]
    end
    for score::I in sump:-1:1
        left::I = score
        fill!(lcountarr,0)
        lsump::I = 0
        primeptr::I = 1
        done::Bool = false
        while !done && primeptr <= 95 && left > 1
            while left % primes[primeptr] == 0
                lsump += primes[primeptr]
                lcountarr[primeptr] += 1
                left = left ÷ primes[primeptr]
                if lsump + score > sump; done = true; break; end
                if lcountarr[primeptr] > countarr[primeptr]; done = true; break; end 
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

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

