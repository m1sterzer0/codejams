const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

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
