################################################################################
## Prime table -- for reference
## 10^2  : 101
## 10^3  : 1009
## 10^4  : 10007
## 10^5  : 100003
## 10^6  : 1000003
## 10^7  : 10000019
## 10^8  : 100000007
## 10^9  : 1000000007
## 10^10 : 10000000019
## 10^11 : 100000000003
## 10^12 : 1000000000039
## 10^13 : 10000000000037
## 10^14 : 100000000000031
## 10^15 : 1000000000000037
## 10^16 : 10000000000000061
## 10^17 : 100000000000000003
## 10^18 : 1000000000000000003
## 
## 2*10^2  : 211
## 2*10^3  : 2003
## 2*10^4  : 20011
## 2*10^5  : 200003
## 2*10^6  : 2000003
## 2*10^7  : 20000003
## 2*10^8  : 200000033
## 2*10^9  : 2000000011
## 2*10^10 : 20000000089
## 2*10^11 : 200000000041
## 2*10^12 : 2000000000003
## 2*10^13 : 20000000000021
## 2*10^14 : 200000000000027
## 2*10^15 : 2000000000000021
## 2*10^16 : 20000000000000003
## 2*10^17 : 200000000000000003
## 2*10^18 : 2000000000000000057
## 
## 3*10^2  : 307
## 3*10^3  : 3001
## 3*10^4  : 30011
## 3*10^5  : 300007
## 3*10^6  : 3000017
## 3*10^7  : 30000001
## 3*10^8  : 300000007
## 3*10^9  : 3000000019
## 3*10^10 : 30000000001
## 3*10^11 : 300000000077
## 3*10^12 : 3000000000013
## 3*10^13 : 30000000000011
## 3*10^14 : 300000000000089
## 3*10^15 : 3000000000000037
## 3*10^16 : 30000000000000029
## 3*10^17 : 300000000000000011
## 3*10^18 : 3000000000000000037
## 
## 5*10^2  : 503
## 5*10^3  : 5003
## 5*10^4  : 50021
## 5*10^5  : 500009
## 5*10^6  : 5000011
## 5*10^7  : 50000017
## 5*10^8  : 500000003
## 5*10^9  : 5000000029
## 5*10^10 : 50000000021
## 5*10^11 : 500000000023
## 5*10^12 : 5000000000053
## 5*10^13 : 50000000000053
## 5*10^14 : 500000000000057
## 5*10^15 : 5000000000000023
## 5*10^16 : 50000000000000051
## 5*10^17 : 500000000000000021
## 5*10^18 : 5000000000000000003
################################################################################

## Minimum slope increment to bisect slopes is 1/2 * 1/2e6 * 1/2e6 = 1/8 * 1/2e12
## We choose a slope increment of 2/100000000000031, which should be sufficient
## Also, we scale up all of the numbers by 1e9 so that we work in integers

mutable struct Pt
    x::Int64
    y::Int64
end

function getdxdy(x)
    den = 100000000000031
    return x == den ? (den,den-1) : x < den ? (den,x) : (x,den)
end

function tryit(PP::Vector{Pt},dx::Int64,dy::Int64)::Int64
    (x1,y1,x2,y2) = solvexy1(PP,dx,dy)
    (q1,q2,q3,q4,degen) = getquadguts(PP,x1,y1,x2,y2,dx,dy)
    print("DBG: x1:$x1 y1:$y1 x2:$x2 y2:$y2 dx:$dx dy:$dy q1:$q1 q2:$q2 q3:$q3 q4:$q4 degen:$degen\n")
    return q1
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        scaleup = 10^9
        PP::Vector{Pt} = []
        for i in 1:4N
            x,y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            push!(PP,Pt(scaleup*x,scaleup*y))
        end

        myprime = 100000000000031
        l = -myprime+1; (q1l,degen1l) = solvelite(PP,myprime,l)
        r = myprime-1;  (q1r,degen1r) = solvelite(PP,myprime,r)
        if degen1l != 0 || degen1r != 0; print("ERROR\n"); continue; end
        if q1l < N && q1r < N || q1l > N && q1r > N; print("ERROR2\n"); continue; end
        if q1l == N ; stage2(PP,l-1,l,r,myprime); continue; end
        if q1r == N ; stage2(PP,l,r,r+1,myprime); continue; end
        m = stage1(PP,l,r,myprime)
        if m != 0; stage2(PP,l,m,r,myprime); end
    end
end

function stage1(PP::Vector{Pt},l::Int64,r::Int64,myprime::Int64)
    fourn = length(PP)
    N = fourn ÷ 4
    (q1l,degen1l) = solvelite(PP,myprime,l)
    (q1r,degen1r) = solvelite(PP,myprime,r)
    #print("\nDBG: l:$l q1l:$q1l degen1l:$degen1l\n")
    #print("DBG: r:$r q1r:$q1r degen1r:$degen1r\n")

    while true
        m = (l+r) ÷ 2
        if m == 0; m = 1; end
        if m == l || m == r; print("ERROR3\n"); return 0; end
        (q1m,degen1m) = solvelite(PP,myprime,m)
        if degen1m != 0; print("ERROR4\n"); return 0; end
        #print("DBG: m:$m q1m:$q1m degen1m:$degen1m\n")
        if q1m == N; return m; end
        if q1l < N && q1m < N || q1l > N && q1m > N; l = m; else; r = m; end
    end
end

