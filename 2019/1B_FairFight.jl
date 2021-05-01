
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

struct STRMQ; t::Array{I,2}; logt::VI; end
function genSparseTable(a::VI)::STRMQ
    n::I = length(a); k::I = 1; kl::I = 1
    while kl < length(a); k += 1; kl *= 2; end
    t::Array{I,2} = fill(0,n,k)
    for i in 1:n; t[i,1] = a[i]; end
    for j in 2:k
        sz::I = 1 << (j-2)
        for i in 1:n
            i2 = min(i+sz,n)
            t[i,j] = max(t[i,j-1],t[i2,j-1])
        end
    end
    logt::VI = fill(0,n)
    logt[1] = 1
    for i in 2:n; logt[i] = logt[i>>1] + 1; end
    return STRMQ(t,logt)
end

function rmaxq(t::STRMQ,l::I,r::I)
    idx::I = t.logt[r-l+1]
    return max(t.t[l,idx],t.t[r+1-(1<<(idx-1)),idx])
end

## O(n^3)
function solveSmall(N::I,K::I,C::VI,D::VI)::I
    ans::I = 0
    for i::I in 1:N; for j::I in i:N
        cmax::I = -1; for k::I in i:j; if C[k] > cmax; cmax = C[k]; end; end
        dmax::I = -1; for k::I in i:j; if D[k] > dmax; dmax = D[k]; end; end
        if abs(cmax-dmax) <= K; ans += 1; end
    end; end
    return ans
end

## O(n^2)
function process(C::VI,N::I)::Tuple{VI,VI}
    myinf::I = 10^18
    Cbigleft::VI = fill(0,N)
    Cbigright::VI = fill(0,N)
    stack::VPI = []; push!(stack,(myinf,0))
    for i in 1:N
        c = C[i]
        while c > stack[end][1]; pop!(stack); end
        Cbigleft[i] = stack[end][2]+1
        push!(stack,(c,i))
    end
    empty!(stack); push!(stack,(myinf,N+1))
    for i in N:-1:1
        c = C[i]
        while c >= stack[end][1]; pop!(stack); end
        Cbigright[i] = stack[end][2]-1
        push!(stack,(c,i))
    end
    return (Cbigleft,Cbigright)
end

function solveMid(N::I,K::I,C::VI,D::VI)
    ans::I = 0
    Cbigleft::VI,Cbigright::VI = process(C,N)
    Dbigleft::VI,Dbigright::VI = process(D,N)
    for (i::I,c::I) in enumerate(C)
        l::I,r::I = Cbigleft[i],Cbigright[i]
        for j::I in l:r
            d::I = D[j]
            if abs(c-d) > K; continue; end
            l2::I = Dbigleft[j]
            r2::I = Dbigright[j]
            if i < l2 || i > r2; continue; end
            l3 = max(l,l2); r3 = min(r,r2)
            if i <= j; ans += (i-l3+1)*(r3-j+1)
            else ;     ans += (j-l3+1)*(r3-i+1)
            end
        end
    end
    return ans
end

##O(nlog^2n)
function doLeftSearch(t::STRMQ,r::I,l::I,v::I)::I
    anchor::I = r
    if rmaxq(t,l,anchor) <= v; return l; end
    while r-l > 1
        m = (r+l) >> 1
        if rmaxq(t,m,anchor) <= v; r = m; else; l = m; end
    end
    return r
end

function doRightSearch(t::STRMQ,l::I,r::I,v::I)::I
    anchor::I = l
    if rmaxq(t,anchor,r) <= v; return r; end
    while r-l > 1
        m = (r+l) >> 1
        if rmaxq(t,anchor,m) <= v; l = m; else; r = m; end
    end
    return l
end

function solveLarge(N::I,K::I,C::VI,D::VI)
    ans::I = 0
    Cbigleft::VI,Cbigright::VI = process(C,N)
    t::STRMQ = genSparseTable(D)
    for (i::I,c::I) in enumerate(C)
        l::I,r::I = Cbigleft[i],Cbigright[i]
        if D[i] > c + K
            continue
        elseif D[i] >= c - K
            r2 = doRightSearch(t,i,r,c+K)
            l2 = doLeftSearch(t,i,l,c+K)
            ans += (r2-i+1)*(i-l2+1)
        else
            r1 = doRightSearch(t,i,r,c-K-1)
            r2 = doRightSearch(t,i,r,c+K)
            l1 = doLeftSearch(t,i,l,c-K-1)
            l2 = doLeftSearch(t,i,l,c+K)
            ans += (r2-r1)*(l1-l2) + (r2-r1)*(i-l1+1) + (l1-l2)*(r1-i+1)
        end
    end
    return ans
end

function gencase(Nmin::I,Nmax::I,Kmin::I,Kmax::I,Cmin::I,Cmax::I)
    N = rand(Nmin:Nmax)
    K = rand(Kmin:Kmax)
    C::VI = rand(Cmin:Cmax,N)
    D::VI = rand(Cmin:Cmax,N)
    return (N,K,C,D)
end

function test(ntc::I,Nmin::I,Nmax::I,Kmin::I,Kmax::I,Cmin::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,K,C,D) = gencase(Nmin,Nmax,Kmin,Kmax,Cmin,Cmax)
        ans2 = solveLarge(N,K,C,D)
        if check
            ans1 = solveSmall(N,K,C,D)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,K,C,D)
                ans2 = solveLarge(N,K,C,D)
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
        N,K = gis()
        C::VI = gis()
        D::VI = gis()
        #ans = solveSmall(N,K,C,D)
        #ans = solveMid(N,K,C,D)
        ans = solveLarge(N,K,C,D)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(100,1,100,1,30,1,100)
#test(1000,1,100,1,30,1,100)
#test(20,9900,10000,1,200,1,10000,false)
#test(20,9900,10000,9900,10000,1,10000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

