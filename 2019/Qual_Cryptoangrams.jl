
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

function solve(N::BigInt,L::I,A::Vector{BigInt})::String
    aa::Vector{BigInt} = fill(BigInt(0),L+1)
    i::I = 1; while A[i] == A[i+1]; i += 1; end
    aa[i+1] = gcd(A[i],A[i+1])
    for j in i:-1:1; aa[j] = A[j] ÷ aa[j+1]; end
    for j in i+2:L+1; aa[j] = A[j-1] ÷ aa[j-1]; end
    primes::Vector{BigInt} = unique(sort(aa))
    ansarr::VC = []
    for i in 1:L+1
        for (j,p) in enumerate(primes)
            if aa[i] == p; push!(ansarr,'A'+j-1); end
        end
    end
    return join(ansarr)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        xx::VS = gss()
        N = parse(BigInt,xx[1])
        L = parse(Int64,xx[2])
        A::Vector{BigInt} = [parse(BigInt,x) for x in gss()]
        ans = solve(N,L,A)
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

