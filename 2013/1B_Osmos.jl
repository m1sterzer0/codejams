
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solve(A::I,N::I,M::VI)::I
    if A == 1; return N; end ## Special case -- can't grow a mote of size 1
    MM::VI = copy(M); sort!(MM)
    ## Loop over how many motes we kill at the end
    best = N 
    for i in 0:N-1
        moves = i; sz = A
        for m in MM[1:N-i]
            while sz <= m; moves += 1; sz = 2*sz-1; end
            sz += m
        end
        best = min(moves,best)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        A,N = gis()
        M = gis()
        ans = solve(A,N,M)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

