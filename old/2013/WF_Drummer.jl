
## For the small, all we need to observe is that the optimal tempo is achieved with a line between two
## of the observed points.
## For the large, the additonal observation we need is that said line should be on the convex hull.  This
## changes the problem from O(N^3) to O(N^2)


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
    return vcat(up,down[end-1:-1:2])
end

function trytempo(num::Int64,denom::Int64,NN::Vector{Int64})::Float64
    mine::Float64 = 1e99
    maxe::Float64 = -1e99
    N::Int64 = length(NN)
    inc::Float64 = num/denom
    cur::Float64 = 0
    for i in 1:N
        cur += inc
        err = cur - NN[i]
        if err < mine; mine = err; end
        if err > maxe; maxe = err; end
    end
    return 0.5*(maxe-mine)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N  = parse(Int64,rstrip(readline(infile)))
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        ## Look for the degenerate case of all points being colinear
        error = trytempo(NN[2],1,NN)
        if error < 1e-7; print("0.00\n"); continue; end

        pts::Vector{Pt} = []
        for i in 1:N
            push!(pts,Pt(i,NN[i]))
        end
        hull = convexHull(pts)
        lh = length(hull)
        best = 1e99
        for i in 1:lh
            p1,p2 = hull[i],hull[i==lh ? 1 : i+1]
            if p2 < p1; (p1,p2) = (p2,p1); end
            b = trytempo(NN[p2]-NN[p1],p2-p1,NN)
            best = min(best,b)
        end
        print("$best\n")
    end
end

main()

