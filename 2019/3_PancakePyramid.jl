
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

mutable struct FenwickTree; bi_tree::VI; n::I; tot::I; end

FenwickTree(n::I) = FenwickTree(fill(0,n),n,0)
function FenwickTree(a::VI)
    n::I = length(a)
    tree::FenwickTree = FenwickTree(n)
    for i::I in 1:n; inc!(tree,i,a[i]); end
    return tree
end
Base.length(ft::FenwickTree) = ft.n
Base.eltype(::Type{FenwickTree}) = Int64
function Base.empty!(ft::FenwickTree)
    fill!(ft.bi_tree,0)
    ft.tot = 0
end

function inc!(ft::FenwickTree, ind::I, val = 1)
    i::I = ind
    n::I = ft.n
    while i <= n
        ft.bi_tree[i] += val
        i += i&(-i)
    end
    ft.tot += val
end

dec!(ft::FenwickTree, ind::I, val = 1 ) = inc!(ft, ind, -val)

function incdec!(ft::FenwickTree, left::I, right::I, val::I = 1)
    inc!(ft, left, val)
    dec!(ft, right, val)
end

function prefixsum(ft::FenwickTree, ind::I)::I
    if ind < 1; return 0; end
    sum::I = 0; i::I = ind; n::I = ft.n
    while i > 0
        sum += ft.bi_tree[i]
        i -= i&(-i)
    end
    return sum
end

suffixsum(ft::FenwickTree, ind::I)::I = ind > ft.n ? 0 : ft.tot - prefixsum(ft,ind-1)
rangesum(ft::FenwickTree, left::I, right::I)::I = prefixsum(ft,right) - prefixsum(ft,left-1)
Base.getindex(ft::FenwickTree, ind::I) = prefixsum(ft, ind)

################################################################################
## End Fenwick Tree (Adapted from datastructures.jl)
################################################################################

function solveVerySmall(S::I,P::VI)
    ans::I = 0
    mmm::I = 1_000_000_007
    for l in 1:S-2
        for r in l+2:S
            m::I,v::I = l,P[l]
            for i in l:r; if P[i] > v; (m,v) = (i,P[i]); end; end
            v = P[l]
            for i in l:m
                if P[i] >= v; v = P[i]; else; ans = (ans + (v-P[i])) % mmm; end
            end
            v = P[r]
            for i in r:-1:m
                if P[i] >= v; v = P[i]; else; ans = (ans + (v-P[i])) % mmm; end
            end
        end
    end
    return ans
end

function solveSmall(S::I,P::VI)
    ci::Array{I,2} = fill(0,S,S)
    li::Array{I,2} = fill(0,S,S)
    ri::Array{I,2} = fill(0,S,S)
    mmm::I = 1_000_000_007
    for i::I in 1:S
        v::I = P[i]
        inc::I = 0
        for j in i:S
            if P[j] >= v; v = P[j]; else; inc = (inc + (v-P[j])) % mmm; end
            li[i,j] = inc
        end
    end
    for i::I in S:-1:1
        v::I = P[i]
        inc::I = 0
        for j in i:-1:1
            if P[j] >= v; v = P[j]; else; inc = (inc + (v-P[j])) % mmm; end
            ri[i,j] = inc
        end
    end
    for i::I in 1:S
        mymax::I,locmax::I = P[i],i
        for j in i:S
            if P[j] > mymax; mymax = P[j]; locmax = j; end
            ci[i,j] = locmax
        end
    end
    ans::I = 0
    for l in 1:S-2
        for r in l+2:S
            m = ci[l,r]
            ans = (ans + li[l,m]) % mmm
            ans = (ans + ri[r,m]) % mmm
        end
    end
    return ans
end

################################################################################
# * Clearly I can't do the large interval by inverval -- i need to aggregate
#   the intervals
# * Consider something that looks like this
#       
#   *
#   *                   *
#   *         * x x x x *
#   *         * x x x x *         *
#   * *     * * x x x x * *     * *
#   * * * * * * x x x x * *   * * *
#   * * * * * * * * * * * * * * * *  
#   ^         ^         ^
#   c         a         b
# * I want to count in how many intervals I have to fill in those Xs
# * Whenever the left endpoint is between c+1 and a inclusive, and the
#   right endpoint is at least as far as b, we need to include those Xs
# * This gives rise to the following algorithm sketch
#   - Calculate the maximum left and right neighbors using a stack -- O(N)
#   - For each term, calculate the size of the X pool with a range sum query O(NlogN -- can do better if needed)
#   - multiply out the intervals that need the Xs and add 
# * Have to be careful with the matching heights to avoid double counting
################################################################################

function solveLarge(S::I,P::VI)
    mmm::I = 1_000_000_007
    ## Calc taller to the left
    st::VPI = [(10^18,0)]; leftTaller::VI  = fill(0,S)
    for i in 1:S
        p = P[i]
        while p > st[end][1]; pop!(st); end
        leftTaller[i] = st[end][2]
        push!(st,(p,i))
    end
    ## Calc taller to the right
    st = [(10^18,S+1)]; rightTaller::VI = fill(0,S)
    for i in S:-1:1
        p = P[i]
        while p >= st[end][1]; pop!(st); end
        rightTaller[i] = st[end][2]
        push!(st,(p,i))
    end
    ans::I = 0
    ft::FenwickTree = FenwickTree(P)
    for i in 1:S
        ## Peak is to the left
        if leftTaller[i] >= 1 && leftTaller[i]+1 < i
            numleft::I = leftTaller[i]
            numright::I = rightTaller[i]-i
            numint::I = numleft*numright % mmm
            addedPerInt::I = (P[i] * (i-leftTaller[i]) - (prefixsum(ft,i)-prefixsum(ft,leftTaller[i]))) % mmm
            adder::I = numint * addedPerInt % mmm
            ans = (ans + adder) % mmm
        end

        ## Peak is to the right
        if rightTaller[i] <= S && i < rightTaller[i]-1
            numright = S-rightTaller[i]+1
            numleft = i-leftTaller[i]
            numint = numleft*numright % mmm
            addedPerInt = (P[i] * (rightTaller[i]-i) - (prefixsum(ft,rightTaller[i]-1)-(i == 1 ? 0 : prefixsum(ft,i-1)))) % mmm
            adder = numint * addedPerInt % mmm
            ans = (ans + adder) % mmm
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S = gi()
        P::VI = gis()
        #ans = solveVerySmall(S,P)
        #ans = solveSmall(S,P)
        ans = solveLarge(S,P)
        print("$ans\n")
    end
end

function gencase(Smin::I,Smax::I,Pmax::I)
    S = rand(Smin:Smax)
    P = rand(1:Pmax,S)
    return (S,P)
end

function test(ntc::I,Smin::I,Smax::I,Pmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (S,P) = gencase(Smin,Smax,Pmax)
        ans2 = solveLarge(S,P)
        if check
            ans1 = solveSmall(S,P)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(S,P)
                ans2 = solveLarge(S,P)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end


Random.seed!(8675309)
main()
#test(100,1,100,1000000000)
#test(1000,1,100,1000000000)




#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

