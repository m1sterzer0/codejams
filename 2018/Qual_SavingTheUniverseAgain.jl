
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

function solve(D::Int64,P::String)
    cnt::VI = fill(0,30); idx::I = 1; tot::I = 0; pv::I = 1
    for c in P
        if c == 'C'; idx += 1; pv *= 2; end
        if c == 'S'; tot += pv; cnt[idx] += 1; end
    end
    moves::I = 0
    if tot <= D; return "0"; end
    for ii in idx:-1:2
        xx = cnt[ii]
        for jj in 1:xx
            moves += 1; tot -= (pv÷2); cnt[ii] -= 1; cnt[ii-1] += 1
            if tot <= D; return "$moves"; end
        end
        pv ÷= 2
    end
    return "IMPOSSIBLE"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        xx::VS = gss()
        D = parse(Int64,xx[1])
        P::String = xx[2]
        ans = solve(D,P)
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

