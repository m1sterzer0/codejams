using Random

mutable struct Pt
    x::Int64
    y::Int64
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

function solve(N::Int64,pts::Vector{Pt})::Vector{Int64}
    up,dn = convexHull(pts)
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
