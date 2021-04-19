
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
### a) We notice that our total surface area will be area of the top circular surface of the bottom
###    pancake + the area of the "edges" of ALL the pancakes in the stack.
### b) This leads to a nice little O(n^2) algorithm which should be fast enough.  We sort the pancakes
###    by 2*r*h, and then we iterate through all of the candidates as possible bases.
### c) We can move to N log(N) with a more complex data structure, but not worth it for these limits.
######################################################################################################

function solve(N::I,K::I,R::VI,H::VI)::F
    byEdge::VPI = sort([(2*R[i]*H[i],i) for i in 1:N],rev=true)
    best::I = 0
    for (baseArea::I,baseIdx::I) in byEdge
        working::I = baseArea + R[baseIdx]^2; stackCount::I = 1
        if K == 1; best = max(working,best); continue; end
        for (pArea::I,pIdx::I) in byEdge
            if pIdx != baseIdx && R[pIdx] <= R[baseIdx]
                working += pArea; stackCount += 1
                if K == stackCount; best = max(working,best); continue; end
            end
        end
    end
    return best * pi
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        R::VI = fill(0,N)
        H::VI = fill(0,N)
        for i in 1:N; R[i],H[i] = gis(); end
        ans = solve(N,K,R,H)
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

