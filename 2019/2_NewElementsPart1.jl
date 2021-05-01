
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

function solve(N::I,C::VI,J::VI)
    s::SPI = SPI()
    for (i,j) in Iterators.product(1:N,1:N)
        if i >= j; continue; end
        if C[i] >= C[j] && J[i] >= J[j]; continue; end
        if C[j] >= C[i] && J[j] >= J[i]; continue; end
        (x,y) = (abs(C[i]-C[j]),abs(J[i]-J[j]))
        g::I = gcd(x,y)
        push!(s,(x÷g,y÷g))
    end
    return length(s)+1
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        C::VI = fill(0,N)
        J::VI = fill(0,N)
        for i in 1:N; C[i],J[i] = gis(); end
        ans = solve(N,C,J)
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

