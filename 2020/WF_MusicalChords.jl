
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

function solveBruteForce(N::I,R::I,K::I,D::VI,L::VI)::VF
    vals::VF = []
    angfact::F = 0.5 * 0.000000001 * π / 180.00
    for i in 1:N-1
        for j in i+1:N
            ang::I = D[j] - D[i]
            if ang > 180_000_000_000; ang = 360_000_000_000 - ang; end
            push!(vals,L[i] + L[j] + 2R*sin(angfact*ang))
        end
    end
    sort!(vals,rev=true)
    return vals[1:K]
end

function solveSmall(N::I,R::I,K::I,D::VI,L::VI)::VF
    inf::I = 10^12
    angfact::F = 0.5 * 0.000000001 * π / 180.00
    ans::F = 0.0
    ## Fold this twice to make this a linear problem instead of circular
    LL::VI = vcat(L,L)
    DD::VI = vcat(D,[360_000_000_000+x for x in D])

    ## Find the next greater L value to the left
    grl::VI = fill(0,2N)
    st::VPI = [(inf,0)]
    for i in 1:2N
        while LL[i] >= st[end][1]; pop!(st); end
        grl[i] = st[end][2]
        push!(st,(LL[i],i))
    end

    ## Now loop through, find the furthest point, and walk backwards with peak jumping
    ptr::I = 1
    for i in 1:N
        cutoff::I = DD[i] + 180_000_000_000
        while ptr < 2N && DD[ptr+1] <= cutoff; ptr += 1; end
        lptr::I = ptr; lbest::F = 0.00
        while lptr > i
            lbest = max(lbest, LL[lptr] + 2R*sin(angfact*(DD[lptr]-DD[i])))
            lptr = grl[lptr]
        end
        ans = max(ans,lbest+LL[i])
    end
    return [ans]
end        

function findsplit(l::F,r::F,llr::I,ddr::F,lll::I,ddl::F,R::I,angfact::F)::F
    for xx in 1:100
        m::F = 0.5*(l+r)
        if m <= l; return l; elseif m >= r; return r; end
        if lll + 2R*sin(angfact*(m-ddl)) >= llr + 2R*sin(angfact*(m-ddr)); l = m; else; r = m; end
    end
    return 0.5*(l+r)
end

function dopush(farr::VF,K::I,v::F)
    if length(farr) < K; push!(farr,v); sort!(farr,rev=true); return; end
    if v <= farr[end]; return; end
    pop!(farr); push!(farr,v); sort!(farr,rev=true);
end

function solveLarge(N::I,R::I,K::I,D::VI,L::VI)
    inf::I = 10^12
    angfact::F = 0.5 * 0.000000001 * π / 180.00
    ## Fold this twice to make this a linear problem instead of circular
    LL::VI = vcat(L,L)
    DD::VI = vcat(D,[360_000_000_000+x for x in D])
    st::Vector{Tuple{F,F,I}} = []
    for i in 1:2N
        while !isempty(st)
            (a::F,b::F,j::I) = st[end]
            if DD[i] >= b; break; end
            if LL[j] + 2R*sin(angfact*(b-DD[j])) >= LL[i] + 2R*sin(angfact*(b-DD[i])); break; end
            ## We know we are chopping off something -- now to figure out what
            if a >= DD[i]
                if LL[j] + 2R*sin(angfact*(a-DD[j])) <= LL[i] + 2R*sin(angfact*(a-DD[i]))
                    ## Pop off the whole segment
                    pop!(st); continue
                else
                    ## Split between a & b
                    c = findsplit(a,b,LL[i],Float64(DD[i]),LL[j],Float64(DD[j]),R,angfact)
                    pop!(st); push!(st,(a,c,j)); break
                end
            else
                if LL[j] + 2R*sin(angfact*(DD[i]-DD[j])) <= LL[i]
                    ## Split at DD[i]
                    pop!(st); push!(st,(a,DD[i],j)); break
                else
                    ## Split between DD[i] && b
                    c = findsplit(Float64(DD[i]),b,LL[i],Float64(DD[i]),LL[j],Float64(DD[j]),R,angfact)
                    pop!(st); push!(st,(a,c,j)); break
                end
            end
        end
        if isempty(st) || DD[i] > st[end][2]
            push!(st,(1.0*DD[i],1.0*(DD[i]+180_000_000_000),i))
        else
            push!(st,(st[end][2],1.0*(DD[i]+180_000_000_000),i))
        end
    end

    ## Now calculate the best per point in linear time
    ptr = 1
    bestPerPt::Vector{Tuple{F,I,I}} = []
    for i in (N+1):2N
        while st[ptr][2] < DD[i]; ptr += 1; end
        if st[ptr][1] <= DD[i]
            j = st[ptr][3]
            (ii,jj) = (i-N, j > N ? j-N : j)
            if jj < ii; (ii,jj) = (jj,ii); end
            push!(bestPerPt, (LL[i]+LL[j]+2R*sin(angfact*(DD[i]-DD[j])),ii,jj))
        end
    end

    unique!(sort!(bestPerPt))
    ## Pick the points from the best K edges in bestPerPt.
    ## This defines up to 2K points.  Each one of the top K edges should have at least one
    ## endpoint in that set.  Then we just throw everything away and brute force the edges
    ## within this set and the edges between points in this set and points outside this set.
    ptset::SI = SI()
    while !isempty(bestPerPt) && length(ptset) < 2K
        (x::F,i,j) = pop!(bestPerPt); push!(ptset,i); push!(ptset,j)
    end
    lptset::VI = sort([x for x in ptset])
    
    ## This is lazy -- we can do better if we need to -- no need for this much storage
    arcvals::VF = []
    for idxi in 1:length(lptset)
        for idxj in idxi+1:length(lptset)
            i,j = lptset[idxi],lptset[idxj]
            ang = DD[j]-DD[i]; if ang > 180_000_000_000; ang = 360_000_000_000-ang; end
            dopush(arcvals,K,LL[i]+LL[j]+2R*sin(angfact*ang))
        end
    end
    for ii in 1:N
        if ii in ptset; continue; end
        for jj in lptset
            (i,j) = ii < jj ? (ii,jj) : (jj,ii)
            ang = DD[j]-DD[i]; if ang > 180_000_000_000; ang = 360_000_000_000-ang; end
            dopush(arcvals,K,LL[i]+LL[j]+2R*sin(angfact*ang))
        end
    end
    return arcvals[1:K]
