struct Pt
    x::Int64
    y::Int64
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

function doit(idx::Int64,indices::Vector{Int64},N::Int64,pts::Vector{Pt},remaining::Set{Int64})
    ##print("DBG: doit($idx,$indices,$N,pts,$remaining)\n")
    ans::Float64 = 0.00
    best::Vector{Int64} = []
    rem = [x for x in remaining]
    for r in rem
        if checkBacktrack(pts[indices[idx-2]],pts[indices[idx-1]],pts[r]); continue; end
        good = true
        for idx2 in 1:idx-3
            if segIntersect(pts[indices[idx2]],pts[indices[idx2+1]],pts[indices[idx-1]],pts[r])
                good = false; break;
            end
        end
        if good
            indices[idx] = r
            delete!(remaining,r)
            if idx < N
                a2,cand = doit(idx+1,indices,N,pts,remaining)
                if a2 > ans; ans = a2; best = cand[:]; end
            else
                ## Check the last segment
                if checkBacktrack(pts[indices[idx-1]],pts[indices[idx]],pts[indices[1]]); continue; end
                if checkBacktrack(pts[indices[idx]],pts[indices[1]],pts[indices[2]]); continue; end
                good2 = true
                for idx2 in 2:idx-2
                    if segIntersect(pts[indices[idx2]],pts[indices[idx2+1]],pts[indices[idx]],pts[indices[1]])
                        good2 = false; break;
                    end
                end
                if good2
                    a2 = getArea(pts,indices)
                    if a2 > ans; ans = a2; best = indices[:]; end
                end
            end
            indices[idx] = 0
            push!(remaining,r)
        end
    end
    return ans,best
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
        area::Float64 = 0.0
        ans::Vector{Int64} = []
        if N == 3
            area = getArea(pts,[1,2,3])
            ans = [1,2,3]
        else
            indices::Vector{Int64} = fill(0,N)
            indices[2] = 1
            remaining::Set{Int64} = Set{Int64}()
            ## Cut a factor of 20 out of the search
            for i in 2:N-1
                indices[1] = i
                for j in i+1:N
                    indices[3] = j
                    if checkBacktrack(pts[i],pts[1],pts[j]); continue; end
                    empty!(remaining)
                    for k in 2:N
                        if k != i && k != j; push!(remaining,k); end
                    end
                    a2,cand = doit(4,indices,N,pts,remaining)
                    if a2 > area; area = a2; ans = cand[:]; end 
                end
            end
        end
        ansstr = join([x-1 for x in ans], " ")
        print("$ansstr\n")
    end
end

main()
