
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

convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) < 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) > 0
function convexHull(a::Vector{Pt},idxFlag::Bool=true)
    mycmp(aa::I,bb::I)::Bool = convexHullCmp(a[aa],a[bb])
    mycw(aa::I,bb::I,cc::I) = convexHullCw(a[aa],a[bb],a[cc])
    myccw(aa::I,bb::I,cc::I) = convexHullCcw(a[aa],a[bb],a[cc])
    N = length(a)
    if length(a) == 1; return idxFlag ? [1] : [a[1]]; end
    aidx = collect(1:N); sort!(aidx,lt=mycmp)
    p1::I,p2::I = aidx[1],aidx[end]
    up::VI = []; down::VI = []
    push!(up,p1); push!(down,p1)
    for i in 2:length(aidx)
        if i == length(aidx) || mycw(p1,aidx[i],p2)
            while length(up) >= 2 && !mycw(up[end-1], up[end], aidx[i]); pop!(up); end
            push!(up,aidx[i])
        end
        if i == length(aidx) || myccw(p1,aidx[i],p2)
            while length(down) >= 2 && !myccw(down[end-1],down[end],aidx[i]); pop!(down); end
            push!(down,aidx[i])
        end
    end
    idxarr::VI = vcat(up,down[end-1:-1:2])
    return idxFlag ? idxarr : [a[x] for x in idxarr]
end

## Useful routine for for sorting out angles
## Returns (dot product,cross product,quadrant) where angle is assumed between 0deg and 180deg.  Let angle be x, then
## 0 if x = 0deg, 1 if 0deg<x<90deg, 2 if x = 90deg, 3 if 90deg<x<180deg, 4 if x == 180deg.
function getcpdpq(a::Pt,b::Pt)::TI
    dp = a.x*b.x+a.y*b.y
    cp = a.x*b.y-a.y*b.x
    q = (cp == 0 && dp > 0) ? 0 : dp > 0 ? 1 : dp == 0 ? 2 : (cp == 0 && dp < 0) ? 4 : 3
    return (dp,cp,q)
end


## Treat like numbers in the complex plane
## Let S1 be the star we choose for the first rotation, S2 the second, etc.
## P1 = S1 + -i*(P0-S1) = (1+i)*S1
## P2 = S2 + -i*(P1-S2) = (1+i)*S2 - i*P1 = (1+i)*S2 + (1-i)*S1
## P3 = S3 + -i*(P2-S3) = (1+i)*S3 - i*P2 = (1+i)*S3 + (1-i)*S2 + (-1-i)*S1
## P4 = S4 + -i*(P3-S4) = (1+i)*S4 - i*P3 = (1+i)*S4 + (1-i)*S3 + (-1-i)*S2 + (-1+i)*S1
## ...
## Pn = (1+i)*(Sn+Snm4+Snm8+...) + (1-i)*(Snm1+Snm5+Snm9+...) + (-1-i)*(Snm2+Snm6+Snm10+...) + (-1+i)*(Snm3+Snm7+Snm11+...)
## Note that it doesn't make sense to pick different numbers within each of the quadrant sums, so we are just looking
## for (up-to) 4 points to use.

## For the small, we just loop through the 4 possibilities for each 
function solveSmall(N::I,M::I,X::VI,Y::VI)::F
    c::Vector{Complex} = [X[i] + 1im*Y[i] for i in 1:N]
    mtrys::VI = M == 1 ? [M] : M == 2 ? [M-1,M] : M == 3 ? [M-2,M-1,M] : [M-3,M-2,M-1,M]
    ans::F = 0.0
    for mm in mtrys
        m::VI = [(mm+3)÷4, (mm+2)÷4, (mm+1)÷4, mm÷4]
        for i1 in 1:N
            for i2 in 1:N
                for i3 in 1:N
                    for i4 in 1:N
                        cand::Complex = (1+1im)*m[1]*c[i1] + (1-1im)*m[2]*c[i2] + (-1-1im)*m[3]*c[i3] + (-1+1im)*m[4]*c[i4]
                        ans = max(ans,abs(cand))
                    end
                end
            end
        end
    end
    return ans
end

