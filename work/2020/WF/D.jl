using Random
const II = Int64
const FF = Float64
const SS = String
const VI = Vector{Int64}
const VF = Vector{Float64}
const PairI = NTuple{2,Int64}
const TripI = NTuple{3,Int64}
const QuadI = NTuple{4,Int64}
infile = stdin
gs()::SS = rstrip(readline(infile))
gi()::II = parse(Int64, gs())
gf()::FF = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::VI = [parse(Int64,x) for x in gss()]
gfs()::VF = [parse(Float64,x) for x in gss()]

######################################## END BOILERPLATE CODE ########################################

function solveSmallBruteForce(N::II,R::II,K::II,D::VI,L::VI)
    d::VF = []
    angfact::FF = 0.5 * 0.000000001 * π / 180.00
    for i in 1:N-1
        for j in i+1:N
            ang::II = D[j]-D[i]
            if ang > 180_000_000_000; ang = 360_000_000_000 - ang; end
            push!(d,L[i]+L[j]+2R*sin(angfact*ang))
        end
    end
    sort!(d,rev=true)
    return d[1:K]
end

function solveSmall(N::II,R::II,K::II,D::VI,L::VI)
    perPointBest::VF = fill(-9e99,N)
    st::Vector{PairI} = []
    ptr::II = 1
    angfact::FF = 0.5 * 0.000000001 * π / 180.00
    for i in 1:N
        ## Add new potential spots
        while true
            if D[ptr] > D[i] && D[ptr] - D[i] > 180_000_000_000; break; end
            if D[ptr] < D[i] && 360_000_000_000 + D[ptr] - D[i] > 180_000_000_000; break; end
            while !isempty(st) && st[end][2] <= L[ptr]; pop!(st); end
            push!(st,(D[ptr],L[ptr]))
            ptr = ptr == N ? 1 : ptr+1
            if ptr == i; break; end
        end
        ## Remove old potential spots
        while !isempty(st)
            if D[i] < st[1][1] && st[1][1] - D[i] <= 180_000_000_000; break; end
            if st[1][1] < D[i] && 360_000_000_000 + st[1][1] - D[i] <= 180_000_000_000; break; end
            popfirst!(st)
        end
        ## Try all the values in the stack to see which is the best -- with random numbers, should be O(log(n)) entries
        for (d::II,l::II) in st
            ang::FF = d > D[i] ? d-D[i] : 360_000_000_000+d-D[i]
            cand = l + 2R*sin(ang*angfact)
            if cand > perPointBest[i]; perPointBest[i] = cand; end
        end
        perPointBest[i] += L[i]
    end
    best = maximum(perPointBest)
    return [best]
end

function solveIntersection(r1::FF,r2::FF,adder1::II,adder2::II,x1::FF,x2::FF,R::II,angfact::FF)
    (xl::FF,xr::FF) = (x1,x2)
    y1l::FF = adder1 + 2R*sin(angfact*(r1-xl))
    y2l::FF = adder2 + 2R*sin(angfact*(r2-xl))
    y1r::FF = adder1 + 2R*sin(angfact*(r1-xr))
    y2r::FF = adder2 + 2R*sin(angfact*(r2-xr))
    if sign(y2l-y1l) == sign(y2r-y1r); print("ERROR: SOMETHING BAD HAPPENED\n"); end
    (xm::FF,y1m::FF,y2m::FF) = (0.0,0.0,0.0)
    for i in 1:50
        xm = xl + 0.5*(xr-xl)
        y1m = adder1 + 2R*sin(angfact*(r1-xm))
        y2m = adder2 + 2R*sin(angfact*(r2-xm))
        if (y1m-y2m) <= 1e-10; return (xm,y1m+0.5*(y2m-y1m)); end
        if sign(y1m-y2m) == sign(y1l-y2l); (x1,y1l,y2l) = (xm,y1m,y2m); else (x2,y1r,y2r) = (xm,y1m,y2m); end
    end
    return (xm,y1m + 0.5*(y2m-y1m))
end

