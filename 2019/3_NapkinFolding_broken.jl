
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
Base.:+(a::Pt,b::Pt)::Pt = Pt(a.x+b.x,a.y+b.y)
Base.:-(a::Pt,b::Pt)::Pt = Pt(a.x-b.x,a.y-b.y)
Base.:*(a::I,b::Pt)::Pt = Pt(a*b.x,a*b.y)
Base.:/(a::Pt,b::I)::Pt = Pt(a.x÷b,a.y÷b)
dp(a::Pt,b::Pt)::I = a.x*b.x+a.y*b.y
cp(a::Pt,b::Pt)::I = a.x*b.y-a.y*b.x

## Checks if q is on pr, given that p, q, & r are all colinear
function _segIntersectOnSegment(p::Pt,q::Pt,r::Pt)::Bool
    return q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && 
           q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y)
end

## Indicates if r is left of pq, right of pq, or on the line pq 
function _segIntersectOrientation(p::Pt,q::Pt,r::Pt)::I
    val::I = cp((q-p),(r-p))
    return val < 0 ? 1 : val > 0 ? 2 : 0
end

## Checks to see if p1-q1 && p2-q2 intersect and not on their endpoints
function segIntersectNonend(p1::Pt,q1::Pt,p2::Pt,q2::Pt)::Bool
    o1::I = _segIntersectOrientation(p1,q1,p2)
    o2::I = _segIntersectOrientation(p1,q1,q2)
    o3::I = _segIntersectOrientation(p2,q2,p1)
    o4::I = _segIntersectOrientation(p2,q2,q1)
    return o1+o2==3 && o3+o4==3
end

function segIntersect(p1::Pt,q1::Pt,p2::Pt,q2::Pt)::Bool
    o1::I = _segIntersectOrientation(p1,q1,p2)
    o2::I = _segIntersectOrientation(p1,q1,q2)
    o3::I = _segIntersectOrientation(p2,q2,p1)
    o4::I = _segIntersectOrientation(p2,q2,q1)
    if o1+o2==3 && o3+o4==3; return true; end
    if (o1 == 0 && _segIntersectOnSegment(p1,p2,q1)); return true; end
    if (o2 == 0 && _segIntersectOnSegment(p1,q2,q1)); return true; end
    if (o3 == 0 && _segIntersectOnSegment(p2,p1,q2)); return true; end
    if (o4 == 0 && _segIntersectOnSegment(p2,q1,q2)); return true; end
    return false
end

function reflect(p::Pt,a::Pt,b::Pt)::Pt
    v::Pt = p-a; l::Pt = b-a
    p1::Pt = (2*dp(v,l))*l
    ldotl::I = dp(l,l)
    if p1.x % ldotl !=0 || p1.y % ldotl != 0; return Pt(10^18,10^18); end
    return p1 / ldotl - v + a
end

function calcPossibleEndpoints(P::Vector{Pt},K::I)::Tuple{Vector{Pt},Vector{Pt},I}
    sf::I = 1; for i in 2:K; sf = lcm(sf,i); end; sf *= 2 ## Last *2 for integral midpoints
    P2::Vector{Pt} = [sf*x for x in P]
    numerators::VI = []
    for i in 2:K; for j in 1:i-1; push!(numerators,sf÷i*j); end; end
    unique!(sort!(numerators))
    P3::Vector{Pt} = []; N = length(P)
    for i in 1:N
        j = i == N ? 1 : i+1
        push!(P3,P2[i])
        for n in numerators; push!(P3,P2[i] + n * (P[j]-P[i])); end
    end
    return (P2,P3,sf)
end

function findPossibleSegments(P2::Vector{Pt},K::I,P3::Vector{Pt})::VPI
    ans::VPI = []
    ## Calculate the total polygon Area (times 2)
    totalArea::I = 0
    for i in 1:length(P2)
        j = i == length(P2) ? 1 : i+1
        totalArea += cp(P2[i],P2[j])
    end
    totalArea = abs(totalArea)
    targArea::I = totalArea ÷ K

    ## Loop through and find pairing the chop off the right target area.
    ## It it matches the right target area, we then can run a check to see if the segment if valid
    for i in 1:length(P3)
        candArea = 0
        jcand = vcat(collect(i+1:length(P3)),collect(1:i-1))
        for jidx in 1:(length(P3)-1)
            if jidx > 1
                prevj = jcand[jidx-1]
                candArea -= cp(P3[prevj],P3[i])
                j = jcand[jidx]
                candArea += cp(P3[prevj],P3[j]) + cp(P3[j],P3[i])
            end
            if -candArea == targArea
                if !internalSegment(P2,P3[i],P3[j]); continue; end
                push!(ans,(i,j))
            end
        end
    end
    return ans