function checkColinear(N::I,X::VI,Y::VI)::Bool
    if N <= 2; return true; end
    xref = X[2]-X[1]; yref = Y[2]-Y[1]
    for i in 3:N
        xa = X[i]-X[1]; ya = Y[i]-Y[1]
        if xref*ya-yref*xa != 0; return false; end
    end
    return true
end

function doColinear(N::I,M::I,X::VI,Y::VI)::F
    pt1 = Pt(0,0); pt2 = Pt(0,0)
    if X[2]-X[1] != 0
        i1,i2 = 1,1
        for i in 2:N; if X[i] > X[i1]; i1 = i; end; end
        for i in 2:N; if X[i] < X[i2]; i2 = i; end; end
        pt1=Pt(X[i1],Y[i1]); pt2=Pt(X[i2],Y[i2])
    else
        i1,i2 = 1,1
        for i in 2:N; if Y[i] > Y[i1]; i1 = i; end; end
        for i in 2:N; if Y[i] < Y[i2]; i2 = i; end; end
        pt1=Pt(X[i1],Y[i1]); pt2=Pt(X[i2],Y[i2])
    end
    ans1 = evalquad(M,pt1,pt1,pt2,pt2)
    ans2 = evalquad(M,pt1,pt2,pt2,pt1)
    ans3 = evalquad(M,pt2,pt2,pt1,pt1)
    ans4 = evalquad(M,pt2,pt1,pt1,pt2)
    return max(ans1,ans2,ans3,ans4)
end

function evalquad(M::Int64,pt1::Pt,pt2::Pt,pt3::Pt,pt4::Pt)::F
    c1,c2,c3,c4 = pt1.x+1im*pt1.y, pt2.x+1im*pt2.y, pt3.x+1im*pt3.y, pt4.x+1im*pt4.y
    cands::Vector{Complex{Int64}} = []
    push!(cands,(1+1im)*c2 + (1-1im)*c1)
    if M > 2; push!(cands,(1+1im)*(c3-c1) + (1-1im)*c2); end
    if M >= 4
        q = M ÷ 4 - 1
        for x in 4*q:M
            qq = x ÷ 4
            if x % 4 == 0;     push!(cands,(1+1im)*(qq)*c4 + (1-1im)*(qq)*c3 + (-1-1im)*(qq)*c2 + (-1+1im)*qq*c1)
            elseif x % 4 == 1; push!(cands,(1+1im)*(qq+1)*c1 + (1-1im)*(qq)*c4 + (-1-1im)*(qq)*c3 + (-1+1im)*qq*c2)
            elseif x % 4 == 2; push!(cands,(1+1im)*(qq+1)*c2 + (1-1im)*(qq+1)*c1 + (-1-1im)*(qq)*c4 + (-1+1im)*qq*c3)
            else               push!(cands,(1+1im)*(qq+1)*c3 + (1-1im)*(qq+1)*c2 + (-1-1im)*(qq+1)*c1 + (-1+1im)*qq*c4)
            end
        end
    end
    ans = maximum(abs(x) for x in cands)
    return ans
end

function evalinc(chull::Vector{Pt},n::I,i1::I,i2::I,i3::I,i4::I,dir::Pt)::Int64
    (ans,dp,cp,q) = (0,0,0,0)
    mydir = Pt(dir.x,dir.y)
    for idx in 1:4
        ii = idx == 1 ? i1 : idx == 2 ? i2 : idx == 3 ? i3 : i4
        nii = ii == n ? 1 : ii+1
        hv = Pt(chull[nii].x-chull[ii].x,chull[nii].y-chull[ii].y)
        (candcp,canddp,candq) = getcpdpq(hv,mydir)
        if idx == 1
            (ans,cp,dp,q) = (idx,candcp,canddp,candq)
        elseif candq < q || candq == q && (q == 1 || q == 3) && canddp * cp < dp * candcp
            (ans,cp,dp,q) = (idx,candcp,canddp,candq)
        end
        mydir = Pt(mydir.y,-mydir.x)
    end
    return ans
end

