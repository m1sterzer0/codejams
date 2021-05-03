
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

function findnext(N::I,X::VI,Y::VI,i2::I,i3::I,ix::I)
    best::I = -1
    bestdist::I = 4_000_000_000_000_000_001
    dx::I = X[i3]-X[i2]
    dy::I = Y[i3]-Y[i2]
    for i::I in 1:N
        if i == ix; continue; end
        dx2::I = X[i]-X[ix]
        dy2::I = Y[i]-Y[ix]
        dp::I = dx*dx2+dy*dy2
        cp::I = dx*dy2-dy*dx2
        dist::I = dx2*dx2+dy2*dy2
        if dp > 0 && cp == 0 && dist < bestdist; best = i; bestdist = dist; end
    end
    return best
end

function solveSmall(N::I,X::VI,Y::VI)::I
    if N <= 4; return N; end  ## Putt into hole 1 along vector from hole 2 --> hole 3.  Link 1->2 and 3->4.
    best::I = 4
    wh::VI = [-1 for i in 1:N]
    used::VB = [false for i in 1:N]
    visited::VB = [false for i in 1:N]
    for p in unsafeIntPerm(collect(1:N))
        fill!(used,false)
        fill!(visited,false)
        fill!(wh,-1)
        wh[p[1]] = p[2]; wh[p[2]] = p[1]
        wh[p[4]] = p[3]; wh[p[3]] = p[4]
        if N >= 6; wh[p[6]] = p[5]; wh[p[5]] = p[6]; end
        if N >= 8; wh[p[8]] = p[7]; wh[p[7]] = p[8]; end
        if N >= 10; wh[p[10]] = p[9]; wh[p[9]] = p[10]; end
        for i::I in (1,3); used[p[i]] = true; end
        for i::I in (1,2,3,4); visited[p[i]] = true; end
        x::I = p[4]
        while(true)
            visited[x] = true
            x2::I = findnext(N,X,Y,p[2],p[3],x) ## Went into the next hole in the chain
            if x2 < 0; break; end
            visited[x2] = true
            if wh[x2] < 0 || used[x2]; break; end
            used[x2] = true
            x = wh[x2]
        end
        ans::I = count(x->x,visited)
        best = max(ans,best)
    end
    return best
end

function solveLarge(N::I,X::VI,Y::VI)::I
    best::I = 0
    d::Dict{I,I} = Dict{I,I}()
    if N <= 4; return N; end
    for i::I in 1:N
        for j::I in 1:N
            if i == j; continue; end
            empty!(d)
            dy::I = Y[j]-Y[i]
            dx::I = X[j]-X[i]
            for k::I in 1:N
                b::I = Y[k]*dx-X[k]*dy
                if haskey(d,b); d[b] += 1; else; d[b] = 1; end
            end
            ## Count singletons, doubles, and triples
            sing::I,doub::I,trip::I = 0,0,0
            for (k::I,v::I) in d;
                if v >= 3 && v % 2 != 0; trip += 1; doub += (v-3) ÷ 2
                elseif v % 2 == 0; doub += v ÷ 2
                elseif v == 1; sing += 1
                end
            end
            ## Pick the starting one
            if sing > 0; sing -= 1; elseif trip > 0; trip -= 1; doub += 1; else doub -= 1; sing += 1; end
            ans::I = 1 + 2 * doub + 3 * trip + (trip % 2 == 0 && sing > 0 ? 1 : 0)
            best = max(ans,best)
        end
    end
    return best
end

function gencase(Nmax::I,Cmax::I)
    N = rand(1:Nmax)
    pts = SPI()
    while length(pts) < N; push!(pts,(rand(-Cmax:Cmax),rand(-Cmax:Cmax))); end
    lpts = shuffle([(x,y) for (x,y) in pts])
    X = [x for (x,y) in lpts]
    Y = [y for (x,y) in lpts]
    return (N,X,Y)
end

function test(ntc::I,Nmax::I,Cmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,X,Y) = gencase(Nmax,Cmax)
        ans2 = solveLarge(N,X,Y)
        if check
            ans1 = solveSmall(N,X,Y)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,X,Y)
                ans2 = solveLarge(N,X,Y)
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
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,X,Y)
        ans = solveLarge(N,X,Y)
        println(ans)
    end
end

Random.seed!(8675309)
main()
#test(1000,7,5)
#test(100,9,10)
#test(1000,7,1000)
#test(1000,7,1_000_000_000)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

