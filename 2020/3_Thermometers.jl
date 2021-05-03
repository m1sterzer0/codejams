
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

function solveSmall(K::Int64,N::Int64,X::Vector{Int64},T::Vector{Int64})
    npts = 2K
    best = npts
    base::VI = fill(0,2K)
    keepout::VB = fill(false,2K)
    working::VI = fill(0,2K)
    for i in 1:N; j = 2*X[i]+1; keepout[j] = true; end
    for i in 0:2*X[1]-1; base[i+1] = T[N]; end
    for i in 2*X[N]:2K-1; base[i+1] = T[N]; end
    for j in 1:N-1
        for i in 2*X[j]:2*X[j+1]-1; base[i+1]=T[j]; end
    end
    for mask in 0:2^(2K)-1
        empty!(working)
        for i in 0:npts-1; if mask & (1<<i) != 0; push!(working,i+1); end; end
        if length(working) < N || length(working) >= best; continue; end
        good = true
        for w in working; if keepout[w]; good = false; break; end; end
        if !good; continue; end

        for j in 1:length(working)-1
            l,r = working[j],working[j+1]
            lt,rt = base[l],base[r]
            if lt != rt && (r-l) % 2 != 0; good = false; break; end
            m = (l+r) >> 1
            (lm,rm) = (r-l)%2==0 ? (m-1,m) : (m,m+1)
            for i in l:lm; if base[i] != lt; good = false; break; end; end
            for i in rm:r; if base[i] != rt; good = false; break; end; end
            if !good; break; end
        end
        if !good; continue; end
        l,r = working[end],2K+working[1]
        lt,rt = base[l],base[r-2K]
        if lt != rt && (r-l) % 2 != 0; continue; end
        m = (l+r) >> 1
        (lm,rm) = (r-l)%2==0 ? (m-1,m) : (m,m+1)
        for i in l:lm; if (i>2K ? base[i-2K] : base[i]) != lt; good = false; break; end; end
        for i in rm:r; if (i>2K ? base[i-2K] : base[i]) != rt; good = false; break; end; end
        if !good; continue; end
        #print("DBG: best:$best newbest:$(length(working)) working:$working base:$base\n")
        best = length(working)
    end
    return best
end

# Key observations
## We know that
## a) Every segement is covered by 1 or 2 lighthouses
## b) We never have a 2 lighthouse segment adjacent to a 2 segment lighthouse,
##    as we can move the lighthouses away from the common point until one (or both)
##    of them hit the other segment.
## c) common points must be equidistant to the nearest lighthouses in each segment
##

function nointersect(l,r,w,nl,nr)::Bool
    (l,r) = (max(w-r,nl),min(w-l,nr))
    return l >= r
end

function dofullloop(N::I,segleft::VI,segright::VI,segwidths::VI,singleOK::VB)::Bool
    if false in singleOK; return false; end
    if dotraverse(1,1,true,N,segleft,segright,segwidths,singleOK) > N; return false; end
    if N % 2 == 0
        return sum(segwidths[1:2:end]) == sum(segwidths[2:2:end])
    else
        twoz = sum(segwidths[1:2:end]) - sum(segwidths[2:2:end])
        for i in 1:N
            if twoz <= 2*segleft[i] || twoz >= 2*segright[i]; return false; end
            twoz = 2*segwidths[i]-twoz
        end
        return true
    end
end

function dotraverse(st::I,en::I,checkfull::Bool,N::I,segleft::VI,segright::VI,segwidths::VI,singleOK::VB)::I
    i = (st==N ? 1 : st+1); ans = 1; (l,r,w) = (segleft[st],segright[st],segwidths[st])
    while(true)
        if !singleOK[i] || nointersect(l,r,w,segleft[i],segright[i])
            if checkfull; return 2N; end
            ans += 2
            if i == en; break; end
            i = (i==N ? 1 : i+1)
            (l,r,w) = (segleft[i],segright[i],segwidths[i])
            ans += 1
            if i == en; break; end
            i = (i==N ? 1 : i+1)
        else
            ans += 1
            (l,r,w) = (max(w-r,segleft[i]),min(w-l,segright[i]),segwidths[i])
            if i == en; break; end
            i = (i==N ? 1 : i+1)
        end
    end
    return checkfull ? N : ans
end

function solveLarge(K::I,N::I,X::VI,T::VI)
    segwidths::VI = fill(0,N)
    segleft::VI = fill(0,N)
    segright::VI = fill(0,N)
    singleOK::VB = fill(true,N)

    for i in 1:N-1; segwidths[i] = X[i+1]-X[i]; end
    segwidths[N] = K-X[N]+X[1]
    for i in 1:N
        sl,sc,sr = (i==1 ? segwidths[N] : segwidths[i-1]),segwidths[i],(i==N ? segwidths[1] : segwidths[i+1])
        cmax = min(sl,sc)
        cmin = sc - min(sr,sc)
        if cmax > cmin; segleft[i] = cmin; segright[i] = cmax
        else; singleOK[i] = false
        end
    end

    if dofullloop(N,segleft,segright,segwidths,singleOK); return N; end
    best = 2N
    if N == 2; return min(best,3); end
    for i in 1:N
        if !singleOK[i]; continue; end
        en = i-2; if en < 1; en += N; end
        best = min(best,2+dotraverse(i,en,false,N,segleft,segright,segwidths,singleOK))
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        K,N = gis()
        X::VI = gis()
        T::VI = gis()
        #ans = solveSmall(K,N,X,T)
        ans = solveLarge(K,N,X,T)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