function solveLarge(N::II,R::II,K::II,D::VI,L::VI)
    ## We figure out a list of intervals which contain the best point to use in that interval
    ## We process this from 0 degrees to 720 degrees
    best::Vector{Tuple{II,II,II,II,II}} = []
    angfact::FF = 0.5 * 0.000000001 * π / 180.00
    DD::VI = vcat(D,[x+360_000_000_000 for x in D])
    LL::VI = vcat(L,L)
    for i in 1:2N
        l::FF,r::FF = max(0.000,1.0*(DD[i]-180_000_000_000)),1.0*DD[i]
        vl::FF = l == 1.0 * (DD[i]-180_000_000_000) ? 1.0*(LL[i] + 2R) : LL[1] + 2R * sin(angfact*(DD[i]))
        if l == r; continue; end
        while true
            if isempty(best); push!(best,(l,r,vl,0.000,i)); break; end
            (a::FF,b::FF,va::FF,vb::FF,p::II) = best[end]
            ## 3 possible orders: [a,b,l,r], [l,a,b,r], or [a,l,b,r]
            newpa = LL[i]+2R*sin(angfact*(r-a))
            oldvl = LL[p]+2R*sin(angfact*(DD[p]-l))
            if l >= b  ## [a,b,l,r] case
                push!(best,(l,r,vl,0.000,i)); break
            elseif a >= l && newpa >= pa ## [l,a,b,r] case
                pop!(best) 
            elseif a < l && oldvl <= vl ## [a,l,b,r] case
                best[end] = (a,l,va,oldvl,p); push!(best,(l,r,vl,0.0,i)); break
            else
                (x,y) = solveIntersection(1.0*DD[p],1.0*DD[i],LL[p],LL[i],a >= l ? a : l,b,R,angfact)
                best[end] = (a,x,va,y,p)
                push!(best,(x,r,y,0.0,i))
                break
            end
        end
    end
    ptr = 1
    chords::Vector{Tuple{FF,II}} = []
    for i in 1:N
        while best[ptr][2] <= 1.0*D[i]; ptr += 1; end
        if best[ptr][1] <= 1.0*D[i]
            (a::FF,b::FF,va::FF,vb::FF,p::II) = best[ptr]
            myc::FF = L[i] + LL[p] + 2R * sin(angfact * (DD[p]-D[i]))
            push!(chords,(myc,i))
        end
    end
    sort!(chords,rev=true)
    chosenPointSet::Set{Int64} = ()
    for i in 1:min(length(chords),2K-1)
        push!(chosenPointSet,chords[i][2])
    end
    nonChosenPoints::VI = []
    for i in 1:N; if i ∉ chosenPointSet; push!(nonChosenPoints,i); end; end
    chosenPoints::VI = [x for x in chosenPointSet]
    values::VF = []
    for i in nonChosenPoints
        for j in chosenPoints
            ang = D[i]-D[j]
            if ang < 0; ang += 360_000_000_000; end
            if ang > 180_000_000_000; ang =  360_000_000_000 - ang; end
            push!(values,L[i]+L[j]+2R*sin(angfact*ang))
        end
    end
    for i in chosenPoints
        for j in chosenPoints
            if j <= i; continue; end
            ang = D[i]-D[j]
            if ang < 0; ang += 360_000_000_000; end
            if ang > 180_000_000_000; ang =  360_000_000_000 - ang; end
            push!(values,L[i]+L[j]+2R*sin(angfact*ang))
        end
    end
    sort!(values,rev=true)
    return values[1:K]
end

function isApproximatelyEqual(x::FF,y::FF,epsilon::FF)::Bool
    if -epsilon <= x - y <= epsilon; return true; end
    if -epsilon <= x <= epsilon || -epsilon <= y <= epsilon; return false; end
    if -epsilon <= (x - y) / x <= epsilon; return true; end
    if -epsilon <= (x - y) / y <= epsilon; return true; end
    return false
end

function gencase(Nmin::II,Nmax::II,Kmin::II,Kmax::II)
    N::II = rand(Nmin:Nmax)
    K::II = rand(Kmin:Kmax)
    spts = Set{Int64}()
    while length(spts) < N; push!(spts,rand(0:359_999_999_999)); end
    D::VI = [x for x in spts]; sort!(D)
    R::II = rand(1:1000000000)
    L::VI = rand(1:1000000000,N)
    return (N,R,K,D,L)
end

function test1(ntc::II,Nmin::II,Nmax::II,Kmin::II,Kmax::II,check::Bool = true)
    pass = 0
    for ttt in 1:ntc
        (N::II,R::II,K::II,D::VI,L::VI) = gencase(Nmin,Nmax,Kmin,Kmax)
        ans2 = solveSmall(N,R,K,D,L)
        if check
            ans1 = solveSmallBruteForce(N,R,K,D,L)
            good = true
            for i in 1:K; if !isApproximatelyEqual(ans1[i],ans2[i],1e-10); good = false; break; end; end
            if good
                pass += 1
            else
                print("ERROR ttt:$ttt N:$N ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmallBruteForce(N,R,K,D,L)
                ans2 = solveSmall(N,R,K,D,L)
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
    tt = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,K = gis()
        D::VI = fill(0,N)
        L::VI = fill(0,N)
        for i in 1:N; D[i],L[i] = gis(); end
        ans = solveSmall(N,R,K,D,L)
        #ans = solveSmallBruteForce(N,R,K,D,L)
        #ans = solveLarge()
        ansstr = join(ans," ")
        print("$ansstr\n")
    end
end

Random.seed!(8675309)
test1(10000,5,10,1,1)
test1(1000,5,1000,1,1)
test1(20,149999,150000,1,1,false)
#main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

