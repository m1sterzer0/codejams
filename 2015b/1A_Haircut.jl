
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

function served(M::VI,m::I)
    ans = 0
    for x in M; ans += (m + x -1) ÷ x; end
    return ans
end

function solve(B::I,N::I,M::VI)
    l,u,m = [0,10^17+1,0]

    while (u-l > 1) 
        m = (u+l) ÷ 2
        l,u = N <= served(M,m) ? [l,m] : [m,u]
    end
    x = served(M,l)
    #print(stderr,"DEBUG x=$x l=$l N=$N B=$B M=$M\n")
    for i in 1:B
        if l % M[i] == 0
            x += 1; if x == N; return i; end
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        B,N = gis()
        M::VI = gis()
        ans = solve(B,N,M)
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

