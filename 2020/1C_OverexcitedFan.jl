
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

function solve(X::I,Y::I,M::String)::I
    d::I = 0
    for (i::I,m::Char) in enumerate(M)
        if m == 'W'; X -= 1; end
        if m == 'E'; X += 1; end
        if m == 'N'; Y += 1; end
        if m == 'S'; Y -= 1; end
        d += 1
        if abs(X) + abs(Y) <= d; return i; end
    end
    return -1
end    

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        inp::VS = gss()
        X = parse(Int64,inp[1])
        Y = parse(Int64,inp[2])
        M = inp[3]
        ans = solve(X,Y,M)
        if ans == -1; println("IMPOSSIBLE"); else; println(ans); end

    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

