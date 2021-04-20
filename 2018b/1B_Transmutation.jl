
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
### There are two key insights
### * We can use binary search to figure out how much lead we can build
### * We build the lead "on credit" and then check to see if we can pay back the debt without
###   looping back on ourself.  In order to avoid overflow, we note that the starting material can'that
###   even make 10^10 of one element, so we can use that as a cutoff
######################################################################################################

function check(n::I,targ::I,R::VPI,visited::SI,inv::VI)
    if inv[targ] >= n; inv[targ] -= n; return true; end
    if targ ∈ visited || n >= 10^11; return false; end
    d = n-inv[targ]
    inv[targ] = 0
    push!(visited,targ)
    if !check(d,R[targ][1],R,visited,inv); return false; end
    if !check(d,R[targ][2],R,visited,inv); return false; end
    delete!(visited,targ)
    return true
end

function solve(M::I,R::VPI,G::VI)::I
    l::I,u::I = 0,10^10
    while (u-l > 1)
        m::I = (u+l) ÷ 2
        locG::VI = copy(G)
        if check(m,1,R,SI(),locG); l = m; else; u = m; end
    end
    return l
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        M = gi()
        R::VPI = []
        for i in 1:M; x,y = gis(); push!(R,(x,y)); end
        G::VI = gis()
        ans = solve(M,R,G)
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

