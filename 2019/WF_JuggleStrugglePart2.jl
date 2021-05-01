
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

function solveSmall(N::I,X1::VI,Y1::VI,X2::VI,Y2::VI)::String
    sb::Array{I,2} = fill(0,N,N)
    for i in 1:N-1
        for j in i+1:N
            if segIntersect(Pt(X1[i],Y1[i]),Pt(X2[i],Y2[i]),Pt(X1[j],Y1[j]),Pt(X2[j],Y2[j]))
                sb[i,j] = sb[j,i] = 1
            end
        end
    end
    ans::VI = [i for i in 1:N if sum(sb[i,:]) < N-1]
    return length(ans) == 0 ? "MAGNIFICENT" : join(ans," ")
end


## Take care of parallel lines and vertical lines first
## For the remaining lines, we want to know the leftmost and rightmost point of intersection
## We can use point-line duality to change this into a problem of looking for the lines of steepest
## slope in the dual plane.  There we can use a Grahm-Scan to calculate this effectively (ordering
## by x coordinate and then calculating either the lower or upper hull).

const MBI = Tuple{Rational{BigInt},Rational{BigInt},Int64}

struct DualPt; m::I; nb::I; d::I; idx::I; end
Base.isless(a::DualPt,b::DualPt) = a.m * b.d < b.m * a.d

function doTurn(p1::DualPt,p2::DualPt,p3::DualPt,left::Bool)
    x1::Int64 = p2.d*p1.m-p1.d*p2.m
    x2::Int64 = p2.d*p3.m-p3.d*p2.m
    y1::BigInt = Int128(p2.d)*p1.nb-Int128(p1.d)*p2.nb
    y2::BigInt = Int128(p2.d)*p3.nb-Int128(p3.d)*p2.nb
    if left; return y2*x1 < y1*x2; else; return y2*x1 > y1*x2; end
end
leftTurn(p1::DualPt,p2::DualPt,p3::DualPt)  = doTurn(p1,p2,p3,true)
rightTurn(p1::DualPt,p2::DualPt,p3::DualPt) = doTurn(p1,p2,p3,false)

function badIntersection(p1::DualPt,p2::DualPt,X1::VI,X2::VI)
    i::I,j::I = p1.idx,p2.idx
    xleft::I  = max(min(X1[i],X2[i]),min(X1[j],X2[j]))
    xright::I = min(max(X1[i],X2[i]),max(X1[j],X2[j]))
    num::Int128 = Int128(p1.d)*p2.nb - Int128(p2.d)*p1.nb
    denom::Int64 = p1.d*p2.m-p2.d*p1.m
    if denom < 0; denom *= -1; num *= -1; end
    return num < Int128(denom)*xleft || num > Int128(denom)*xright
end  

function solveLarge(N::I,X1::VI,Y1::VI,X2::VI,Y2::VI)
    DBG::Bool = false
    if DBG; print("DBG MODE!!!\n"); end
    bad::SI = SI()
    slopes::VPI = []
    for i in 1:N
        dx = X2[i]-X1[i]; dy = Y2[i]-Y1[i]
        if dx < 0; dx *= -1; dy *= -1; end
        g::I = gcd(dx,dy)
        push!(slopes,(dx÷g,dy÷g))
    end
    ## Take care of vertical lines
    verticalLines::VI = []
    for i in 1:N; if slopes[i][1] == 0; push!(verticalLines,i); end; end
    if length(verticalLines) > 1; for i in verticalLines; push!(bad,i); end; end
    for i in verticalLines
        for j in 1:N
            if j in verticalLines; continue; end ## Can't have more than 25 here, so ok
            if !segIntersect(Pt(X1[i],Y1[i]),Pt(X2[i],Y2[i]),Pt(X1[j],Y1[j]),Pt(X2[j],Y2[j]))
                push!(bad,i); push!(bad,j)
            end
        end
    end

    ## Now take care of non-vertical parallel lines
    slopeset::SPI = SPI()
    badslopes::SPI = SPI()
    parallel::VI = []
    for i in 1:N;
        if slopes[i][1] == 0; continue; end
        if slopes[i] ∈ slopeset; push!(badslopes,slopes[i]); end
        push!(slopeset,slopes[i])
    end
    for i in 1:N; if slopes[i] ∈ badslopes; push!(parallel,i); push!(bad,i); end; end
    for i in parallel
        for j in 1:N
            if j in parallel; continue; end  ## again bounded by 25
            if !segIntersect(Pt(X1[i],Y1[i]),Pt(X2[i],Y2[i]),Pt(X1[j],Y1[j]),Pt(X2[j],Y2[j]))
                push!(bad,i); push!(bad,j)
            end
        end
    end

    ignoredPts::SI = SI(vcat(parallel,verticalLines))
    pts1::Vector{NTuple{5,I}} = [(X1[i],Y1[i],X2[i],Y2[i],i) for i in 1:N if i ∉ ignoredPts]
    
    ## Special case if we have 2 or fewer points left
    if length(pts1) == 2
        if !segIntersect(Pt(pts1[1][1],pts1[1][2]),Pt(pts1[1][3],pts1[1][4]),
                         Pt(pts1[2][1],pts1[2][2]),Pt(pts1[2][3],pts1[2][4]))
            push!(bad,pts1[1][5])
            push!(bad,pts1[2][5])
        end
    elseif length(pts1) >= 3
        dualpt1::Vector{DualPt} = []
        for (x1,y1,x2,y2,i) in pts1
            sign = x2-x1 < 0 ? -1 : 1
            d = abs(x2-x1)
            m = sign * (y2-y1)
            b = y1 * d - m * x1
            push!(dualpt1,DualPt(m,-b,d,i))
        end

        ## Now we sort the dual points first by x coordinate and then by y coordinate.  Note that
        ## we have eliminated parallel lines, so there should be no ties
        sort!(dualpt1)
        dualpt2::Vector{DualPt} = reverse(dualpt1)

        ## We need to do upper and lower hulls from both the right and the left
        for dualpt::Vector{DualPt} in (dualpt1,dualpt2)
            hull1::Vector{DualPt} = []
            hull2::Vector{DualPt} = []
            for pp in dualpt
                while length(hull1) >= 2 && leftTurn(hull1[end-1],hull1[end],pp); pop!(hull1); end
                while length(hull2) >= 2 && rightTurn(hull2[end-1],hull2[end],pp); pop!(hull2); end
                push!(hull1,pp); push!(hull2,pp)
                for hull in (hull1,hull2)
                    if length(hull) < 2; continue; end
                    if badIntersection(hull[end-1],hull[end],X1,X2)
                        for pt in (hull[end-1],hull[end]); push!(bad,pt.idx); end
                    end
                end
            end
        end
    end

    ## Ok, so far we have found
    ## -- any sets of parallel lines, which must be bad (including multiple vertical liines)
    ## -- segments that are too short 
    ## We are still missing segments that don't have all of their intersections because a different segment is too short
    ## Since there are <= 25 bad segments, we can now solve these like we do in the solveSmall
    if DBG; return ""; end
    lbad = [x for x in bad]
    for i in lbad
        for j in 1:N
            if j in lbad; continue; end
            if !segIntersect(Pt(X1[i],Y1[i]),Pt(X2[i],Y2[i]),Pt(X1[j],Y1[j]),Pt(X2[j],Y2[j]))
                push!(bad,i); push!(bad,j)
            end
        end
    end

    if length(bad) == 0; return "MAGNIFICENT"; end
    ans::VI = sort([x for x in bad])
    return join(ans," ")
