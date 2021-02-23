################################################################################
## Begin Fenwick Tree (Adapted from datastructures.jl)
################################################################################

mutable struct FenwickTree
    bi_tree::Vector{Int64}
    n::Int64
    tot::Int64
end

FenwickTree(n::Int64) = FenwickTree(fill(0,n),n,0)
function FenwickTree(a::AbstractVector{Int64})
    n = length(a)
    tree = FenwickTree(n)
    for i in 1:n; inc!(tree,i,a[i]); end
    return tree
end
Base.length(ft::FenwickTree) = ft.n
Base.eltype(::Type{FenwickTree}) = Int64
function Base.empty!(ft::FenwickTree)
    fill!(ft.bi_tree,0)
    ft.tot = 0
end

function inc!(ft::FenwickTree, ind::Int64, val = 1)
    i = ind
    n = ft.n
    #@boundscheck 1 <= i <= n || throw(ArgumentError("$i should be in between 1 and $n"))
    #@inbounds while i <= n
    while i <= n
        ft.bi_tree[i] += val
        i += i&(-i)
    end
    ft.tot += val
end

dec!(ft::FenwickTree, ind::Int64, val = 1 ) = inc!(ft, ind, -val)

function incdec!(ft::FenwickTree, left::Int64, right::Int64, val = 1)
    inc!(ft, left, val)
    dec!(ft, right, val)
end

function prefixsum(ft::FenwickTree, ind::Int64)
    if ind < 1; return 0; end
    sum = 0
    i = ind
    n = ft.n
    #@boundscheck 1 <= i <= n || throw(ArgumentError("$i should be in between 1 and $n"))
    #@inbounds while i > 0
    while i > 0
        sum += ft.bi_tree[i]
        i -= i&(-i)
    end
    return sum
end

suffixsum(ft::FenwickTree, ind::Int64) = ind > ft.n ? 0 : ft.tot - prefixsum(ft,ind-1)
rangesum(ft::FenwickTree, left::Int64, right::Int64) = prefixsum(ft,right) - prefixsum(ft,left-1)
Base.getindex(ft::FenwickTree, ind::Int64) = prefixsum(ft, ind)

################################################################################
## End Fenwick Tree (Adapted from datastructures.jl)
################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    fact::Vector{Int64} = fill(1,10001)
    for i in 1:10000
        fact[i+1] = (fact[i] * i) % 10007
    end
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        NN = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        NV = unique(sort(NN))
        Norder = []
        for v in NV
            for i in N:-1:1
                if NN[i] == v; push!(Norder,i); end
            end
        end

        ## Iterate through subsequences by length
        ## Add in the ways to get to that sequence
        ## Subtract off the ways to
        vals::Vector{Int64} = fill(1,N)
        ft::FenwickTree = FenwickTree(N)
        ways::Int64 = fact[N+1]  ## Accounts for all of the ways to get to a single element
        overcount::Int64 = 0
        newvals::Vector{Int64} = fill(0,N)
        for l in 2:N
            empty!(ft)
            fill!(newvals,0)
            for i in Norder
                newvals[i] = suffixsum(ft,i) % 10007
                if vals[i] > 0; inc!(ft,i,vals[i]); end
            end
            vals[:] = newvals
            numl = sum(vals) % 10007
            totinc = (numl * fact[N-l+1]) % 10007
            totdec = (totinc * l) % 10007
            ways = (ways + totinc) % 10007
            overcount = (overcount + totdec) % 10007
        end
        ans = ways - overcount
        if ans < 0; ans += 10007; end
        print("$ans\n")
    end
end

main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("E.in")
#Profile.clear()
#@profilehtml main("Etc2.in")