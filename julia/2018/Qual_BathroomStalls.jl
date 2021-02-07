using Printf

######################################################################################################
### We first orient the cube such that the corners are all directly above/below the X/Z axes with the
### two faces paralell to the ground.  This gives us a minimal shadow of exactly 1.  Then, if we rotate
### the cube by asin(sqrt(2)/sqrt(3)), we will get the maximal area of sqrt(3).  The shadow's area is
### monotonic increasing in this interval, so we can just do a binary search.
######################################################################################################

function rotatex(a::Array{Float64,2},x::Float64)
    rotx::Array{Float64,2} = [1.0 0.0 0.0; 0.0 cos(x) -sin(x); 0.0 sin(x) cos(x) ]
    return rotx * a
end

function rotatey(a::Array{Float64,2},x::Float64)
    rotx::Array{Float64,2} = [cos(x) 0.0 sin(x); 0.0 1.0 0.0; -sin(x) 0.0 cos(x)]
    return rotx * a
end

function rotatez(a::Array{Float64,2},x::Float64)
    rotz::Array{Float64,2} = [cos(x) -sin(x) 0.0; sin(x) cos(x) 0.0; 0.0 0.0 1.0 ]
    return rotz * a
end

function solveit(A::Float64)
    (al,ar) = (1.000,sqrt(3.00))
    (l,r) = (0.00,asin(sqrt(2)/sqrt(3)))
    if A <= al; return 0.00; end
    if A >= ar; return r; end
    while (ar-al) > 1e-9 && (ar-al)/(ar+al) > 1e-9
        m = 0.5*(l+r)
        area = shadowArea(m)
        if area > A; (r,ar) = (m,area)
        else       ; (l,al) = (m,area)
        end
    end
    return 0.5*(l+r)
end

function shadowArea(m::Float64)
    a = [0.5 0.5 0.5 0.5 -0.5 -0.5 -0.5 -0.5; 0.5 0.5 -0.5 -0.5 0.5 0.5 -0.5 -0.5; 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5]
    rota = rotatex(rotatey(a,pi/4),m)
    planepoints::Vector{Tuple{Float64,Float64}} = [(rota[1,x],rota[3,x]) for x in 1:8]
    hull = convexHull(planepoints)
    area = abs(shoelace(hull))
    return area
end

function getFaces(m::Float64)
    a = [0.5 0.0 0.0; 0.0 0.5 0.0; 0.0 0.0 0.5]
    return rotatex(rotatey(a,pi/4),m)
end

function convexHull(pts::Vector{Tuple{Float64,Float64}})::Vector{Tuple{Float64,Float64}}
    function cw(a::Tuple{Float64,Float64}, b::Tuple{Float64,Float64}, c::Tuple{Float64,Float64})::Bool
        return a[1]*(b[2]-c[2])+b[1]*(c[2]-a[2])+c[1]*(a[2]-b[2]) > 0.0
    end
    function ccw(a::Tuple{Float64,Float64}, b::Tuple{Float64,Float64}, c::Tuple{Float64,Float64})::Bool
        return a[1]*(b[2]-c[2])+b[1]*(c[2]-a[2])+c[1]*(a[2]-b[2]) < 0.0
    end
    ptarr = copy(pts)
    sort!(ptarr)
    p1 = ptarr[1]
    p2 = ptarr[end]
    up,dn = Vector{Tuple{Float64,Float64}}(),Vector{Tuple{Float64,Float64}}()
    push!(up,p1)
    push!(dn,p1)
    for pt in ptarr[2:end]
        if pt==p2 || cw(p1,pt,p2)
            while length(up) >= 2 && !cw(up[end-1],up[end],pt); pop!(up); end
            push!(up,pt)
        end
        if pt==p2 || ccw(p1,pt,p2)
            while length(dn) >= 2 && !ccw(dn[end-1],dn[end],pt); pop!(dn); end
            push!(dn,pt)
        end
    end
    res = Vector{Tuple{Float64,Float64}}()
    for pt in up[1:end-1]; push!(res,pt); end
    for pt in dn[end:-1:2]; push!(res,pt); end
    return res
end

function shoelace(pts::Vector{Tuple{Float64,Float64}})::Float64
    area2 = 0.0
    for i in 1:length(pts)
        j = (i == length(pts)) ? 1 : i+1
        k = (i == 1) ? length(pts) : i-1
        area2 += pts[i][1]*pts[j][2]
        area2 -= pts[i][1]*pts[k][2]
    end
    return 0.5*area2
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        A = parse(Float64,rstrip(readline(infile)))
        theta = solveit(A)
        print(stderr,"DEBUG: A:$A theta:$theta\n")
        faces = getFaces(theta)
        @printf("%.10f %.10f %.10f\n",faces[1,1],faces[2,1],faces[3,1])
        @printf("%.10f %.10f %.10f\n",faces[1,2],faces[2,2],faces[3,2])
        @printf("%.10f %.10f %.10f\n",faces[1,3],faces[2,3],faces[3,3])
    end
end

main()
