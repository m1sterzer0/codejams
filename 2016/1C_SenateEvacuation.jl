
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
### Three step plan for evacuation
### 1) We whittle down the most populous party one-by-one until it matches the cardinality of the
###    second most populous party.
### 2) We evacuate everyone not in the top two parties one-by-one
### 3) We evacuate the two most populous parties two-by-two to prevent the majority condition
######################################################################################################

function solve(N::I,P::VI)::String
    alph::String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    counts::VPI = [(p,i) for (i,p) in enumerate(P)]
    sort!(counts,rev=true)
    s1::VC = [alph[counts[1][2]] for i in 1:counts[1][1]-counts[2][1] ]
    s2::VC = [alph[counts[i][2]] for i in 3:N for j in 1:counts[i][1] ]
    s3::VS = [alph[counts[1][2]] * alph[counts[2][2]] for i in 1:counts[2][1]]
    return join(vcat(s1,s2,s3)," ")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        P::VI = gis()
        ans = solve(N,P)
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