end

function check3Colinear(N,X,Y)
    for i in 1:2N-2
        for j in i+1:2N-1
            for k in j+1:2N
                x1 = X[j]-X[i]; y1 = Y[j]-Y[i]
                x2 = X[k]-X[i]; y2 = Y[k]-Y[i]
                if x1*y2 == y1*x2; return true; end
            end
        end
    end
    return false
end

function gencase(Nmin::I,Nmax::I,Cmin::I,Cmax::I,nocollinear::Bool=true)
    N = rand(Nmin:Nmax)
    while (true)
        pts::SPI = SPI()
        lpts::VPI = VPI()
        while length(pts) < 2N
            x = rand(Cmin:Cmax)
            y = rand(Cmin:Cmax)
            if (x,y) in pts; continue; end
            if nocollinear
                good = true
                for i in 1:length(pts)
                    for j in i+1:length(pts)
                        (x1,y1) = lpts[i]
                        (x2,y2) = lpts[j]
                        dx1 = x2-x1
                        dy1 = y2-y1
                        dx2 = x - x1
                        dy2 = y - y1
                        if dx1*dy2 == dx2*dy1; good = false; break; end
                    end
                    if !good; break; end
                end
                if !good; continue; end
            end
            push!(pts,(x,y)); push!(lpts,(x,y))
        end
        X::VI = [p[1] for p in lpts]
        Y::VI = [p[2] for p in lpts]
        X1::VI = X[1:N]
        X2::VI = X[N+1:2N]
        Y1::VI = Y[1:N]
        Y2::VI = Y[N+1:2N]
        return (N,X1,Y1,X2,Y2)
    end
end

function test(ntc::I,Nmin::I,Nmax::I,Cmin::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,X1,Y1,X2,Y2) = gencase(Nmin,Nmax,Cmin,Cmax)
        ans2 = solveLarge(N,X1,Y1,X2,Y2)
        if check
            ans1 = solveSmall(N,X1,Y1,X2,Y2)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                print("$N\n")
                for i in 1:N; print("$(X1[i]) $(Y1[i]) $(X2[i]) $(Y2[i])\n"); end
                ans1 = solveSmall(N,X1,Y1,X2,Y2)
                ans2 = solveLarge(N,X1,Y1,X2,Y2)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X1::VI,Y1::VI,X2::VI,Y2::VI = fill(0,N),fill(0,N),fill(0,N),fill(0,N)
        for i in 1:N; X1[i],Y1[i],X2[i],Y2[i] = gis(); end
        #ans = solveSmall(N,X1,Y1,X2,Y2)
        ans = solveLarge(N,X1,Y1,X2,Y2)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#for i in 1:1000
#    for (nmin,nmax) in [(2,10)]
#        for (cmin,cmax) in [(0,100)]
#            test(1000,nmin,nmax,cmin,cmax)
#        end
#    end
#end

#(N,X1,Y1,X2,Y2) = gencase(99000,100000,-1000000000,1000000000,false)
#using Profile, StatProfilerHTML
#Profile.clear()
#@profile solveLarge(N,X1,Y1,X2,Y2)
#Profile.clear()
#@profilehtml solveLarge(N,X1,Y1,X2,Y2)




#test(10,1,10,100)
#test(10,11,20,1000)
#test(10,21,100,10000)
#test(100,1,10,100)
#test(100,11,20,1000)
#test(100,21,100,10000)
#test(1000,1,10,100)
#test(1000,11,20,1000)
#test(1000,21,100,10000)


