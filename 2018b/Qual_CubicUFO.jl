
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

rotatex(a::Array{F,2},x::F)::Array{F,2} = [1.0 0.0 0.0; 0.0 cos(x) -sin(x); 0.0 sin(x) cos(x) ] * a
rotatey(a::Array{F,2},x::F)::Array{F,2} = [cos(x) 0.0 sin(x); 0.0 1.0 0.0; -sin(x) 0.0 cos(x) ] * a
rotatez(a::Array{F,2},x::F)::Array{F,2} = [cos(x) -sin(x) 0.0; sin(x) cos(x) 0.0; 0.0 0.0 1.0 ] * a

function solveit(A::F)
    (al::F,ar::F) = (1.000,sqrt(3.00))
    (l::F,r::F) = (0.00,asin(sqrt(2)/sqrt(3)))
    if A <= al; return 0.00; end
    if A >= ar; return r; end
    while (ar-al) > 1e-9 && (ar-al)/(ar+al) > 1e-9
        m::F = 0.5*(l+r)
        area::F = shadowArea(m)
        if area > A; (r,ar) = (m,area)
        else       ; (l,al) = (m,area)
        end
    end
    return 0.5*(l+r)
end

function shadowArea(m::F)
    a = [0.5 0.5 0.5 0.5 -0.5 -0.5 -0.5 -0.5; 0.5 0.5 -0.5 -0.5 0.5 0.5 -0.5 -0.5; 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5]
    rota = rotatex(rotatey(a,pi/4),m)
    planepoints::Vector{Tuple{F,F}} = [(rota[1,x],rota[3,x]) for x in 1:8]
    hull = convexHull(planepoints)
    area = abs(shoelace(hull))
    return area
end

function getFaces(m::F)
    a = [0.5 0.0 0.0; 0.0 0.5 0.0; 0.0 0.0 0.5]
    return rotatex(rotatey(a,pi/4),m)
end

function convexHull(pts::Vector{Tuple{F,F}})::Vector{Tuple{F,F}}
    function cw(a::Tuple{F,F}, b::Tuple{F,F}, c::Tuple{F,F})::Bool
        return a[1]*(b[2]-c[2])+b[1]*(c[2]-a[2])+c[1]*(a[2]-b[2]) > 0.0
    end
    function ccw(a::Tuple{F,F}, b::Tuple{F,F}, c::Tuple{F,F})::Bool
        return a[1]*(b[2]-c[2])+b[1]*(c[2]-a[2])+c[1]*(a[2]-b[2]) < 0.0
    end
    ptarr = copy(pts)
    sort!(ptarr)
    p1 = ptarr[1]
    p2 = ptarr[end]
    up::Vector{Tuple{F,F}},dn::Vector{Tuple{F,F}} = Vector{Tuple{F,F}}(),Vector{Tuple{F,F}}()
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
    res = Vector{Tuple{F,F}}()
    for pt in up[1:end-1]; push!(res,pt); end
    for pt in dn[end:-1:2]; push!(res,pt); end
    return res
end

function shoelace(pts::Vector{Tuple{F,F}})::F
    area2::F = 0.0
    for i::I in 1:length(pts)
        j::I = (i == length(pts)) ? 1 : i+1
        k::I = (i == 1) ? length(pts) : i-1
        area2 += pts[i][1]*pts[j][2]
        area2 -= pts[i][1]*pts[k][2]
    end
    return 0.5*area2
end

######################################################################################################
### We first orient the cube such that the corners are all directly above/below the X/Z axes with the
### two faces paralell to the ground.  This gives us a minimal shadow of exactly 1.  Then, if we rotate
### the cube by asin(sqrt(2)/sqrt(3)), we will get the maximal area of sqrt(3).  The shadow's area is
### monotonic increasing in this interval, so we can just do a binary search.
######################################################################################################

function solve(A::F)::VS
    theta::F = solveit(A)
    faces = getFaces(theta)
    return [join([faces[i,j] for i in 1:3]," ") for j in 1:3]
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        A::F = gf()
        ans = solve(A)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

