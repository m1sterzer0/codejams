
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

mutable struct UnsafeIntPerm; n::I; r::I; indices::VI; cycles::VI; end
Base.eltype(iter::UnsafeIntPerm) = Vector{Int64}
function Base.length(iter::UnsafeIntPerm)
    ans::I = 1; for i in iter.n:-1:iter.n-iter.r+1; ans *= i; end
    return ans
end
function unsafeIntPerm(a::VI,r::I=-1) 
    n = length(a)
    if r < 0; r = n; end
    return UnsafeIntPerm(n,r,copy(a),collect(n:-1:n-r+1))
end
function Base.iterate(p::UnsafeIntPerm, s::I=0)
    n = p.n; r=p.r; indices = p.indices; cycles = p.cycles
    if s == 0; return(n==r ? indices : indices[1:r],s+1); end
    for i in (r==n ? n-1 : r):-1:1
        cycles[i] -= 1
        if cycles[i] == 0
            k = indices[i]; for j in i:n-1; indices[j] = indices[j+1]; end; indices[n] = k
            cycles[i] = n-i+1
        else
            j = cycles[i]
            indices[i],indices[n-j+1] = indices[n-j+1],indices[i]
            return(n==r ? indices : indices[1:r],s+1)
        end
    end
    return nothing
end

function solveSmall(Z::I,X::VI,Y::VI,M::VI)::I
    ans::I = 0
    zidx::VI = collect(1:Z)
    for zarr in unsafeIntPerm(zidx)
        lans::I = 0
        x::I,y::I,tt::I = 0,0,0
        for zi in 1:Z
            m2,x2,y2 = M[zarr[zi]],X[zarr[zi]],Y[zarr[zi]]
            tt += max((zi == 1 ? 0 : 750),100*abs(x2-x),100*abs(y2-y))
            if tt > m2+1000; break; end
            tt = max(m2,tt)
            lans += 1
            x,y = x2,y2
        end
        ans = max(ans,lans)
    end
    return ans
end

function solveLarge(Z::I,X::VI,Y::VI,M::VI)::I
    zombies::Vector{TI} = sort([(M[i],X[i],Y[i]) for i in 1:Z])
    lasttime::VI = fill(-1,Z)
    oldlasttime::VI = fill(-1,Z)
    for loop in 1:Z
        found = false
        oldlasttime[:] = lasttime
        fill!(lasttime,-1)
        for st in 1:(loop==1 ? 1 : Z)
            (m1,x1,y1) = loop == 1 ? (0,0,0) : zombies[st]
            tstart = loop == 1 ? 0 : oldlasttime[st]
            if tstart < 0 ; continue; end
            for en in 1:Z
                if st == en && loop > 1; continue; end
                (m2,x2,y2) = zombies[en]
                tt = tstart + max( (loop==1 ? 0 : 750), 100*abs(x2-x1), 100*abs(y2-y1) )
                if tt > m2+1000; continue; end
                found = true
                tt = max(m2,tt)
                lasttime[en] = lasttime[en] < 0 ? tt : min(tt,lasttime[en])
            end
        end
        if !found; return loop-1; end
    end
    return Z
end

function gencase(Cmax::I,Mmax::I,Zmin::I,Zmax::I)
    Z = rand(Zmin:Zmax)
    X::VI = fill(0,Z)
    Y::VI = fill(0,Z)
    M::VI = fill(0,Z)
    
    while (true)
        rand!(X,-Cmax:Cmax)
        rand!(Y,-Cmax:Cmax)
        rand!(M,0:Mmax)
        good::Bool = true
        ## Now check for illegal overlaps
        for i in 1:Z
            for j in i+1:Z
                if X[i] != X[j]; continue; end
                if Y[i] != Y[j]; continue; end
                if abs(M[i]-M[j]) > 1000; continue; end
                good = false
            end
        end
        if good; break; end
    end
    return (Z,X,Y,M)
end

function test(ntc::I,Cmax::I,Mmax::I,Zmin::I,Zmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (Z,X,Y,M) = gencase(Cmax,Mmax,Zmin,Zmax)
        ans2 = solveLarge(Z,X,Y,M)
        if check
            ans1 = solveSmall(Z,X,Y,M)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(Z,X,Y,M)
                ans2 = solveLarge(Z,X,Y,M)
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
        Z::I = gi()
        X::VI = fill(0,Z)
        Y::VI = fill(0,Z)
        M::VI = fill(0,Z)
        for i in 1:Z; X[i],Y[i],M[i] = gis(); end
        ans = solveSmall(Z,X,Y,M)
        #ans = solveLarge(Z,X,Y,M)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,5,100,1,8,true)
#test(1000,10,1000,1,8,true)
#test(1000,100,10000,1,8,true)
#test(1000,1000,100000,1,8,true)
#test(1000,1000,100000000,1,8,true)
#test(1000,1000,100000,90,100,false)
