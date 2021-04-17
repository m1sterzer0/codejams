
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
### Full disclosure: I had to look at the answers for the long.
###
### For the first program, we want to make an "anti-B" sequence with                           
### questionmarks after each character
###
### The only way to get B then is to replace ALL the question-marks with a
### subsequence of the second program.  We now need to create a sequence which
### doesn't contain B as a "generalized-subsequence" (a subsequence where adjacency
### is not required).  However, its content must allow us to create all the strings in 
### G
###
### For the short case, this is easy.  A string of L-1 1's will suffice.  Note that it is
### impossible to create a string of L 1's, but every other string is possible, since
### prog 1 has L zeros.
###
### For the long case, we want a prog 2 that can emit any L-1 character string, but it
### cannot emit the entire B string. (Looking at the answers), the solution here is actually
### pretty simple.  We take the first L-1 characters of B and emit a "01" for every '1' and
### "10" for every '0'.
### -- Note since ever pair contains a 0 and a 1, every L-1 character sequence can be emitted.
### -- If we try to emit B, we chew up 2 characters for each symbol, so we run out before
###    we emit the last character.
###
### Note one special case.  When L == 1, our algorithm doesn't work, so we have to do something different.
######################################################################################################

function solve(N::I,L::I,G::VS,B::String)::String
    if B in G; return "IMPOSSIBLE"; end
    prog1 = join([x == '0' ? "1?" : "0?" for x in B],"")
    prog2a = B[1] == '0' ? "1" : "0"
    prog2b = join([x == '0' ? "10" : "01" for x in B[1:end-1]],"")
    return L == 1 ? "$prog1 $prog2a" : "$prog1 $prog2b"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = gis()
        G::VS = gss()
        B::String = gs()
        ans = solve(N,L,G,B)
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

