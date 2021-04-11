
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

## From Combinations.jl (why isn't this part of the base language??)
struct WithReplacementCombinations{T}; a::T; t::Int; end
Base.eltype(::Type{WithReplacementCombinations{T}}) where {T} = Vector{eltype(T)}
Base.length(c::WithReplacementCombinations) = binomial(length(c.a) + c.t - 1, c.t)
with_replacement_combinations(a, t::Integer) = WithReplacementCombinations(a, t)
function Base.iterate(c::WithReplacementCombinations, s = [1 for i in 1:c.t])
    (!isempty(s) && s[1] > length(c.a) || c.t < 0) && return
    n = length(c.a); t = c.t; comb = [c.a[si] for si in s]
    if t > 0
        s = copy(s)
        changed = false
        for i in t:-1:1
            if s[i] < n
                s[i] += 1; for j in (i+1):t; s[j] = s[i]; end; changed = true; break
            end
        end
        !changed && (s[1] = n+1)
    else
        s = [n+1]
    end
    return (comb, s)
end

function solve(R::I,N::I,M::I,K::I,board::Array{I,2})::VVI
    ans::VVI = []

    ## Initialize the data structure
    combspace = collect(with_replacement_combinations(collect(2:M),N))
    #print("DBG: combspace\n")

    ## Calculate the sums
    sumset::SI = SI()
    push!(sumset,1)
    for i in 1:N
        svals::VI = [x for x in sumset]
        for sv in svals; for j in 2:M; push!(sumset,sv*j); end; end
    end
    sumvals::VI = [x for x in sumset]  ## Around 6k of these for large
    sort!(sumvals)
    sum2idx::Dict{I,I} = Dict{I,I}()
    for (i,j) in enumerate(sumvals); sum2idx[j] = i; end

    sb::Array{Int16,2} = fill(Int16(0),length(combspace),length(sumvals))

    ## Initial probabilities
    initprob::VF = []
    denfact1::F = 1 / (M-1)^N
    for a in combspace
        ways::I = 1; left::I = N
        for m in 2:M
            cc::I = count(x->x==m,a)
            if cc > 0; ways *= binomial(left,cc); left -= cc; end
        end
        push!(initprob,ways*denfact1)
    end

    ## create probabilities of each output
    for (i,a) in enumerate(combspace)
        d1::Dict{I,I} = Dict{I,I}()
        d1[1] = 1
        for n in a
            newres::VPI = []
            for (k,v) in d1; push!(newres,(k*n,v)); end
            for (k,v) in newres
                if !haskey(d1,k); d1[k] = v; else; d1[k] += v; end
            end
        end
        for (k,v) in d1; idx = sum2idx[k]; sb[i,idx] = Int16(v); end
    end
    #print("DBG: initoutcomes\n")

    ## Do the Bayes loop
    for i in 1:R
        #if i % 100 == 0; print("DBG: i:$i R:$R\n"); end
        p::VF = copy(initprob)
        alive::VI = collect(1:length(p))
        nextalive::VI = []
        ## process observations in this order to reduce the number of
        ## possibilities
        for k in board[i,:]
            kidx = sum2idx[k]
            empty!(nextalive)
            s::F = 0.00
            for idx in alive
                vv = sb[idx,kidx]
                if vv > 0; p[idx] *= vv; s += p[idx]; push!(nextalive,idx)
                else p[idx] = 0.00
                end
            end
            for idx in nextalive; p[idx] /= s; end
            (alive,nextalive) = (nextalive,alive) 
        end
        (pp,idx) = findmax(p)
        push!(ans,copy(combspace[idx]))
    end
    return ans
end

function test(ntc::I,R::I,N::I,M::I,K::I,X::I,check::Bool=true)
    for ttt in 1:ntc
        targets::VVI = []
        for i in 1:R; push!(targets,rand(2:M,N)); end
        for i in 1:R; sort!(targets[i]); end  ## Helps with the compare
        board::Array{I,2} = fill(0,R,K)
        for i in 1:R
            for j in 1:K
                prod = 1
                for k in 1:N; prod *= rand() < 0.5 ? 1 : targets[i][k]; end
                board[i,j] = prod
            end
        end
        ans = solve(R,N,M,K,board)
        if check
            pass = 0
            for i in 1:R
                if ans[i] == targets[i]; pass += 1; end
            end
            if pass >= X
                print("Case #$ttt: passed ($pass/$R right) X==$X\n")
            else
                print("Case #$ttt: ERROR ($pass/$R right) X==$X\n")
                ans = solve(R,N,M,K,board)
            end
        else
            print("Case #$ttt:\n")
            for i in 1:R; ansstr = join(ans[i],""); print("$ansstr\n")
            end
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq:\n")
        R,N,M,K = gis()
        board::Array{I,2} = fill(0,R,K)
        for i in 1:R; board[i,:] = gis(); end
        ans = solve(R,N,M,K,board)
        for i in 1:R; ansstr = join(ans[i],""); print("$ansstr\n"); end
    end
end

Random.seed!(8675309)
main()
#test(1,100,3,5,7,50,false)
#test(1,8000,12,8,12,1120)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile test(1,100,3,5,7,50)
#Profile.clear()
#@profilehtml test(1,8000,12,8,12,1120)

