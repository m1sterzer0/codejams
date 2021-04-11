
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

function getdxdy(x)
    den = 10000000000000061
    return x == den ? (den,den-1) : x < den ? (den,x) : (2*den-x,den)
end

function getbreakpoints(PP::Vector{Pt},dx::I,dy::I)::QI
    ddx = Int128(dx)
    ddy = Int128(dy)
    PP1::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    PP2::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    for (i,p) in enumerate(PP)
        xp1::Int128 = ddx*p.y-ddy*p.x  ## Vector 1 in (den,num)
        xp2::Int128 = -ddy*p.y-ddx*p.x ## Orthogonal vector is (-num,den)
        push!(PP1,(xp1,i))
        push!(PP2,(xp2,i))
    end
    sort!(PP1)
    sort!(PP2)
    N = length(PP) ÷ 4
    PPP1 = [PP1[i][2] for i in 1:2N]
    PPP2 = [PP2[i][2] for i in 1:2N]
    #print("DBG: breakpoints dx:$dx dy:$dy PPP1:$PPP1 PPP2:$PPP2\n")
    #if PP1[2N][1] == 0 || PP1[2N+1][1] == 0 || PP2[2N][1] == 0 || PP2[2N+1][1] == 0; return (0,0,0,0); end
    return (PP1[2N][2],PP1[2N+1][2],PP2[2N][2],PP2[2N+1][2])
end

function getquadguts(PP::Vector{Pt},x1::I,y1::I,x2::I,y2::I,dx::I,dy::I)::Tuple{I,I,I,I,I}
    ddx = Int128(dx)
    ddy = Int128(dy)
    (q1,q2,q3,q4,degen) = (0,0,0,0,0)
    for p::Pt in PP
        xp1::Int128 = ddx*(p.y-y1)-ddy*(p.x-x1)  ## Vector 1 in (den,num)
        xp2::Int128 = -ddy*(p.y-y2)-ddx*(p.x-x2) ## Orthogonal vector is (-num,den)
        if     xp1 > 0 && xp2 < 0; q1 += 1
        elseif xp1 > 0 && xp2 > 0; q2 += 1
        elseif xp1 < 0 && xp2 > 0; q3 += 1
        elseif xp1 < 0 && xp2 < 0; q4 += 1
        else; degen += 1
        end
    end
    return (q1,q2,q3,q4,degen)
end

function solvelite(PP::Vector{Pt},dx::I,dy::I)::PI
    (i1,i2,i3,i4) = getbreakpoints(PP,dx,dy)
    (p1,p2,p3,p4) = (PP[i1],PP[i2],PP[i3],PP[i4]) 
    x1::I = (p1.x + p2.x) ÷ 2
    y1::I = (p1.y + p2.y) ÷ 2
    x2::I = (p3.x + p4.x) ÷ 2
    y2::I = (p3.y + p4.y) ÷ 2
    (q1,q2,q3,q4,degen) = getquadguts(PP,x1,y1,x2,y2,dx,dy)
    #if degen == 0 && q1+q2 != q3+q4; print("ERROR6\n"); end
    #if degen == 0 && q1+q4 != q2+q3; print("ERROR7\n"); end
    return (q1,degen)
end

function getsets(PP::Vector{Pt},dx::I,dy::I)::Tuple{SI,SI}
    ddx = Int128(dx)
    ddy = Int128(dy)
    PP1::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    PP2::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    for (i,p) in enumerate(PP)
        xp1::Int128 = ddx*p.y-ddy*p.x  ## Vector 1 in (den,num)
        xp2::Int128 = -ddy*p.y-ddx*p.x ## Orthogonal vector is (-num,den)
        push!(PP1,(xp1,i))
        push!(PP2,(xp2,i))
    end
    sort!(PP1)
    sort!(PP2)
    N = length(PP) ÷ 4
    PPP1::VI = [PP1[i][2] for i in 1:2N]
    PPP2::VI = [PP2[i][2] for i in 1:2N]
    return (SI(PPP1),SI(PPP2))
