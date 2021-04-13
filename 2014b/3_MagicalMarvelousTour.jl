
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

function solve(N::I,p::I,q::I,r::I,s::I)::F
    tt::VI = [((i*p+q) % r) + s for i in 0:N-1]
    ttsum::I = sum(tt)
    best::I = ttsum
    l::I,r::I,ls::I,ms::I,rs::I = 1,0,0,0,ttsum
    for l in 1:N
        if r < l; r += 1; ms += tt[r]; rs -= tt[r]; end
        while(r < N && max(ls,ms+tt[r+1],rs-tt[r+1]) < max(ls,ms,rs))
            r += 1; ms += tt[r]; rs -= tt[r]
        end
        best = min(best,max(ls,ms,rs))
        ls += tt[l]
        ms -= tt[l]
    end
    return float(ttsum-best) / float(ttsum)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,p,q,r,s = gis()
        ans = solve(N,p,q,r,s)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
