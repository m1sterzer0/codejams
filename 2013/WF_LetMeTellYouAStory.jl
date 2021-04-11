
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

function prework()
    fact::VI = fill(1,10001)
    factinv::VI = fill(1,10001)
    for i in 1:10000
        fact[i+1] = (fact[i]* i) % 10007
        factinv[i+1] = invmod(fact[i+1],10007)
    end
    return (fact,factinv)
end

function solveSmall(N::I,NN::VI,working)::I
    (fact::VI,factinv::VI) = working
    noninc::Array{I,2} = fill(0,N,N)
    for i in 1:N; noninc[i,1] = 1; end
    for i in N-1:-1:1
        for j in i+1:N
            if NN[i] < NN[j]; continue; end
            for k in 1:N-1
                noninc[i,k+1] = (noninc[i,k+1] + noninc[j,k]) % 10007
            end
        end
    end

    totperms,badperms = 0,0
    for i in 1:N
        for k in 1:N
            totinc = (fact[N-k+1] * noninc[i,k]) % 10007
            totperms = (totperms + totinc) % 10007
            if k > 1
                badper = (fact[N-k+1] * k) % 10007
                badinc = badper * noninc[i,k] % 10007
                badperms = (badperms + badinc) % 10007
            end
        end
    end

    ans = totperms - badperms
    if ans < 0; ans += 10007; end
    return ans
end

function solveLarge(N::I,NN::VI,working)::I
    (fact::VI,factinv::VI) = working
    NV::VI = unique(sort(NN))
    Norder::VI = []
    for v in NV
        for i in N:-1:1
            if NN[i] == v; push!(Norder,i); end
        end
    end
    ## Iterate through subsequences by length
    ## Add in the ways to get to that sequence
    ## Subtract off the ways to
    vals::VI = fill(1,N)
    ft::FenwickTree = FenwickTree(N)
    ways::I = fact[N+1]  ## Accounts for all of the ways to get to a single element
    overcount::I = 0
    newvals::VI = fill(0,N)
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
    return ans
end

function gencase(Nmin::I,Nmax::I,NNmax::I)
    N = rand(Nmin:Nmax)
    NN::VI = rand(1:NNmax,N)
    return (N,NN)
end

function test(ntc::I,Nmin::I,Nmax::I,NNmax::I,check::Bool=true)
    working = prework()
    pass = 0
    for ttt in 1:ntc
        (N,NN) = gencase(Nmin,Nmax,NNmax)
        ans2 = solveLarge(N,NN,working)
        if check
            ans1 = solveSmall(N,NN,working)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,NN,working)
                ans2 = solveLarge(N,NN,working)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    working = prework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        NN::VI = gis()
        #ans = solveSmall(N,NN,working)
        ans = solveLarge(N,NN,working)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(1,1,100,10)
#test(10,1,100,10)
#test(100,1,100,100)
#test(100,1,100,1000)
#test(100,1,100,100000)




#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

