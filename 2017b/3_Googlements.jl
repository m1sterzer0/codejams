
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

######################################################################################################
### BEGIN COMBINATIONS ITERATOR
### From: https://github.com/JuliaMath/Combinatorics.jl/blob/master/src/combinations.jl
######################################################################################################

struct Combinations; n::I; t::I; end

function Base.iterate(c::Combinations, s = [min(c.t - 1, i) for i in 1:c.t])
    if c.t == 0 # special case to generate 1 result for t==0
        isempty(s) && return (s, [1])
        return
    end
    for i in c.t:-1:1
        s[i] += 1
        if s[i] > (c.n - (c.t - i))
            continue
        end
        for j in i+1:c.t
            s[j] = s[j-1] + 1
        end
        break
    end
    s[1] > c.n - c.t + 1 && return
    (s, s)
end

Base.length(c::Combinations) = binomial(c.n, c.t)

Base.eltype(::Type{Combinations}) = Vector{Int}

function combinations(a, t::Integer)
    if t < 0
        # generate 0 combinations for negative argument
        t = length(a) + 1
    end
    reorder(c) = [a[ci] for ci in c]
    (reorder(c) for c in Combinations(length(a), t))
end

######################################################################################################
### END COMBINATIONS ITERATOR
### From: https://github.com/JuliaMath/Combinatorics.jl/blob/master/src/combinations.jl
######################################################################################################

function ballsUrns(n::Integer,m::Integer)
    vars = collect(1:n+m-1)
    convert(c,n,m) = vcat(c,[n+m]) .- vcat([0],c) .- 1
    (convert(c,n,m) for c in combinations(vars,m-1))
end

function googlementsa(n::I)::VVI
    ans::VVI = []
    for i in 1:n; append!(ans,collect(ballsUrns(i,n))); end
    return ans
end

function decay(a::VI,n::I)::String
    ans::VI = fill(0,n)
    for x in a; if x > 0; ans[x] += 1; end; end
    return join(ans,"")
end

function doGooglements(n::Integer)
    googlements = googlementsa(n)
    ans::Dict{String,I} = Dict{String,I}()
    depCnt::Dict{String,I} = Dict{String,I}()
    decayDict::Dict{String,String} = Dict{String,String}()
    ancestorNumerator::I = factorial(n)

    ## Init the data structures
    for a::VI in googlements
        x = join(a,""); ans[x] = 1; depCnt[x] = 0
    end

    ## Decay all of the elements
    for a::VI in googlements
        x = join(a,""); y = decay(a,n); decayDict[x] = y; depCnt[y] += 1
    end

    ## Add the ancestors for the nodes with ancestorDigsum > n
    digplace = collect(1:n)'
    for a::VI in googlements
        ancestorDigsum::I = digplace * a
        if ancestorDigsum > n
            xx::String = join(a,"")
            ancestors::I = ancestorNumerator
            for x::I in a; ancestors ÷= factorial(x); end
            ancestors ÷= factorial(n-sum(a))  ## Have to account for the zereos
            ans[xx] += ancestors
        end
    end

    ## Propagate the ancestor counts along the graph
    free::VS = [x for (x,v) in depCnt if v == 0]
    while !isempty(free)
        x::String = pop!(free)
        y::String = decayDict[x]
        ans[y] += ans[x]
        depCnt[y] -= 1
        if depCnt[y] == 0; push!(free,y); end
    end
    return ans
end

function precalc()
    ans::Dict{String,I} = Dict{String,I}()
    for i in 1:9
        xx::Dict{String,I} = doGooglements(i)
        merge!(ans,xx)
    end
    return ans
end


function solve(G::String,working)
    (g::Dict{String,I},) = working
    return haskey(g,G) ? g[G] : 1
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    g = precalc()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        G = gs()
        ans = solve(G,(g,))
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