function stage2(PP::Vector{Pt},l::Int64,m::Int64,r::Int64,myprime::Int64)
    ## print("DBG: enter stage2\n")
    (s1,s2) = getsets(PP,myprime,m)
    ## Do the left search
    ll,ml = l,m
    while (ml-ll > 1)
        mm = (ml+ll) ÷ 2
        (t1,t2) = getsets(PP,myprime,mm)
        if (s1,s2) == (t1,t2); ml = mm; else; ll = mm; end
    end

    ## Do the right search
    mr,rr = m,r
    while (rr-mr > 1)
        mm = (rr+mr) ÷ 2
        (t1,t2) = getsets(PP,myprime,mm)
        if (s1,s2) == (t1,t2); mr = mm; else; rr = mm; end
    end
    ## print("DBG: l:$(l/myprime) m:$(m/myprime) r:$(r/myprime) ml:$(ml/myprime) mr:$(mr/myprime)\n")

    finalsolve(PP,myprime,(ml+mr)÷2)
end

function getbreakpoints(PP::Vector{Pt},dx::Int64,dy::Int64)::Tuple{Int64,Int64,Int64,Int64}
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
    ## print("DBG: breakpoints dx:$dx dy:$dy PPP1:$PPP1 PPP2:$PPP2\n")
    #if PP1[2N][1] == 0 || PP1[2N+1][1] == 0 || PP2[2N][1] == 0 || PP2[2N+1][1] == 0; return (0,0,0,0); end
    return (PP1[2N][2],PP1[2N+1][2],PP2[2N][2],PP2[2N+1][2])
end

function getsets(PP::Vector{Pt},dx::Int64,dy::Int64)::Tuple{Set{Int64},Set{Int64}}
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
    PPP1::Vector{Int64} = [PP1[i][2] for i in 1:2N]
    PPP2::Vector{Int64} = [PP2[i][2] for i in 1:2N]
    return (Set(PPP1),Set(PPP2))
end


function solvelite(PP::Vector{Pt},dx::Int64,dy::Int64)::Tuple{Int64,Int64}
    (i1,i2,i3,i4) = getbreakpoints(PP,dx,dy)
    (p1,p2,p3,p4) = (PP[i1],PP[i2],PP[i3],PP[i4]) 
    x1::Int64 = (p1.x + p2.x) ÷ 2
    y1::Int64 = (p1.y + p2.y) ÷ 2
    x2::Int64 = (p3.x + p4.x) ÷ 2
    y2::Int64 = (p3.y + p4.y) ÷ 2
    (q1,q2,q3,q4,degen) = getquadguts(PP,x1,y1,x2,y2,dx,dy)
    if degen == 0 && q1+q2 != q3+q4; print("ERROR6\n"); end
    if degen == 0 && q1+q4 != q2+q3; print("ERROR7\n"); end
    return (q1,degen)
end

function finalsolve(PP::Vector{Pt},dx::Int64,dy::Int64)
    (i1,i2,i3,i4) = getbreakpoints(PP,dx,dy)
    (p1,p2,p3,p4) = (PP[i1],PP[i2],PP[i3],PP[i4]) 
    x1::Int64 = (p1.x + p2.x) ÷ 2
    y1::Int64 = (p1.y + p2.y) ÷ 2
    x2::Int64 = (p3.x + p4.x) ÷ 2
    y2::Int64 = (p3.y + p4.y) ÷ 2
    xnum::BigInt = BigInt(dy)*BigInt(dy)*BigInt(x1) + 
                   BigInt(dy)*BigInt(dx)*(BigInt(y2-y1)) +
                   BigInt(dx)*BigInt(dx)*BigInt(x2)
    ynum::BigInt = BigInt(dy)*BigInt(dy)*BigInt(y2) + 
                   BigInt(dy)*BigInt(dx)*(BigInt(x2-x1)) +
                   BigInt(dx)*BigInt(dx)*BigInt(y1)
    xydenom::BigInt = BigInt(dy)*BigInt(dy) + BigInt(dx)*BigInt(dx)

    x3::Int64 = Int64(xnum ÷ xydenom)
    y3::Int64 = Int64(ynum ÷ xydenom)
    (q1,q2,q3,q4,degen) = getquadguts(PP,x1,y1,x2,y2,dx,dy)
    if degen != 0 || q1 != q2 || q1 != q3 || q1 != q4; print("ERROR10a q1:$q1 q2:$q2 q3:$q3 q4:$q4 degen:$degen\n"); return; end
    (q1,q2,q3,q4,degen) = getquadguts(PP,x3,y3,x3,y3,dx,dy)
    if degen != 0 || q1 != q2 || q1 != q3 || q1 != q4; print("ERROR10 q1:$q1 q2:$q2 q3:$q3 q4:$q4 degen:$degen\n"); return; end
    doans(x3,y3,dx,dy)
end

function getquadguts(PP::Vector{Pt},x1::Int64,y1::Int64,x2::Int64,y2::Int64,dx::Int64,dy::Int64)
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

function doans(x::Int64,y::Int64,dx::Int64,dy::Int64)
    dostr(x::Int64) = string(x ÷ 10^9) * "." * lpad(string(abs(x % 10^9)),9,'0')
    x1 = x + dx
    y1 = y + dy
    xstr = dostr(x)
    ystr = dostr(y)
    x1str = dostr(x1)
    y1str = dostr(y1)
    print("$xstr $ystr $x1str $y1str\n")
end

main()