end

function stage2a(PP::Vector{Pt},l::I,m::I,r::I)
    (dx,dy) = getdxdy(m); (s1,s2) = getsets(PP,dx,dy)
    #print("DBG: m:$m dx:$dx dy:$dy s1:$s1 s2:$s2\n")
    ## Do the left search
    ll,ml = l,m
    while (ml-ll > 1)
        mm = (ml+ll) ÷ 2
        (dx,dy) = getdxdy(mm)
        (t1,t2) = getsets(PP,dx,dy)
        #print("DBG: mm:$mm dx:$dx dy:$dy t1:$t1 t2:$t2\n")
        if (s1,s2) == (t1,t2); ml = mm; else; ll = mm; end
    end

    ## Do the right search
    mr,rr = m,r
    while (rr-mr > 1)
        mm = (rr+mr) ÷ 2
        (dx,dy) = getdxdy(mm)
        (t1,t2) = getsets(PP,dx,dy)
        #print("DBG: mm:$mm dx:$dx dy:$dy t1:$t1 t2:$t2\n")
        if (s1,s2) == (t1,t2); mr = mm; else; rr = mm; end
    end
    ans = (ml+mr) ÷ 2
    #print("DBG: ml:$ml mr:$mr ans:$ans\n")
    return ans
end

function finalsolve(PP::Vector{Pt},dx::I,dy::I)
    (i1,i2,i3,i4) = getbreakpoints(PP,dx,dy)
    (p1,p2,p3,p4) = (PP[i1],PP[i2],PP[i3],PP[i4]) 
    x1::I = (p1.x + p2.x) ÷ 2
    y1::I = (p1.y + p2.y) ÷ 2
    x2::I = (p3.x + p4.x) ÷ 2
    y2::I = (p3.y + p4.y) ÷ 2
    xnum::BigInt = BigInt(dy)*BigInt(dy)*BigInt(x1) + 
                   BigInt(dy)*BigInt(dx)*(BigInt(y2-y1)) +
                   BigInt(dx)*BigInt(dx)*BigInt(x2)
    ynum::BigInt = BigInt(dy)*BigInt(dy)*BigInt(y2) + 
                   BigInt(dy)*BigInt(dx)*(BigInt(x2-x1)) +
                   BigInt(dx)*BigInt(dx)*BigInt(y1)
    xydenom::BigInt = BigInt(dy)*BigInt(dy) + BigInt(dx)*BigInt(dx)

    x3::I = Int64(xnum ÷ xydenom)
    y3::I = Int64(ynum ÷ xydenom)
    (q1,q2,q3,q4,degen) = getquadguts(PP,x1,y1,x2,y2,dx,dy)
    #if degen != 0 || q1 != q2 || q1 != q3 || q1 != q4; print("ERROR10a q1:$q1 q2:$q2 q3:$q3 q4:$q4 degen:$degen\n"); return; end
    (q1,q2,q3,q4,degen) = getquadguts(PP,x3,y3,x3,y3,dx,dy)
    #if degen != 0 || q1 != q2 || q1 != q3 || q1 != q4; print("ERROR10 q1:$q1 q2:$q2 q3:$q3 q4:$q4 degen:$degen\n"); return; end
    return doans(x3,y3,dx,dy)
end

function doans(x::Int64,y::Int64,dx::Int64,dy::Int64)::VS
    dostr(x::Int64) = (x < 0 ? "-" : "") * string(abs(x) ÷ 10^9) * "." * lpad(string(abs(x) % 10^9),9,'0')
    x1 = x + dx
    y1 = y + dy
    return [dostr(x),dostr(y),dostr(x1),dostr(y1)]
end

