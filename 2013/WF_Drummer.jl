
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

struct Pt; x::I; y::I; end
convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) <= 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) >= 0
function convexHull(a::Vector{Pt})
    mycmp(aa::I,bb::I)::Bool = convexHullCmp(a[aa],a[bb])
    mycw(aa::I,bb::I,cc::I) = convexHullCw(a[aa],a[bb],a[cc])
    myccw(aa::I,bb::I,cc::I) = convexHullCcw(a[aa],a[bb],a[cc])
    N = length(a)
    if length(a) == 1; return [1]; end
    aidx = collect(1:N)
    sort!(aidx,lt=mycmp)
    p1::I,p2::I = aidx[1],aidx[end]
    up::VI = []; down::VI = []
    push!(up,p1); push!(down,p1)
    for i in 2:length(aidx)
        if i == length(aidx) || mycw(p1,aidx[i],p2)
            while length(up) >= 2 && !mycw(up[end-1], up[end], aidx[i]); pop!(up); end
            push!(up,aidx[i])
        end
        if i == length(aidx) || myccw(p1,aidx[i],p2)
            while length(down) >= 2 && !myccw(down[end-1],down[end],aidx[i]); pop!(down); end
            push!(down,aidx[i])
        end
    end
    return vcat(up,down[end-1:-1:2])
end

## The key observation is that the optimal tempo must
## be defined by 2 of the points.
function trytempo(num::I,denom::I,NN::VI)::F
    mine::F = 1e99; maxe::F = -1e99
    N::I = length(NN)
    inc::F = num/denom
    cur::F = 0
    for i in 1:N
        cur += inc
        err = cur - NN[i]
        if err < mine; mine = err; end
        if err > maxe; maxe = err; end
    end
    return 0.5*(maxe-mine)
end

function solveSmall(N::I,NN::VI)::F
    best = 1e99
    for i::I in 1:N-1
        for j::I in i+1:N
            b = trytempo(NN[j]-NN[i],j-i,NN)
            best = min(best,b)
        end
    end
    return best
end

function solveLarge(N::I,NN::VI)::F
    error = trytempo(NN[2]-NN[1],2-1,NN)
    if error < 1e-7; return 0.00; end
    pts::Vector{Pt} = [Pt(i,NN[i]) for i in 1:N]
    hull::VI = convexHull(pts)
    lh = length(hull)
    best = 1e99
    for i in 1:lh
        p1,p2 = hull[i],hull[i==lh ? 1 : i+1]
        if p2 < p1; (p1,p2) = (p2,p1); end
        b = trytempo(NN[p2]-NN[p1],p2-p1,NN)
        best = min(best,b)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        NN = gis()
        #ans = solveSmall(N,NN)
        ans = solveLarge(N,NN)
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