end

function gencase(Nmin::I,Nmax::I,Rmin::I,Rmax::I,Kmin::I,Kmax::I,Lmin::I,Lmax::I)
    N = rand(Nmin:Nmax)
    R = rand(Rmin:Rmax)
    K = rand(Kmin:Kmax)
    D = rand(0:359_999_999_999,N); sort!(D)
    L = rand(Lmin:Lmax,N)
    return (N,R,K,D,L)
end

function gencase2(Nmin::I,Nmax::I,Rmin::I,Rmax::I,Kmin::I,Kmax::I,Lmin::I,Lmax::I)
    N = rand(Nmin:Nmax)
    R = rand(Rmin:Rmax)
    K = rand(Kmin:Kmax)
    ## Interesting cases
    ## Ds: (equidistant,no) x (full circle,half circle,quarter circle)
    ## Ls: (all same, monotonic increasing, montonic decreasing, random)
    circamt = rand(1:3)
    if circamt == 3; Dmin = rand(0:270_000_000_000); Dmax = Dmin + 89_999_999_999; end
    if circamt == 2; Dmin = rand(0:180_000_000_000); Dmax = Dmin + 179_999_999_999; end
    if circamt == 1; Dmin = 0; Dmax = Dmin + 359_999_99_999; end

    equidistant = rand([true,false,false,false])
    if equidistant;  inc = (Dmax-Dmin)÷(N-1); D = [Dmin + inc*i for i in 0:(N-1)]; end
    if !equidistant; D = rand(Dmin:Dmax,N); sort!(D); end

    lcond = rand(1:4)
    if lcond == 1; lval = rand(Lmin:Lmax); L = fill(lval,N); end
    if lcond == 2; L = rand(Lmin:Lmax,N); sort!(L); end
    if lcond == 3; L = rand(Lmin:Lmax,N); sort!(L,rev=true); end
    if lcond == 4; L = rand(Lmin:Lmax,N); end
    return (N,R,K,D,L)
end

function isApproximatelyEqual(x::F,y::F,epsilon::F)::Bool
    if -epsilon <= x - y <= epsilon; return true; end
    if -epsilon <= x <= epsilon || -epsilon <= y <= epsilon; return false; end
    if -epsilon <= (x - y) / x <= epsilon; return true; end
    if -epsilon <= (x - y) / y <= epsilon; return true; end
    return false
end

function test(ntc::I,Nmin::I,Nmax::I,Rmin::I,Rmax::I,Kmin::I,Kmax::I,Lmin::I,Lmax::I,mode::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,R,K,D,L) = mode == 3 ? gencase2(Nmin,Nmax,Rmin,Rmax,Kmin,Kmax,Lmin,Lmax) : gencase(Nmin,Nmax,Rmin,Rmax,Kmin,Kmax,Lmin,Lmax)
        ans2 = mode == 1 ? solveSmall(N,R,K,D,L) : solveLarge(N,R,K,D,L)
        if check
            ans1 = solveBruteForce(N,R,K,D,L)
            good = true
            for i in 1:K; if !isApproximatelyEqual(ans1[i],ans2[i],10.0^(-10)); good = false; end; end
            if good
                pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                print("$N $R $K\n")
                for i in 1:N; print("$(D[i]) $(L[i])\n"); end
                ans1 = solveBruteForce(N,R,K,D,L)
                ans2 = mode == 1 ? solveSmall(N,R,K,D,L) : solveLarge(N,R,K,D,L)
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
        N,R,K = gis()
        D::VI = fill(0,N)
        L::VI = fill(0,N)
        for i in 1:N; D[i],L[i] = gis(); end
        #ans = solveBruteForce(N,R,K,D,L)
        #ans = solveSmall(N,R,K,D,L)
        ans = solveLarge(N,R,K,D,L)
        println(join(ans," "))
    end
end

Random.seed!(8675309)
main()
#test(1000,5,10,1,100,1,1,1,100,1)
#test(1000,500,1000,1,1000000000,1,1,1,1000000000,1)
#test(20,149999,150000,1,1000000000,1,1,1,1000000000,1,false)

#test(1000,5,10,1,100,1,10,1,100,2)
#test(1000,500,1000,1,1000000000,1,10,1,1000000000,2)
#test(100,149999,150000,1,1000000000,1,10,1,1000000000,2,false)

#test(1000,5,10,1,100,1,10,1,100,3)
#test(1000,500,1000,1,1000000000,1,10,1,1000000000,3)
#test(100,149999,150000,1,1000000000,1,10,1,1000000000,3,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,149999,150000,1,1000000000,1,10,1,1000000000,3,false)
#Profile.clear()
#@profilehtml test(100,149999,150000,1,1000000000,9,10,1,1000000000,3,false)

