
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

mutable struct UnsafeIntPerm; n::I; r::I; indices::VI; cycles::VI; end
Base.eltype(iter::UnsafeIntPerm) = Vector{Int64}
function Base.length(iter::UnsafeIntPerm)
    ans::I = 1; for i in iter.n:-1:iter.n-iter.r+1; ans *= i; end
    return ans
end
function unsafeIntPerm(a::VI,r::I=-1) 
    n = length(a)
    if r < 0; r = n; end
    return UnsafeIntPerm(n,r,copy(a),collect(n:-1:n-r+1))
end
function Base.iterate(p::UnsafeIntPerm, s::I=0)
    n = p.n; r=p.r; indices = p.indices; cycles = p.cycles
    if s == 0; return(n==r ? indices : indices[1:r],s+1); end
    for i in (r==n ? n-1 : r):-1:1
        cycles[i] -= 1
        if cycles[i] == 0
            k = indices[i]; for j in i:n-1; indices[j] = indices[j+1]; end; indices[n] = k
            cycles[i] = n-i+1
        else
            j = cycles[i]
            indices[i],indices[n-j+1] = indices[n-j+1],indices[i]
            return(n==r ? indices : indices[1:r],s+1)
        end
    end
    return nothing
end

struct Pt; x::I; y::I; end

function getArea(ptarr::Vector{Pt}):F
    N::I = length(ptarr); aa::F = 0.0
    for i in 1:N
        j = i == N ? 1 : i+1
        aa += ptarr[i].x*ptarr[j].y - ptarr[i].y*ptarr[j].x
    end
    return abs(0.5*aa)
end

function getcpdpq(a::Pt,b::Pt)::TI
    dp = a.x*b.x+a.y*b.y
    cp = a.x*b.y-a.y*b.x
    q = (cp == 0 && dp > 0) ? 0 : dp > 0 ? 1 : dp == 0 ? 2 : (cp == 0 && dp < 0) ? 4 : 3
    return (dp,cp,q)
end

## Segment intersection -- adapted from Geeks4Geeks code
## -- segIntersectOnSegment -- Given three colinear points p, q, r, checkif q is on line segment 'pr'
## -- segIntersectOrientation -- Orientation of (p,q,r) 0->colinear.  1->clockwise.  2->counterclockwise  
segIntersectOnSegment(p::Pt,q::Pt,r::Pt)::Bool = (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && 
                                                  q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y))
function segIntersectOrientation(p::Pt,q::Pt,r::Pt)::Int64
    val::Int64 = (q.y-p.y) * (r.x-q.x) - (q.x-p.x) * (r.y-q.y);
    return val < 0 ? 1 : val > 0 ? 2 : 0
end
## Checks if p1--q1 and p2--q2 intersect
function segIntersect(p1::Pt,q1::Pt,p2::Pt,q2::Pt)::Bool
    o1::Int64 = segIntersectOrientation(p1,q1,p2)
    o2::Int64 = segIntersectOrientation(p1,q1,q2)
    o3::Int64 = segIntersectOrientation(p2,q2,p1)
    o4::Int64 = segIntersectOrientation(p2,q2,q1)
    if (o1 != o2 && o3 != o4); return true; end
    if (o1 == 0 && segIntersectOnSegment(p1,p2,q1)); return true; end
    if (o2 == 0 && segIntersectOnSegment(p1,q2,q1)); return true; end
    if (o3 == 0 && segIntersectOnSegment(p2,p1,q2)); return true; end
    if (o4 == 0 && segIntersectOnSegment(p2,q1,q2)); return true; end
    return false
end

convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) <= 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) >= 0
function convexHull(a::Vector{Pt})
    mycmp(aa::Int64,bb::Int64)::Bool = convexHullCmp(a[aa],a[bb])
    mycw(aa::Int64,bb::Int64,cc::Int64) = convexHullCw(a[aa],a[bb],a[cc])
    myccw(aa::Int64,bb::Int64,cc::Int64) = convexHullCcw(a[aa],a[bb],a[cc])
    N = length(a)
    if length(a) == 1; return [1]; end
    aidx = collect(1:N)
    sort!(aidx,lt=mycmp)
    p1::Int64,p2::Int64 = aidx[1],aidx[end]
    up::Vector{Int64} = []
    down::Vector{Int64} = []
    push!(up,p1)
    push!(down,p1)
    for i in 2:length(aidx)
        if i == length(aidx) || mycw(p1,aidx[i],p2)
            while length(up) >= 2 && !mycw(up[end-1], up[end], aidx[i]); pop!(up); end
            push!(up,aidx[i])
        end
        if i == length(aidx) || myccw(p1,aidx[i],p2)
            #print("DBG: down:$down aidx:$aidx\n")
            while length(down) >= 2 && !myccw(down[end-1],down[end],aidx[i]); pop!(down); end
            push!(down,aidx[i])
        end
    end
    return up,down
end

function checkForBacktracks(N::I,ptarr::Vector{Pt})::Bool
    for j in 1:N
        i = j == 1 ? N : j - 1
        k = j == N ? 1 : j + 1
        a::Pt = Pt(ptarr[i].x-ptarr[j].x,ptarr[i].y-ptarr[j].y)
        b::Pt = Pt(ptarr[k].x-ptarr[j].x,ptarr[k].y-ptarr[j].y)
        (dp,cp,q) = getcpdpq(a,b)
        if q == 0; return true; end
    end
    return false
end

function checkForIntersections(N::I,ptarr::Vector{Pt})::Bool
    for i in 1:N
        for j in 1:N
            if i == j; continue; end
            i2 = i==N ? 1 : i+1
            j2 = j==N ? 1 : j+1
            if i2 == j || j2 == i; continue; end
            if segIntersect(ptarr[i],ptarr[i2],ptarr[j],ptarr[j2]); return true; end
        end
    end
    return false
end

function solveSmall(N::I,X::VI,Y::VI)::VI
    bestarea::F = 0; bestperm::VI = collect(1:N); ptarr::Vector{Pt} = fill(Pt(0,0),N)
    if N > 10; return bestperm; end  ## Just to get us to end sooner on too large inputs
    for perm in unsafeIntPerm(collect(1:N)) 
        if perm[1] != 1 || perm[2] > perm[end]; continue; end  ## Do some search space trimming
        for (i,idx) in enumerate(perm); ptarr[i] = Pt(X[idx],Y[idx]); end
        if checkForBacktracks(N,ptarr); continue; end
        if checkForIntersections(N,ptarr); continue; end
        area = getArea(ptarr)
        if area > bestarea; bestarea = area; bestperm .= perm; end
    end
    return bestperm
end

function solveLarge(N::I,X::VI,Y::VI)::VI
    pts::Vector{Pt} = [Pt(X[i],Y[i]) for i in 1:N]
    up,dn = convexHull(pts)
    setup::SI = SI(up)
    setdn::SI = SI(dn)
    nonup::VI = [x for x in 1:N if x ∉ setup]
    nondn::VI = [x for x in 1:N if x ∉ setdn]
    mycmp(aa::I,bb::I)::Bool = convexHullCmp(pts[aa],pts[bb])
    sort!(nonup,lt=mycmp)
    sort!(nondn,lt=mycmp)
    poly1 = vcat(up,nonup[end:-1:1])
    poly2 = vcat(dn,nondn[end:-1:1])
    area1 = getArea([pts[i] for i in poly1])
    area2 = getArea([pts[i] for i in poly2])
    ans = area1 > area2 ? poly1 : poly2
    return ans
end    

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X = fill(0,N)
        Y = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,X,Y)
        ans = solveLarge(N,X,Y)
        ansstr = join([x-1 for x in ans]," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