end 

################################################################################
## Main idea
## * No edge or vertex bisects the two points
## * The midpoint is internal to the polygon (using a winding number algorithm)
################################################################################

function internalSegment(P2::Vector{Pt},pii::Pt,pjj::Pt)
    return true
    ## Translate everything releative to pii
    segvec::Pt = pjj-pii
    n = length(P2)
    midp = Pt((pii.x+pjj.x) ÷ 2, (pii.y+pjj.y) ÷ 2)
    area::I = 0
    for i in 1:n
        pt::Pt     = P2[i]
        nxtpt::Pt  = P2[i==n ? 1 : i+1]
        if pt == pii || pt == pjj; continue; end
        if cp(pt-pii,segvec) == 0 && _segIntersectOnSegment(pii,pt,pjj); return false; end
        if segIntersectNonend(pii,pjj,pt,nxtpt); return false; end
        area += cp(pt-midp,nxtpt-midp)
    end
    if area == 0; return false; else; return true; end
end

################################################################################
## Now we search for the valid segments
################################################################################

## Here, we are trying to traverse from the start to the end around the polygon
## and record (a) vertices of the original polygon, or (b) endpoints if the are
## not vertices themselves
function findPattern(st::I,en::I,l::I,C::I,sb::VI)::VI
    ## Take care of the scoreboard first
    if st < en; for i in st:en; sb[i] += 1; end
    else; for i in st:l; sb[i] += 1; end; for i in 1:en; sb[i] += 1; end 
    end

    ## Now for the pattern indices
    st2 = st % C == 0 ? st + 1 : st % C == 1 ? st : st - st % C + C + 1
    en2 = en % C == 0 ? en - C + 1 : en % C == 1 ? en : en - en % C + 1
    if st2 > l; st2 -= l; end
    if en2 < 1; en2 += l; end
    pattern::VI = []
    if st != st2; push!(pattern,st); end
    push!(pattern,st2)
    while st2 != en2
        st2 += C; if st2 > l; st2 -= l; end
        push!(pattern,st2)
    end
    if en != pattern[end]; push!(pattern,en); end
    push!(pattern,st)
    return pattern
end

function isOnPolyEdge(a::I,b::I,l::I,C::I,sb::VI)::Bool
    ## Both points are bonafide vertices
    if a % C == 1 && b % C == 1
        if abs(a-b) == C
            for i in min(a,b):min(a,b)+C; sb[i] += 1; end
            return true
        elseif abs(a-b) == l-C
            sb[1] += 1
            for x in C-1:-1:0; sb[end-x] += 1; end
            return true
        else
            return false
        end
    end

    ## One point is a bonafide vertex
    if a % C == 1 || b % C == 1
        (a,b) = (a % C == 1) ? (a,b) : (b,a)
        if 0 < b-a < C
            for i in a:b; sb[i] += 1; end; return true
        end
        preva = a - C; if preva <= 0; preva += l; end
        if 0 < b - preva < C
            if b < a; for i in b:a; sb[i] += 1; end; return true; end
            sb[1] += 1; for i in b:l; sb[i] += 1; end; return true
        end
        return false
    end

    if (a-1) ÷ C == (b-1) ÷ C
        for i in min(a,b):max(a,b); sb[i] += 1; end
        return true
    end

    return false
end

