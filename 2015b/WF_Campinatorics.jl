
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

function prework()
    m::I             = 1_000_000_007
    fact::VI         = fill(0,1_000_000)
    factinv::VI      = fill(0,1_000_000)
    derangements::VI = fill(0,1_000_000)
    t::I = 1
    for i in 1:1000000; t = (t*i) % m; fact[i] = t; end
    t = 1
    for i in 1:1000000; t = (t * invmod(i,m)) % m; factinv[i] = t; end
    derangements[1] = 0
    derangements[2] = 1
    for i in 3:1000000
        t = (derangements[i-1]+derangements[i-2])%m
        derangements[i] = ((i-1) * t ) % m
    end
    return (fact,factinv,derangements)
end

function solve(N::I,X::I,working)
    (fact::VI,factinv::VI,derangements::VI) = working
    m = 1_000_000_007
    ans::I = 0
    for x in X:N
        ## Answer for x is C(N,x) * N!/(N-x)! * (N-x)! * !(N-x)
        ##  = N! / x! / (N-x)! * N! / (N-x)! * (N-x)! * !(N-x)
        ##  = N! * N! / x! /(N-x)! * !*(N-x)
        t::I = 1
        t = (t * (N==0 ? 1 : fact[N])) % m
        t = (t * (N==0 ? 1 : fact[N])) % m
        t = (t * (x==0 ? 1 : factinv[x])) % m
        t = (t * (x==N ? 1 : factinv[N-x])) % m
        t = (t * (x==N ? 1 : derangements[N-x])) % m
        ans = (ans + t) % m
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = prework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,X = gis()
        ans = solve(N,X,working)
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

