
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
### Simple strategy
### 1) We have a directed acyclic graph (if there are cycles, then there are infinite ways)
### 2) Directed acyclic graphs correspond to a topological sorting, so we can assume that 
###    all paths are in order from node 1 to node B
### 3) If we maximally connect the directed graph, we notice that we get powers of 2 (namely 2^(B-2))
###    B = 2,  #paths =  1
###    B = 3,  #paths =  1 + 1
###    B = 4,  #paths =  2 + 1 + 1
###    B = 5,  #paths =  4 + 2 + 1 + 1
###    B = 6,  #paths =  8 + 4 + 2 + 1 + 1
###    B = 7,  #paths = 16 + 8 + 4 + 2 + 1 + 1
### 4) We can easily pick any number less than this by first maximally connecting the nodes from 2:B and then
###    carefully choosing which which connections we make from node 1 using a "binary representation" of M to guide
###    us.
######################################################################################################

function solve(B::I,M::I)::Tuple{String,VS}
    if M > 2^(B-2); return ("IMPOSSIBLE",[]); end
    g::Array{I,2} = [i > 1 && i < B && j > i ? 1 : 0 for i in 1:B,j in 1:B]
    if M == 2^(B-2)
        g[1,:] = [j>1 ? 1 : 0 for j in 1:B]
    else
        ## Inner B-2 elements of row 1 should be the binary representation of M
        g[1,:] = [j>1 && j<B && (M & (1 << (B-1-j))) > 0 ? 1 : 0 for j in 1:B]
    end
    return ("POSSIBLE", [ join(g[i,:],"") for i in 1:B ])
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        B::I,M::I = gis()
        ans = solve(B,M)
        print("$(ans[1])\n")
        for ss in ans[2]; print("$ss\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

