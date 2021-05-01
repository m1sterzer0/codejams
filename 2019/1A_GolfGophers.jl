
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

function solve(N::I,M::I)
    res::VI = fill(0,6)
    for (i,x) in enumerate([17,16,15,13,11,7])
        println(join(fill(x,18)," ")); flush(stdout)
        pos::VI = gis()
        res[i] = sum(pos) % x
    end
    for i in 1:M
        good = true
        for (j,x) in enumerate([17,16,15,13,11,7])
            if i % x != res[j]; good = false; break; end
        end
        if good; print("$i\n"); flush(stdout); return; end
    end
    print("0\n"); flush(stdout)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt,N,M = gis()
    for qq in 1:tt
        solve(N,M)
        res = gi(); if res != 1; exit(0); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

