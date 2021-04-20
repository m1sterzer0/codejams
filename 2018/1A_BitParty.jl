
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
### We do a binary search on the time and figure out whether that work.
######################################################################################################

function check(t::I,R::I,B::I,C::I,M::VI,S::VI,P::VI)::Bool
    bitsPerCashier = [max(0,min(M[i],(t-P[i])÷S[i])) for i in 1:C]
    reverse!(sort!(bitsPerCashier))
    b = sum(bitsPerCashier[1:R])  ## bitsPerCashier capped at 10^9, so the sum is capped at 10^12
    return b >= B
end

function solve(R::I,B::I,C::I,M::VI,S::VI,P::VI)::I
    (l::I,u::I) = (0,typemax(Int64))
    while u-l > 1
        m::I = (u+l) ÷ 2
        (l,u) = check(m,R,B,C,M,S,P) ? (l,m) : (m,u)
    end
    return u
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,B,C = gis()
        M::VI = fill(0,C)
        S::VI = fill(0,C)
        P::VI = fill(0,C)
        for i in 1:C; M[i],S[i],P[i] = gis(); end
        ans = solve(R,B,C,M,S,P)
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

