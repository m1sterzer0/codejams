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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        m = 10^9
        PP::Vector{Pt} = []
        for i in 1:4N
            x,y = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            push!(PP,Pt(m*x,m*y))
        end
        den = 100000000000031
        l = -50000000000015
        r =  50000000000016
        (x1,y1,q1) = tryit(PP,Int128(2*l),Int128(den))
        (x2,y2,q2) = tryit(PP,Int128(2*r),Int128(den))
        print("\nDBG: l:$l x1:$(dostr(x1)) y1:$(dostr(y1)) q1:$q1\n")
        print("DBG: r:$r x2:$(dostr(x2)) y2:$(dostr(y2)) q2:$q2\n")
        if q1 == N; doans(x1,y1,2*l,den,PP); continue; end
        if q2 == N; doans(x2,y2,2*r,den,PP); continue; end
        if q1 < N && q2 < N; print("ERROR\n"); continue; end
        if q1 > N && q2 > N; print("ERROR\n"); continue; end
        while true
            m = (r+l) >> 1
            if m == 0; m = 1; end
            if m >= r || m <= l; print("IMPOSSIBLE\n"); break; end
            (x3,y3,q3) = tryit(PP,Int128(2*m),Int128(den))
            print("DBG: m:$m x3:$(dostr(x3)) y3:$(dostr(y3)) q3:$q3\n")
            if q3 == N; doans(x3,y3,2*m,den,PP); break; end
            if q3 < N && q1 < N || q3 > N && q1 > N; l = m
            else; r = m
            end
        end
    end
end

function tryit(PP::Vector{Pt},num::Int128,den::Int128)
    PP1::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    PP2::Vector{Tuple{Int128,Int64}} = Vector{Tuple{Int128,Int64}}()
    for (i,p) in enumerate(PP)
        xp1::Int128 = den*p.y-num*p.x  ## Vector 1 in (den,num)
        xp2::Int128 = -num*p.y-den*p.x ## Orthogonal vector is (-num,den)
        push!(PP1,(xp1,i))
        push!(PP2,(xp2,i))
    end
    sort!(PP1)
    sort!(PP2)
    N = length(PP) ÷ 4
    p1::Pt,p2::Pt,p3::Pt,p4::Pt = PP[PP1[2N][2]],PP[PP1[2N+1][2]],PP[PP2[2N][2]],PP[PP2[2N+1][2]]
    x1::Int64 = (p1.x + p2.x) ÷ 2
    y1::Int64 = (p1.y + p2.y) ÷ 2
    x2::Int64 = (p3.x + p4.x) ÷ 2
    y2::Int64 = (p3.y + p4.y) ÷ 2
    check(x1,y1,x1+Int64(den),y1+Int64(num),PP)
    check(x2,y2,x2-Int64(num),y2+Int64(den),PP)

    xnum::BigInt = BigInt(num)*BigInt(num)*BigInt(x1) + 
                   BigInt(num)*BigInt(den)*(BigInt(y2-y1)) +
                   BigInt(den)*BigInt(den)*BigInt(x2)
    ynum::BigInt = BigInt(num)*BigInt(num)*BigInt(y2) + 
                   BigInt(num)*BigInt(den)*(BigInt(x2-x1)) +
                   BigInt(den)*BigInt(den)*BigInt(y1)
    xydenom::BigInt = BigInt(num)*BigInt(num) + BigInt(den)*BigInt(den)

    x3::Int64 = Int64(xnum ÷ xydenom)
    y3::Int64 = Int64(ynum ÷ xydenom)

    ## Looks like we need to try nearby points
    x4::Int64 = x3
    y4::Int64 = y3

    good = false
    for xdelta in -1:1
        for ydelta in -1:1
            x4 = x3 + xdelta
            y4 = y3 + ydelta
            vx1 = Int128(p1.x-x4); vy1 = Int128(p1.y-y4); cp1 = den*vy1-num*vx1
            vx2 = Int128(p2.x-x4); vy2 = Int128(p2.y-y4); cp2 = den*vy2-num*vx2
            if cp1 > 0 && cp2 > 0 || cp1 < 0 && cp2 < 0; continue; end
            vx3 = Int128(p1.x-x4); vy3 = Int128(p1.y-y4); cp3 = (-num)*vy3-den*vx3
            vx4 = Int128(p2.x-x4); vy4 = Int128(p2.y-y4); cp4 = (-num)*vy4-den*vx4
            if cp3 > 0 && cp4 > 0 || cp3 < 0 && cp4 < 0; continue; end
            good = true
            break
        end
        if good; break; end
    end
    if !good; print("NO GOOD POINT FOUND!\n"); end
    check(x4,y4,x4+Int64(den),y4+Int64(num),PP)
    print("x1:$x1 y1:$y1 x2:$x2 y2:$y2 x3:$x3 y3:$y3 x4:$x4 y4:$y4\n")
    q1 = countquad(PP,x4,y4,Int64(num),Int64(den))
    return (x4,y4,q1)
end


function countdiv(a::Pt,b::Pt,PP::Vector{Pt})::Tuple{Int64,Int64,Int64}
    vx::Int128 = Int128(b.x-a.x)
    vy::Int128 = Int128(b.y-a.y)
    l::Int64,m::Int64,r::Int64 = 0,0,0
    for p::Pt in PP
        vv::Int128 = vx * Int128(p.y-a.y) - vy * Int128(p.x-a.x)
        if vv > 0.0; l += 1; elseif vv == 0.0; m += 1; else r += 1; end
    end
    return (l,m,r)

end

function countquad(PP::Vector{Pt},x1::Int64,y1::Int64,num::Int64,den::Int64)
    q::Int64 = 0
    (vx1,vy1) = (den,num)
    (vx2,vy2) = (-num,den)
    for p in PP
        if vx1 * Int128(p.y-y1) - vy1 * Int128(p.x-x1) <= 0; continue; end
        if vx2 * Int128(p.y-y1) - vy2 * Int128(p.x-x1) >= 0; continue; end
        q += 1
    end
    return q
end

dostr(x::Int64) = string(x ÷ 10^9) * "." * lpad(string(abs(x % 10^9)),9,'0')

function doans(x::Int64,y::Int64,num::Int64,den::Int64,PP::Vector{Pt})
    x1 = x + den
    y1 = y + num
    xstr = dostr(x)
    ystr = dostr(y)
    x1str = dostr(x1)
    y1str = dostr(y1)
    print("$xstr $ystr $x1str $y1str\n")
    check(x,y,x+den,y+num,PP)
end

function check(x1::Int64,y1::Int64,x2::Int64,y2::Int64,PP::Vector{Pt})
    dx = Int128(x2-x1)
    dy = Int128(y2-y1)
    q1,q2,q3,q4,degen = 0,0,0,0,0
    for p in PP
        dp = Int128(p.x-x1) * dx + Int128(p.y-y1) * dy
        cp = dx * Int128(p.y-y1) - dy * Int128(p.x-x1)
        if cp > 0 && dp > 0; q1 += 1
        elseif cp > 0 && dp < 0; q2 += 1
        elseif cp < 0 && dp < 0; q3 += 1
        elseif cp < 0 && dp > 0; q4 += 1
        else degen += 1
        end
    end
    status = (q2==q1 && q3==q1 && q4==q1 && degen==0) ? "pass" : "FAIL"
    print("DBG: $status (q1,q2,q3,q4,degen) = ($q1,$q2,$q3,$q4,$degen)\n")
end

main("Ctc4.in")

