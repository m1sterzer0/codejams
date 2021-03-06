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

function nthperm!(a::AbstractVector, k::Integer)
    n = length(a)
    n == 0 && return a
    f = factorial(oftype(k, n))
    0 < k <= f || throw(ArgumentError("permutation k must satisfy 0 < k = $f, got $k"))
    k -= 1 # make k 1-indexed
    for i=1:n-1
        f ÷= n - i + 1
        j = k ÷ f
        k -= j * f
        j += i
        elt = a[j]
        for d = j:-1:i+1
            a[d] = a[d-1]
        end
        a[i] = elt
    end
    a
end

nthperm(a::AbstractVector, k::Integer) = nthperm!(collect(a), k)

function nthperm(p::AbstractVector{<:Integer})
    isperm(p) || throw(ArgumentError("argument is not a permutation"))
    k, n = 1, length(p)
    for i = 1:n-1
        f = factorial(n-i)
        for j = i+1:n
            k += ifelse(p[j] < p[i], f, 0)
        end
    end
    return k
end

###############################################################################
### END PERMUTATION Code
###    Leveraged from Combinatorics.jl
###############################################################################

function solve(Z::Int64, X::Vector{Int64}, Y::Vector{Int64}, M::Vector{Int64})::Int64
    ans = 0
    zidx::Vector{Int64} = collect(1:Z)
    for zarr in permutations(zidx)
        #print("DBG: zarr:$zarr\n")
        lans = 0
        x,y,tt = 0,0,0
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
        Z = gi()
        X::Vector{Int64} = fill(0,Z)
        Y::Vector{Int64} = fill(0,Z)
        M::Vector{Int64} = fill(0,Z)
        for i in 1:Z; X[i],Y[i],M[i] = gis(); end
        ans = solve(Z,X,Y,M)
        print("$ans\n")
    end
end

main()