function stage1(PP::Vector{Pt},l::I,r::I)
    fourn = length(PP)
    N = fourn ÷ 4
    (dxl,dyl) = getdxdy(l)
    (dxr,dyr) = getdxdy(r)
    (q1l,degen1l) = solvelite(PP,dxl,dyl)
    (q1r,degen1r) = solvelite(PP,dxr,dyr)

    while true
        m = (l+r) ÷ 2
        #if m == l || m == r; print("ERROR3\n"); return 0; end
        (dxm,dym) = getdxdy(m)
        (q1m,degen1m) = solvelite(PP,dxm,dym)
        #if degen1m != 0; print("ERROR4\n"); return 0; end
        if q1m == N; return m; end
        if q1l < N && q1m < N || q1l > N && q1m > N; l = m; else; r = m; end
    end
end

function stage2(PP::Vector{Pt},l::I,m::I,r::I)
    mm = stage2a(PP,l,m,r)
    (dx,dy) = getdxdy(mm)
    return finalsolve(PP,dx,dy)
end

function solve(N::I,X::VI,Y::VI)::VS
    scaleup::I = 10^9
    PP::Vector{Pt} = [Pt(scaleup*X[i],scaleup*Y[i]) for i in 1:4N] 
    myprime = 10000000000000061
    l = 1;           (dxl,dyl) = getdxdy(l); (q1l,degen1l) = solvelite(PP,dxl,dyl)
    r = 2*myprime-1; (dxr,dyr) = getdxdy(r); (q1r,degen1r) = solvelite(PP,dxr,dyr)
    #if degen1l != 0 || degen1r != 0; print("ERROR\n"); end
    #if q1l < N && q1r < N || q1l > N && q1r > N; print("ERROR2\n"); end
    if q1l == N && q1r == N
        m1 = stage2a(PP,l-1,l,r)
        m2 = stage2a(PP,l,r,r+1)
        mm = (m1-l >= r-m2) ? m1 : m2
        (dx,dy) = getdxdy(mm)
        return finalsolve(PP,dx,dy)
    end
    if q1l == N ; return stage2(PP,l-1,l,r); end
    if q1r == N ; return stage2(PP,l,r,r+1); end
    m = stage1(PP,l,r); return stage2(PP,l,m,r)
end

function iscolinear(p1::PI,p2::PI,p3::PI)::Bool
    dx1 = p2[1]-p1[1]
    dy1 = p2[2]-p1[2]
    dx2 = p3[1]-p1[1]
    dy2 = p3[2]-p1[2]
    return dx1*dy2-dy1*dx2 == 0
end

function gencase(Nmin::I,Nmax::I,Cmax::I)
    N = rand(Nmin:Nmax)
    fourn = 4N
    pts::VPI = []
    while length(pts) < fourn
        x1 = rand(-Cmax:Cmax)
        y1 = rand(-Cmax:Cmax)
        if (x1,y1) in pts; continue; end
        good = true
        for i in 1:length(pts)
            for j in i+1:length(pts)
                if iscolinear(pts[i],pts[j],(x1,y1)); good = false; end
            end
        end
        if good; push!(pts,(x1,y1)); end
    end
    X::VI = [x[1] for x in pts]
    Y::VI = [x[2] for x in pts]
    return (N,X,Y)
end

function test(ntc::I,Nmin::I,Nmax::I,Cmax::I)
    for ttt in 1:ntc
        (N,X,Y) = gencase(Nmin,Nmax,Cmax)
        ans = solve(N,X,Y)
        print("Case #$ttt: $ans\n")
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::VI = fill(0,4N)
        Y::VI = fill(0,4N)
        for i in 1:4N; X[i],Y[i] = gis(); end
        ans = solve(N,X,Y)
        print("$(ans[1]) $(ans[2]) $(ans[3]) $(ans[4])\n")
    end
end

Random.seed!(8675309)
main()
#test(100,1,1,5)
#test(100,2,2,10)
#test(100,3,3,100)
#test(100,1,10,1000)
#test(100,1,10,1000000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

