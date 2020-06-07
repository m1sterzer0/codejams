using Printf

######################################################################################################
### We generate all of the googlements up front with digit sum <= than the length of the googlement.
### We can use stars and bars for this.  We can calculate the number of ancestors of these using
### simple combinatorics.
######################################################################################################

######################################################################################################
### BEGIN COMBINATIONS ITERATOR
### From: https://github.com/JuliaMath/Combinatorics.jl/blob/master/src/combinations.jl
######################################################################################################

struct Combinations
    n::Int
    t::Int
end

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

function googlementsa(n::Integer)
    ans = []
    for i in 1:n
        append!(ans,collect(ballsUrns(i,n)))
    end
    return ans
end

function decay(a,n)
    ans = zeros(Int64,n)
    for x in a
        if x > 0; ans[x] += 1; end
    end
    return join(ans,"")
end

function doGooglements(n::Integer)
    googlements = googlementsa(n)
    ans = Dict()
    depCnt = Dict()
    decayDict = Dict()
    ancestorNumerator = factorial(n)

    ## Init the data structures
    for a in googlements
        x = join(a,"")
        ans[x] = 1
        depCnt[x] = 0
    end

    ## Decay all of the elements
    for a in googlements
        x = join(a,"")
        y = decay(a,n)
        decayDict[x] = y
        depCnt[y] += 1
    end

    ## Add the ancestors for the nodes with ancestorDigsum > n
    digplace = collect(1:n)'
    for a in googlements
        ancestorDigsum = digplace * a
        if ancestorDigsum > n
            xx = join(a,"")
            ancestors = ancestorNumerator
            for x in a; ancestors ÷= factorial(x); end
            ancestors ÷= factorial(n-sum(a))  ## Have to account for the zereos
            ans[xx] += ancestors
        end
    end

    ## Propagate the ancestor counts along the graph
    free = [x for (x,v) in depCnt if v == 0]
    while !isempty(free)
        x = pop!(free)
        y = decayDict[x]
        ans[y] += ans[x]
        depCnt[y] -= 1
        if depCnt[y] == 0; push!(free,y); end
    end

    return ans
end

function precalc()
    ans = Dict()
    for i in 1:9
        xx = doGooglements(i)
        merge!(ans,xx)
    end
    return ans
end

function main(infn="")
    g = precalc()
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        G = rstrip(readline(infile))
        ans = 1
        if haskey(g,G); ans = g[G]; end
        print("$ans\n")
    end
end

main()
