using Random

mutable struct Pt
    x::Int64
    y::Int64
end

convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) <= 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) >= 0
##function convexHull(a::Vector{Pt})::Vector{Pt}
##    if length(a) == 1; return [a[1]]; end
##    sort!(a,lt=convexHullCmp)
##    p1::Pt,p2::Pt = a[1],a[end]
##    up::Vector{Pt} = []
##    down::Vector{Pt} = []
##    push!(up,p1)
##    push!(down,p1)
##    for i in 2:length(a)
##        if i == length(a) || convexHullCw(p1,a[i],p2)
##            while length(up) >= 2 && !convexHullCw(up[end-1], up[end], a[i]); pop!(up); end
##            push!(up,a[i])
##        end
##        if i == length(a) || convexHullCcw(p1,a[i],p2)
##            while length(down) >= 2 && !convexHullCcw(down[end-1],down[end],a[i]); pop!(down); end
##            push!(down,a[i])
##        end
##    end
##    ans::Vector{Pt} = []
##    for pt in up; push!(ans,pt); end
##    for pt in down[end-1:-1:2]; push!(ans,pt); end
##    return ans
##end

function convexHull2(a::Vector{Pt})
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


## Segment intersection -- adapted from Geeks4Geeks code
## -- segIntersectOnSegment -- Given three colinear points p, q, r, checkif q is on line segment 'pr'
## -- segIntersectOrientation -- Orientation of (p,q,r) 0->colinear.  1->clockwise.  2->counterclockwise  
segIntersectOnSegment(p::Pt,q::Pt,r::Pt)::Bool = (q.x <= max(p.x, r.x) && q.x >= min(p.x, r.x) && 
                                                  q.y <= max(p.y, r.y) && q.y >= min(p.y, r.y))
function segIntersectOrientation(p::Pt,q::Pt,r::Pt)::Int64
    val::Int64 = (q.y-p.y) * (r.x-q.x) - (q.x-p.x) * (r.y-q.y);
    return val < 0 ? 1 : val > 0 ? 2 : 0
end
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

## This checks if ray ba and ray bc point in same direction
function checkBacktrack(a::Pt,b::Pt,c::Pt)::Bool
    x1::Int64 = a.x-b.x
    y1::Int64 = a.y-b.y
    x2::Int64 = c.x-b.x
    y2::Int64 = c.y-b.y
    cp::Int64 = x1*y2-y1*x2
    if cp != 0; return false; end ##Angle is not 0deg or 180deg
    dp::Int64 = x1*x2+y1*y2
    return dp >= 0
end

function check(N::Int64,pts::Vector{Pt},a::Vector{Int64})::Bool
    retval =  true
    retval &= !checkBacktrack(pts[a[N]],pts[a[1]],pts[a[2]])
    retval &= !checkBacktrack(pts[a[N-1]],pts[a[N]],pts[a[1]])
    for i in 2:N-1
        retval &= !checkBacktrack(pts[a[i-1]],pts[a[i]],pts[a[i+1]])
    end
    for i in 1:N
        (n1,n2) = (i,i == N ? 1 : i+1)
        for j in 1:N
            (n3,n4) = (j,j == N ? 1 : j+1)
            if n1==n3 || n1==n4 || n2==n3 || n2==n4; continue; end
            p1,p2,p3,p4 = pts[a[n1]],pts[a[n2]],pts[a[n3]],pts[a[n4]]
            retval &= !segIntersect(p1,p2,p3,p4)
        end
    end
    up,dn = convexHull2(pts)
    hull = vcat(up,dn[end-1:-1:2])
    areahull = getArea(pts,hull)
    areapoly = getArea(pts,a)
    if areapoly <= 0.5*areahull; retval = false; end
    return retval
end

function gencase(N::Int64,xmin::Int64,xmax::Int64,ymin::Int64,ymax::Int64)
    area = 0.00
    spoints = Set{Tuple{Int64,Int64}}()
    while (area == 0.00)
        empty!(spoints)
        while length(spoints) < N
            x = rand(xmin:xmax)
            y = rand(ymin:ymax)
            push!(spoints,(x,y))
        end
        pts = [Pt(x[1],x[2]) for x in spoints]
        up,dn = convexHull2(pts)
        hull = vcat(up,dn[end-1:-1:2])
        area = getArea(pts,hull)
    end
    pts = [Pt(x[1],x[2]) for x in spoints]
    return (N,pts)
end

function regress()
    Random.seed!(8675309)
    for i in 1:10000
        N = i <= 500 ? rand(3:6) : rand(3:10)
        xmax = i <= 1000 ? 3 : i <= 5000 ? rand(3:10) : rand(3:1000)
        ymax = i <= 1000 ? 3 : i <= 5000 ? rand(3:10) : rand(3:1000)
        (_N,pts) = gencase(N,0,xmax,0,ymax)
        ans = solve(N,pts)
        res = check(N,pts,ans)
        if res
            print("Case $i: --pass--\n")
        else
            print("Case $i: ERROR\n")
            print("$N\n")
            for p in pts
                x,y = p.x,p.y
                print("$x $y\n")
            end
            ansstr = join([x-1 for x in ans]," ")
            print("ANSWER GIVEN: $ansstr\n")
        end
    end
end

function solve(N::Int64,pts::Vector{Pt})::Vector{Int64}
    up,dn = convexHull2(pts)
    #print("    DBG: up:$up\n")
    #print("    DBG: dn:$dn\n")
    setup = Set{Int64}(up)
    setdn = Set{Int64}(dn)
    nonup = [x for x in 1:N if x ∉ setup]
    nondn = [x for x in 1:N if x ∉ setdn]
    mycmp(aa::Int64,bb::Int64)::Bool = convexHullCmp(pts[aa],pts[bb])
    sort!(nonup,lt=mycmp)
    sort!(nondn,lt=mycmp)
    poly1 = vcat(up,nonup[end:-1:1])
    poly2 = vcat(dn,nondn[end:-1:1])
    area1 = getArea(pts,poly1)
    area2 = getArea(pts,poly2)
    ans = area1 > area2 ? poly1 : poly2
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        pts::Vector{Pt} = []
        for i in 1:N
            x,y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            push!(pts,Pt(x,y))
        end
        ans = solve(N,pts)
        ansstr = join([x-1 for x in ans]," ")
        print("$ansstr\n")
    end
end

main()
#regress()