function solveLarge(N::I,M::I,X::VI,Y::VI)::F
    if M == 1; return maximum(abs((1+1im)*(X[i]+1im*Y[i])) for i in 1:N); end
    ans = maximum(2*abs(X[1]+1im*Y[1]) for i in 1:N)
    if N == 1 ; return ans; end
    if checkColinear(N,X,Y); return max(ans,doColinear(N,M,X,Y)); end
    pts::Vector{Pt} = [Pt(X[i],Y[i]) for i in 1:N]
    chullis = convexHull(pts)
    chull::Vector{Pt} = [Pt(X[i],Y[i]) for i in chullis]
    n = length(chull)
    ## Get the initial setup
    i1,i2,i3,i4 = 1,1,1,1
    for i in 2:n
        if chull[i].y > chull[i1].y || chull[i].y == chull[i1].y && chull[i].x > chull[i1].x; i1 = i; end
        if chull[i].x > chull[i2].x || chull[i].x == chull[i2].x && chull[i].y < chull[i2].y; i2 = i; end
        if chull[i].y < chull[i3].y || chull[i].y == chull[i3].y && chull[i].x < chull[i3].x; i3 = i; end
        if chull[i].x < chull[i4].x || chull[i].x == chull[i4].x && chull[i].y > chull[i4].y; i4 = i; end
    end
    si1,si2,si3,si4 = i1,i2,i3,i4
    dir = Pt(1,0)
    curpt::Pt = Pt(0,0)
    lastpt::Pt = Pt(0,0)
    while (true)
        #print("DBG: eval i1:$i1 i2:$i2 i3:$i3 i4:$i4 dir:$(dir.x) $(dir.y)\n")
        ans = max(ans,evalquad(M,chull[i1],chull[i2],chull[i3],chull[i4]))
        idxinc = evalinc(chull,n,i1,i2,i3,i4,dir)
        if     idxinc == 1; ni1 = i1 == n ? 1 : i1+1; curpt=chull[ni1]; lastpt=chull[i1]; i1 = ni1
        elseif idxinc == 2; ni2 = i2 == n ? 1 : i2+1; curpt=chull[ni2]; lastpt=chull[i2]; i2 = ni2
        elseif idxinc == 3; ni3 = i3 == n ? 1 : i3+1; curpt=chull[ni3]; lastpt=chull[i3]; i3 = ni3
        else;               ni4 = i4 == n ? 1 : i4+1; curpt=chull[ni4]; lastpt=chull[i4]; i4 = ni4
        end
        mydir = Pt(curpt.x-lastpt.x,curpt.y-lastpt.y)
        dir = idxinc == 1 ? mydir :
              idxinc == 2 ? Pt(-mydir.y,mydir.x) :
              idxinc == 3 ? Pt(-mydir.x,-mydir.y) : Pt(mydir.y,-mydir.x)
        if i1 == si1 && i2 == si2 && i3 == si3 && i4 == si4; break; end
    end
    return ans
end

function gencase(Nmin::I,Nmax::I,Mmin::I,Mmax::I,Cmax::I)
    N = rand(Nmin:Nmax)
    M = rand(Mmin:Mmax)
    ss::SPI = SPI()
    while length(ss) < N; push!(ss,(rand(-Cmax:Cmax),rand(-Cmax:Cmax))); end
    lss::VPI = [x for x in ss]
    shuffle!(lss)
    X::VI = [x[1] for x in lss]
    Y::VI = [x[2] for x in lss]
    return (N,M,X,Y)
end

function isApproximatelyEqual(x::F,y::F,epsilon::F)::Bool
    if -epsilon <= x - y <= epsilon; return true; end
    if -epsilon <= x <= epsilon || -epsilon <= y <= epsilon; return false; end
    if -epsilon <= (x - y) / x <= epsilon; return true; end
    if -epsilon <= (x - y) / y <= epsilon; return true; end
    return false
end

function test(ntc::I,Nmin::I,Nmax::I,Mmin::I,Mmax::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,M,X,Y) = gencase(Nmin,Nmax,Mmin,Mmax,Cmax)
        ans2 = solveLarge(N,M,X,Y)
        if check
            ans1 = solveSmall(N,M,X,Y)
            if isApproximatelyEqual(ans1,ans2,1e-8)
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,M,X,Y)
                ans2 = solveLarge(N,M,X,Y)
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
        M = gi()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,M,X,Y)
        ans = solveLarge(N,M,X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,1,10,1,10,1000)

