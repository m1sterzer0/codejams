const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

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

struct Permutations{T}; a::T; t::Int; end
Base.eltype(::Type{Permutations{T}}) where {T} = Vector{eltype(T)}
Base.length(p::Permutations) = (0 <= p.t <= length(p.a)) ? factorial(length(p.a), length(p.a)-p.t) : 0
permutations(a) = Permutations(a, length(a))
function permutations(a, t::Integer); if t < 0; t = length(a) + 1; end; Permutations(a, t); end

function Base.iterate(p::Permutations, s = collect(1:length(p.a)))
    (!isempty(s) && max(s[1], p.t) > length(p.a) || (isempty(s) && p.t > 0)) && return; nextpermutation(p.a, p.t ,s)
end

function nextpermutation(m, t, state)
    perm = [m[state[i]] for i in 1:t]
    n = length(state)
    if t <= 0; return(perm, [n+1]); end
    s = copy(state)
    if t < n; j = t + 1; while j <= n &&  s[t] >= s[j]; j+=1; end; end
    if t < n && j <= n
        s[t], s[j] = s[j], s[t]
    else
        if t < n; reverse!(s, t+1); end
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

function test1(cnt::I,n::I)
    a = collect(1:n)
    for i in 1:cnt
        nn = 0
        for x in permutations(a)
            nn += x[1]
        end
        print("$nn\n")
    end
end

function test2(cnt::I,n::I)
    a = collect(1:n)
    for i in 1:cnt
        nn = 0
        for x in unsafeIntPerm(a)
            nn += x[1]
        end
        print("$nn\n")
    end
end

@time test1(10,7)
@time test1(10,8)
@time test1(10,9)
@time test1(10,10)

@time test2(10,7)
@time test2(10,8)
@time test2(10,9)
@time test2(10,10)

for x in unsafeIntPerm([0,1,2,3,4],2); print("$x\n"); end
for x in unsafeIntPerm([0,1,2,3,4],5); print("$x\n"); end



