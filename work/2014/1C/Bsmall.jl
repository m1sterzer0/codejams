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

function compressTrain(a::AbstractString)::AbstractString
    c,last = [],'.'
    for cc in a
        if cc == last; continue; end
        push!(c,cc); last=cc
    end
    return join(c)
end



function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        trains = split(readline(infile))
        ctrains =[ compressTrain(x) for x in trains ]
        indices = collect(1:N)
        ans = 0
        sb = fill(false,26)
        for p in permutations(indices)
            trainstr  = join([ctrains[i] for i in p])
            trainnums = [Int64(x-'`') for x in trainstr]
            last = 0
            good = true
            fill!(sb,false)
            for i in trainnums
                if i == last; continue; end
                if sb[i]; good = false; break; end
                sb[i] = true
                last = i
            end
            if good; ans += 1; end
            #print("$trainstr $sb, $ans\n")
        end
        print("$ans\n")
    end
end

main()