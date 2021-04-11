
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

## We do traversals from all "base classes" (i.e. classes which have no dependencies)
## We use BFS to avoid any recursion stuff (stylistic preference) 
function solve(N::I,M::Vector{VI})::String
    adj::Vector{VI} = [VI() for i in 1:N]
    parents::VI = []
    for i in 1:N
        if length(M[i]) == 0; push!(parents,i); end
        for m in M[i]; push!(adj[m],i); end
    end
    sb::Vector{Bool} = fill(false,N)
    q::VI = []
    for p in parents
        fill!(sb,false)
        push!(q,p); sb[p] = true
        while !isempty(q)
            nn = popfirst!(q)
            for c in adj[nn]
                if sb[c]; return "Yes"; end
                push!(q,c); sb[c] = true
            end
        end
    end
    return "No"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        M::Vector{VI} = [VI() for i in 1:N]
        for i in 1:N; M[i] = gis(); popfirst!(M[i]); end
        ans = solve(N,M)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
