
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

function calcCost(N::I,L::VI)
    ans::I = 0
    inf = 1_000_000_000_000_000_000
    for i in 1:N-1
        minv::I,minidx::I = inf,0
        for j in i:N
            if L[j] < minv; minv = L[j]; minidx = j; end
        end
        ans += (minidx-i+1)
        L[i:minidx] = reverse(L[i:minidx])
    end
    return ans
end

function solveSmall(N::I,C::I)::String
    ## Our min cost is N-1 for no swaps
    ## Our max cost is N + (N-1) + (N-2) + ... + 2  = (N-1)*(N+2)/2
    for x in unsafeIntPerm(collect(1:N))
        c = calcCost(N,copy(x))
        if c == C; return join(x," "); end
    end
    return "IMPOSSIBLE"
end

function solveit(N::I,C::I,idx::I)::VI
    ## Incoming cost is reduced by 1 for each move, so C == 0 means no more swaps.
    maxcost = N-idx
    if C == 0; return collect(idx:N); end
    if C <= maxcost; a = collect(idx:N); a[1:1+C] = reverse(a[1:1+C]); return a; end
    a = solveit(N,C-maxcost,idx+1)
    reverse!(a); push!(a,idx); return a
end

function solveLarge(N::I,C::I)::String
    ## Our min cost is N-1 for no swaps
    ## Our max cost is N + (N-1) + (N-2) + ... + 2  = (N-1)*(N+2)/2
    if C < N-1 || C > (N-1)*(N+2)÷2; return "IMPOSSIBLE"; end
    a = solveit(N,C-(N-1),1)
    astr::String = join(a," ")
    return astr
end

## Borrowed from the first testcase
function checker(N::I,L::VI)
    ans::I = 0
    inf = 1_000_000_000_000_000_000
    for i in 1:N-1
        minv::I,minidx::I = inf,0
        for j in i:N
            if L[j] < minv; minv = L[j]; minidx = j; end
        end
        ans += (minidx-i+1)
        L[i:minidx] = reverse(L[i:minidx])
    end
    return ans
end

function test()
    for N in 2:40
        for C in (N-1):(N-1)*(N+2)÷2
            astr = solveSmall(N,C)
            L = [parse(Int64,x) for x in split(astr)]
            refc = checker(N,L)
            if C != refc
                print("ERROR N:$N C:$C L:$L refc:$refc\n")
                astr = solveSmall(N,C)
            end
        end
    end
    print("DONE!\n")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N::I,C::I = gis()
        #ans = solveSmall(N,C)
        ans = solveLarge(N,C)
        print("$ans\n")
    end
end

Random.seed!(8675309)
#test()
main()