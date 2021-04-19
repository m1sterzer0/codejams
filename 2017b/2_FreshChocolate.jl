
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

function solve(N::I,P::I,G::VI)
    rem::VI = fill(0,P)
    for g::I in G
        x::I = g % P
        if x == 0; x = P; end
        rem[x] += 1
    end
    ans = rem[P]
    if P == 2
        ans += (rem[1] + 1) ÷ 2
    elseif P == 3
        p1::I = min(rem[1],rem[2])
        ans += p1; rem[1] -= p1; rem[2] -= p1
        ans += (2 + max(rem[1],rem[2])) ÷ 3
    else  ## P == 4
        p1 = min(rem[1],rem[3])
        ans += p1; rem[1] -= p1; rem[3] -= p1
        p2 = rem[2] ÷ 2
        ans += p2; rem[2] -= 2 * p2
        remaining = rem[1] + rem[2] + rem[3]
        if rem[2] == 1 && remaining >= 3
            ans += 1; remaining -= 3
        end
        ans += (remaining + 3) ÷ 4
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = gis()
        G::VI = gis()
        ans = solve(N,P,G)
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

