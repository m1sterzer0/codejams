
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
### We consider "groups" of contiguously faced pancakes, and we can count the number of contiguous groups
### in the stack
##
### We make two observations:
###    * The "best" we can do is to reduce the number of contiguously grouped pancakes by one on each "flip"
###    * If the bottom of the stack is faced incorrectly, we have to flip the whole stack, and that doesn't
###      reduce the number of continuous groups
###
### Thus, the "best" we can do is for #(contiguous groups) - 1, and we have to add 1 if the bottom pancake 
### is facing the wrong way.
###
### We note that this is realizable with the simple strategy of just flipping the top contiguous group.
######################################################################################################

function solve(S::String)::I
    flips::I = count(x->S[x]!=S[x+1],1:length(S)-1)
    return S[end] == '-' ? flips+1 : flips
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S::String = gs()
        ans = solve(S)
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

