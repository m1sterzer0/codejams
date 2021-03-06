## Treat like numbers in the complex plane
## Let S1 be the star we choose for the first rotation, S2 the second, etc.
## P1 = S1 + -i*(P0-S1) = (1+i)*S1
## P2 = S2 + -i*(P1-S2) = (1+i)*S2 - i*P1 = (1+i)*S2 + (1-i)*S1
## P3 = S3 + -i*(P2-S3) = (1+i)*S3 - i*P2 = (1+i)*S3 + (1-i)*S2 + (-1-i)*S1
## P4 = S4 + -i*(P3-S4) = (1+i)*S4 - i*P3 = (1+i)*S4 + (1-i)*S3 + (-1-i)*S2 + (-1+i)*S1
## ...
## Pn = (1+i)*(Sn+Snm4+Snm8+...) + (1-i)*(Snm1+Snm5+Snm9+...) + (-1-i)*(Snm2+Snm6+Snm10+...) + (-1+i)*(Snm3+Snm7+Snm11+...)

mutable struct Pt
    x::Int64
    y::Int64
end

convexHullCmp(a::Pt,b::Pt)::Bool = a.x < b.x || (a.x == b.x && a.y < b.y)
convexHullCw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) < 0
convexHullCcw(a::Pt,b::Pt,c::Pt)::Bool = a.x*(b.y-c.y)+b.x*(c.y-a.y)+c.x*(a.y-b.y) > 0
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

function checkColinear(N::Int64,X::Vector{Int64},Y::Vector{Int64})::Bool
    if N <= 2; return true; end
    xref = X[2]-X[1]
    yref = Y[2]-Y[1]
    for i in 3:N
        xa = X[i]-X[1]
        ya = Y[i]-Y[1]
        if xref*ya-yref*xa != 0; return false; end
    end
    return true
end

function doColinear(ans::Float64,N::Int64,M::Int64,X::Vector{Int64},Y::Vector{Int64})::Float64
    pt1 = Pt(0,0)
    pt2 = Pt(0,0)
    if X[2]-X[1] != 0
        i1,i2 = 1,1
        for i in 2:N; if X[i] > X[i1]; i1 = i; end; end
        for i in 2:N; if X[i] < X[i2]; i2 = i; end; end
        pt1=Pt(X[i1],Y[i1])
        pt2=Pt(X[i2],Y[i2])
    else
        i1,i2 = 1,1
        for i in 2:N; if Y[i] > Y[i1]; i1 = i; end; end
        for i in 2:N; if Y[i] < Y[i2]; i2 = i; end; end
        pt1=Pt(X[i1],Y[i1])
        pt2=Pt(X[i2],Y[i2])
    end
    ans = evalquad(ans,M,pt1,pt1,pt2,pt2)
    ans = evalquad(ans,M,pt1,pt2,pt2,pt1)
    ans = evalquad(ans,M,pt2,pt2,pt1,pt1)
    ans = evalquad(ans,M,pt2,pt1,pt1,pt2)
    return ans
end

#function evalquada(M::Int64,pt1::Pt,pt2::Pt,pt3::Pt,pt4::Pt)::Float64
#    c1,c2,c3,c4 = pt1.x+1im*pt1.y, pt2.x+1im*pt2.y, pt3.x+1im*pt3.y, pt4.x+1im*pt4.y
#    terms = [c1,c2,c3,c4,c1,c2,c3,c4,c1,c2,c3,c4,c1,c2,c3,c4,c1,c2,c3,c4]
#    loc = 0+0im
#    ans::Float64 = 0.00
#    for i in 1:M
#        loc = terms[i] + -1im*(loc-terms[i])
#        if abs(loc) > ans; ans = abs(loc); end
#    end
#    return ans
#end

function evalquadb(M::Int64,pt1::Pt,pt2::Pt,pt3::Pt,pt4::Pt)::Float64
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

function evalquad(ans::Float64,M::Int64,pt1::Pt,pt2::Pt,pt3::Pt,pt4::Pt)::Float64
    ans2 = evalquadb(M,pt1,pt2,pt3,pt4)
    return max(ans,ans2)
    #if M <= 4
    #    ans2 = evalquada(M,pt1,pt2,pt3,pt4)
    #    return max(ans,ans2)
    #elseif M <= 20
    #    ans2a = evalquada(M,pt1,pt2,pt3,pt4)
    #    ans2b = evalquadb(M,pt1,pt2,pt3,pt4)
    #    if ans2a != ans2b
    #        print("ERROR: ans2a:$ans2a ans2b:$ans2b do not match\n")
    #        ans2a = evalquada(M,pt1,pt2,pt3,pt4)
    #        ans2b = evalquadb(M,pt1,pt2,pt3,pt4)
    #    end
    #    return max(ans,ans2a)
    #else
    #    ans2b = evalquadb(M,pt1,pt2,pt3,pt4)
    #    return max(ans,ans2b)
    #end
end

function getcpdpq(hullvec::Pt,dirvec::Pt)::Tuple{Int64,Int64,Int64}
    dp = hullvec.x*dirvec.x+hullvec.y*dirvec.y
    cp = hullvec.x*dirvec.y-hullvec.y*dirvec.x
    q = (cp == 0 && dp > 0) ? 0 : dp > 0 ? 1 : dp == 0 ? 2 : (cp == 0 && dp < 0) ? 4 : 3
    return (dp,cp,q)
end

function evalinc(chull::Vector{Pt},n::Int64,i1::Int64,i2::Int64,i3::Int64,i4::Int64,dir::Pt)::Int64
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


function solve(N::Int64,M::Int64,X::Vector{Int64},Y::Vector{Int64})
    if M == 1; return maximum(abs((1+1im)*(X[i]+1im*Y[i])) for i in 1:N); end
    ans = maximum(2*abs(X[1]+1im*Y[1]) for i in 1:N)
    if N == 1 ; return ans; end
    if checkColinear(N,X,Y); return doColinear(ans,N,M,X,Y); end
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
        ans = evalquad(ans,M,chull[i1],chull[i2],chull[i3],chull[i4])
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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        M = gi()
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        ans = solve(N,M,X,Y)
        print("$ans\n")
    end
end

main()
