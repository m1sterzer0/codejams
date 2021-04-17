
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

function buildIt(sb::Array{Char,2},n::I)
    for i::I in 1:n
        l::I = 2^(i-1)
        sb[i+1,1:2:2*l] = sb[i,1:l]
        sb[i+1,2:2:2*l] = [x == 'R' ? 'S' : x == 'P' ? 'R' : 'P' for x in sb[i,1:l]]
    end
end

function checkIt(sb::Array{Char,2},n::I,r::I,p::I,s::I)
    if count(x->x=='R',sb[n+1,1:2^n]) != r; return false; end
    if count(x->x=='P',sb[n+1,1:2^n]) != p; return false; end
    if count(x->x=='S',sb[n+1,1:2^n]) != s; return false; end
    return true
end

function sortIt(sb::Array{Char,2},n::I)::String
    b::VS = ["$c" for c in sb[n+1,1:2^n]]
    for i in 1:n
        l::I = length(b)
        b = [min(x*y,y*x) for (x,y) in zip(b[1:2:l],b[2:2:l])]
    end
    return b[1]
end

function solve(N::I,R::I,P::I,S::I,working)::String
    (sb::Array{Char,2},) = working
    ans::VS = []
    for seed in "PRS"
        sb[1,1] = seed
        buildIt(sb,N)
        if checkIt(sb,N,R,P,S);
            push!(ans,sortIt(sb,N))
        end
    end
    sort!(ans)
    return length(ans) == 0 ? "IMPOSSIBLE" : "$(ans[1])"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    sb::Array{Char,2} = fill('x',13,4096)
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,P,S = gis()
        ans = solve(N,R,P,S,(sb,))
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

