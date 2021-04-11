
###############################################################################
### BEGIN PERMUTATION Code
###    Leveraged from Combinatorics.jl
###############################################################################

struct Permutations{T}
    a::T
    t::Int
end
Base.eltype(::Type{Permutations{T}}) where {T} = Vector{eltype(T)}
Base.length(p::Permutations) = (0 <= p.t <= length(p.a)) ? factorial(length(p.a), length(p.a)-p.t) : 0
permutations(a) = Permutations(a, length(a))
function permutations(a, t::Integer)
    if t < 0; t = length(a) + 1; end
    Permutations(a, t)
end

function Base.iterate(p::Permutations, s = collect(1:length(p.a)))
    (!isempty(s) && max(s[1], p.t) > length(p.a) || (isempty(s) && p.t > 0)) && return
    nextpermutation(p.a, p.t ,s)
end


function nextpermutation(m, t, state)
    perm = [m[state[i]] for i in 1:t]
    n = length(state)
    if t <= 0
        return(perm, [n+1])
    end
    s = copy(state)
    if t < n
        j = t + 1
        while j <= n &&  s[t] >= s[j]; j+=1; end
    end
    if t < n && j <= n
        s[t], s[j] = s[j], s[t]
    else
        if t < n
            reverse!(s, t+1)
        end
        i = t - 1
        while i>=1 && s[i] >= s[i+1]; i -= 1; end
        if i > 0
            j = n
            while j>i && s[i] >= s[j]; j -= 1; end
            s[i], s[j] = s[j], s[i]
            reverse!(s, i+1)
        else
            s[1] = n+1
        end
    end
    return (perm, s)
end

###############################################################################
### END PERMUTATION Code
###    Leveraged from Combinatorics.jl
###############################################################################

using Random

function findnext(N::Int64,X::Vector{Int64},Y::Vector{Int64},i2::Int64,i3::Int64,ix::Int64)
    best = -1
    bestdist = 4_000_000_000_000_000_001
    dx = X[i3]-X[i2]
    dy = Y[i3]-Y[i2]
    for i in 1:N
        if i == ix; continue; end
        dx2 = X[i]-X[ix]
        dy2 = Y[i]-Y[ix]
        dp = dx*dx2+dy*dy2
        cp = dx*dy2-dy*dx2
        dist = dx2*dx2+dy2*dy2
        if dp > 0 && cp == 0 && dist < bestdist; best = i; bestdist = dist; end
    end
    return best
end

function solveSmall(N::Int64,X::Vector{Int64},Y::Vector{Int64})::Int64
    if N <= 4; return N; end  ## Putt into hole 1 along vector from hole 2 --> hole 3.  Link 1->2 and 3->4.
    best = 4
    wh = [-1 for i in 1:N]
    used = [false for i in 1:N]
    visited = [false for i in 1:N]
    for p in permutations(collect(1:N))
        fill!(used,false)
        fill!(visited,false)
        fill!(wh,-1)
        wh[p[1]] = p[2]; wh[p[2]] = p[1]
        wh[p[4]] = p[3]; wh[p[3]] = p[4]
        if N >= 6; wh[p[6]] = p[5]; wh[p[5]] = p[6]; end
        if N >= 8; wh[p[8]] = p[7]; wh[p[7]] = p[8]; end
        if N >= 10; wh[p[10]] = p[9]; wh[p[9]] = p[10]; end
        for i in (1,3); used[p[i]] = true; end
        for i in (1,2,3,4); visited[p[i]] = true; end
        x = p[4]
        while(true)
            visited[x] = true
            x2 = findnext(N,X,Y,p[2],p[3],x) ## Went into the next hole in the chain
            if x2 < 0; break; end
            visited[x2] = true
            if wh[x2] < 0 || used[x2]; break; end
            used[x2] = true
            x = wh[x2]
        end
        ans = count(x->x,visited)
        best = max(ans,best)
    end
    return best
end

function solveLarge(N::Int64,X::Vector{Int64},Y::Vector{Int64})::Int64
    best = 0
    d = Dict{Int64,Int64}()
    if N <= 4; return N; end
    for i in 1:N
        for j in 1:N
            if i == j; continue; end
            empty!(d)
            dy = Y[j]-Y[i]
            dx = X[j]-X[i]
            for k in 1:N
                b = Y[k]*dx-X[k]*dy
                if haskey(d,b); d[b] += 1; else; d[b] = 1; end
            end
            ## Count singletons, doubles, and triples
            sing,doub,trip = 0,0,0
            for (k,v) in d;
                if v >= 3 && v % 2 != 0; trip += 1; doub += (v-3) ÷ 2
                elseif v % 2 == 0; doub += v ÷ 2
                elseif v == 1; sing += 1
                end
            end
            ## Pick the starting one
            if sing > 0; sing -= 1; elseif trip > 0; trip -= 1; doub += 1; else doub -= 1; sing += 1; end
            ans = 1 + 2 * doub + 3 * trip + (trip % 2 == 0 && sing > 0 ? 1 : 0)
            best = max(ans,best)
        end
    end
    return best
end

function test(ntc,Nmax,Cmax)
    N = 6
    X::Vector{Int64} = [3, -1, 2, 5, 1, 2]
    Y::Vector{Int64} = [4, -4, 4, 4, 4, -3]
    solveLarge(N,X,Y)
    pass = 0
    for ttt in 1:ntc
        N = rand(1:Nmax)
        pts = Set{Tuple{Int64,Int64}}()
        while length(pts) < N
            x = rand(-Cmax:Cmax)
            y = rand(-Cmax:Cmax)
            push!(pts,(x,y))
        end
        lpts = [(x,y) for (x,y) in pts]
        shuffle!(lpts)
        X = [x for (x,y) in lpts]
        Y = [y for (x,y) in lpts]
        ans1 = solveSmall(N,X,Y)
        ans2 = solveLarge(N,X,Y)
        if ans1 == ans2
            pass += 1
        else
            print("ERROR: ttt:$ttt N:$N X:$X Y:$Y ans1:$ans1 ans2:$ans2\n")
            ans1 = solveSmall(N,X,Y)
            ans2 = solveLarge(N,X,Y)
        end
    end
    print("$pass/$ntc passed\n")
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
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        for i in 1:N; X[i],Y[i] = gis(); end
        #ans = solveSmall(N,X,Y)
        ans = solveLarge(N,X,Y)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test(1000,7,5)
#test(100,9,10)
#test(1000,7,1000)
#test(1000,7,1_000_000_000)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