## Need to think about possibility of overlapping reflections in a simple polygon.
## For now, I am ignoring them, but may add that code later (i.e. a "perimeter scoreboard")
function findValidSegments(P2::Vector{Pt}, K::I, P3::Vector{Pt}, P3Dict::Dict{Pt,I}, segment::PI)::SPI
    C::I = length(P3) ÷ length(P2)
    sb::VI = [0 for x in P3]
    pattern::VI = findPattern(segment[1],segment[2],length(P3),C,sb)
    segments::SPI = SPI(); push!(segments,segment)
    stk::Vector{Tuple{PI,VI}} = [(segment,pattern)]
    while !isempty(stk)
        if length(segments) >= K; return SPI(); end  ## Should only have n-1 segments
        (locseg,pattern) = pop!(stk)
        if !internalSegment(P2,P3[locseg[1]],P3[locseg[2]]); return SPI(); end
        newSegs::VPI,newPat::VI = [],[]
        for i::I in 1:length(pattern)
            p::Pt = reflect(P3[pattern[i]],P3[locseg[1]],P3[locseg[2]])
            if !haskey(P3Dict,p); return SPI(); end
            pidx::I = P3Dict[p]
            if !isempty(newPat) && !isOnPolyEdge(newPat[end],pidx,length(P3),C,sb)
                newSeg = newPat[end] < pidx ? (newPat[end],pidx) : (pidx,newPat[end])
                if newSeg ∉ segments; push!(newSegs,newSeg); end
            end
            push!(newPat,pidx)
        end
        for newSeg::PI in newSegs
            push!(stk,(newSeg,newPat))
            push!(segments,newSeg)
        end
    end
    if length(segments) != K-1; return SPI(); end
    if 0 in sb; return SPI(); end
    return segments
end

function solveLarge(N::I,K::I,X::VI,Y::VI)::VS
    P::Vector{Pt} = [Pt(X[i],Y[i]) for i in 1:N]
    (P2::Vector{Pt},P3::Vector{Pt},scaleup) = calcPossibleEndpoints(P,K)
    P3Dict::Dict{Pt,I} = Dict{Pt,I}()
    for (i,p) in enumerate(P3); P3Dict[p] = i; end
    candSegs = findPossibleSegments(P2,K,P3)
    for seg in candSegs
        segSet = findValidSegments(P2,K,P3,P3Dict,seg)
        if length(segSet) == 0; continue; end
        ans::VS = ["POSSIBLE"]
        for (a,b) in segSet
            push!(ans,join(["$(numerator(XX//scaleup))/$(denominator(XX//scaleup))" for XX in (P3[a].x,P3[a].y,P3[b].x,P3[b].y)]," "))
        end
        return ans
    end
    return ["IMPOSSIBLE"]
end

##https://en.wikipedia.org/wiki/Reflection_(mathematics)#Reflection_across_a_line_in_the_plane
function reflectSmall(a::Pt,b::Pt,p::Pt)
    v = Pt(p.x-a.x,p.y-a.y)
    l = Pt(b.x-a.x,b.y-a.y)
    ldotl = l.x*l.x+l.y*l.y
    vdotl = v.x*l.x+v.y*l.y
    p1 = Pt(2*vdotl*l.x,2*vdotl*l.y)
    if p1.x % ldotl !=0 || p1.y % ldotl != 0; return (10^18,10^18); end
    return Pt( p1.x÷ldotl - v.x + a.x, p1.y÷ldotl - v.y + a.y)
end

function reflectCheckSmall(P3::Vector{Pt},ii::I,jj::I)::Bool
    p1::Vector{Pt} = P3[ii+1:jj-1]
    p2::Vector{Pt} = vcat(P3[ii-1:-1:1],P3[end:-1:jj+1])
    refp2 = [reflectSmall(P3[ii],P3[jj],p) for p in p2]
    return p1 == refp2
end 

function solveSmall(N::I,K::I,X::VI,Y::VI)::VS
    if K > 2; return ["IMPOSSIBLE"]; end
    P2::Vector{Pt} = [Pt(2*X[i],2*Y[i]) for i in 1:N]
    P3::Vector{Pt} = []
    for i::I in 1:N
        push!(P3,P2[i])
        j::I = i == N ? 1 : i+1
        push!(P3,Pt( (P2[i].x+P2[j].x)÷2, (P2[i].y+P2[j].y)÷2 ))
    end
    for i in 1:N
        j = i+N
        if !reflectCheckSmall(P3,i,j); continue; end
        ans::VS = ["POSSIBLE"]
        push!(ans,join(["$(numerator(XX//2))/$(denominator(XX//2))" for XX in (P3[i].x,P3[i].y,P3[j].x,P3[j].y)]," "))
        return ans
    end
    return ["IMPOSSIBLE"]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #ans1 = solveSmall(N,K,X,Y)
        ans1 = solveLarge(N,K,X,Y)
        #if ans1[1] == "POSSIBLE" && ans2[1] == "IMPOSSIBLE"; exit(1); end
        #if ans1[1] == "IMPOSSIBLE" && ans2[1] == "POSSIBLE"; a = fill(0,10^9,10^9); end
        for l in ans1; println(l); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

