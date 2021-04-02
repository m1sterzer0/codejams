
## From Combinations.jl (why isn't this part of the base language??)
struct WithReplacementCombinations{T}; a::T; t::Int; end
Base.eltype(::Type{WithReplacementCombinations{T}}) where {T} = Vector{eltype(T)}
Base.length(c::WithReplacementCombinations) = binomial(length(c.a) + c.t - 1, c.t)
"""
    with_replacement_combinations(a, t)
Generate all combinations with replacement of size `t` from an array `a`.
"""
with_replacement_combinations(a, t::Integer) = WithReplacementCombinations(a, t)
function Base.iterate(c::WithReplacementCombinations, s = [1 for i in 1:c.t])
    (!isempty(s) && s[1] > length(c.a) || c.t < 0) && return
    n = length(c.a)
    t = c.t
    comb = [c.a[si] for si in s]
    if t > 0
        s = copy(s)
        changed = false
        for i in t:-1:1
            if s[i] < n
                s[i] += 1
                for j in (i+1):t; s[j] = s[i]; end
                changed = true
                break
            end
        end
        !changed && (s[1] = n+1)
    else
        s = [n+1]
    end
    (comb, s)
end

function createInitProb(c,M,N)
    rtotways::Float64 = 1.0 / (M-1)^N
    ways::Int64 = 1
    left::Int64 = N
    for m in 2:M
        cc::Int64 = count(x->x==m,c)
        if cc > 0; ways *= binomial(left,cc); left -= cc; end
    end
    return rtotways*ways
end

function createPdata(c,N)
    d1::Dict{Int64,Int64} = Dict{Int64,Int64}()
    d2::Dict{Int64,Float64} = Dict{Int64,Float64}()
    den = 1.0/2^N
    d1[1] = 1
    for n in c
        newres = []
        for (k,v) in d1; push!(newres,(k*n,v)); end
        for (k,v) in newres
            if !haskey(d1,k); d1[k] = v; else; d1[k] += v; end
        end
    end
    for (k,v) in d1; d2[k] = den*v; end
    return d2
end
    
function updateProb(pdata::Vector{Dict{Int64,Float64}},p::Vector{Float64},k::Int64)
    for i in 1:length(pdata); p[i] *= (haskey(pdata[i],k) ? pdata[i][k] : 0); end
    rptot = 1.0/sum(p)
    for i in 1:length(pdata); p[i] *= rptot; end
end
    
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        R,N,M,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        #print("DBG: HERE1\n")
        combspace = collect(with_replacement_combinations(collect(2:M),N))
        #print("DBG: HERE2\n")
        initProb = [ createInitProb(x,M,N) for x in combspace]
        #print("DBG: HERE3\n")
        pdata = [ createPdata(x,N) for x in combspace ]
        #print("DBG: HERE4\n")
        for r in 1:R
            p = initProb[:]
            KK = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            for k in KK; updateProb(pdata,p,k); end
            (_junk,idx) = findmax(p)
            ansstr = join(combspace[idx],"")
            print("$ansstr\n")
        end
    end
end

main()
