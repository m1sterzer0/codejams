const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

struct Pt; x::I; y::I; end

convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) < 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) > 0
function convexHull(a::Vector{Pt},idxFlag::Bool=true)
    mycmp(aa::I,bb::I)::Bool = convexHullCmp(a[aa],a[bb])
    mycw(aa::I,bb::I,cc::I) = convexHullCw(a[aa],a[bb],a[cc])
    myccw(aa::I,bb::I,cc::I) = convexHullCcw(a[aa],a[bb],a[cc])
    N = length(a)
    if length(a) == 1; return idxFlag ? [1] : [a[1]]; end
    aidx = collect(1:N); sort!(aidx,lt=mycmp)
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
    idxarr::VI = vcat(up,down[end-1:-1:2])
    return idxFlag ? idxarr : [a[x] for x in idxarr]
end

## Useful routine for for sorting out angles
## Returns (dot product,cross product,quadrant) where angle is assumed between 0deg and 180deg.  Let angle be x, then
## 0 if x = 0deg, 1 if 0deg<x<90deg, 2 if x = 90deg, 3 if 90deg<x<180deg, 4 if x == 180deg.

struct Pt; x::I; y::I; end

function getcpdpq(a::Pt,b::Pt)::TI
    dp = a.x*b.x+a.y*b.y
    cp = a.x*b.y-a.y*b.x
    q = (cp == 0 && dp > 0) ? 0 : dp > 0 ? 1 : dp == 0 ? 2 : (cp == 0 && dp < 0) ? 4 : 3
    return (dp,cp,q)
end

function getArea(ptarr::Vector{Pt}):F
    N::I = length(ptarr); aa::F = 0.0
    for i in 1:N
        j = i == N ? 1 : i+1
        aa += ptarr[i].x*ptarr[j].y - ptarr[i].y*ptarr[j].x
    end
    return abs(0.5*aa)
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

function getArea(pts::Vector{Pt},indices::Vector{Int64})::Float64
    aa::Int64 = 0
    N = length(indices)
    for i in 1:N-1
        p1::Pt = pts[indices[i]]
        p2::Pt = pts[indices[i+1]]
        aa += (p1.x*p2.y-p1.y*p2.x)
    end
    p3::Pt = pts[indices[N]]
    p4::Pt = pts[indices[1]]
    aa += (p3.x*p4.y-p3.y*p4.x)
    return 0.5*abs(aa)
end


mutable struct Pt3; x::Int128; y::Int128; z::Int128; end
Pt3() = Pt3(Int128(0),Int128(0),Int128(0))
Base.:+(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x+b.x,a.y+b.y,a.z+b.z)
Base.:-(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x-b.x,a.y-b.y,a.z-b.z)
Base.:*(a::Int64,b::Pt3)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z)
Base.:*(b::Pt3,a::Int64)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z) 
cross(a::Pt3,b::Pt3)::Pt3  = Pt3(a.y*b.z-b.y*a.z,a.z*b.x-b.z*a.x,a.x*b.y-b.x*a.y)
dot(a::Pt3,b::Pt3)::Int128 = a.x*b.x + a.y*b.y + a.z*b.z

mutable struct Pt2; x::Int128; y::Int128; end
Pt2() = Pt2(Int128(0),Int128(0))
Base.:+(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x+b.x,a.y+b.y)
Base.:-(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x-b.x,a.y-b.y)
Base.:*(a::Int64,b::Pt2)::Pt2 = Pt2(a*b.x,a*b.y)
Base.:*(b::Pt2,a::Int64)::Pt2 = Pt2(a*b.x,a*b.y) 
dot(a::Pt2,b::Pt2)::Int128 = a.x*b.x + a.y*b.y