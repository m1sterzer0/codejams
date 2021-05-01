
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
### Trial and error shows that we have to use a mix of biasing against certain vases and spying
### Moves 1-19  -- Put coin 100 into 1 through 19
### Moves 20-49 -- Put 3 coins in each of 11:20
### Moves 50-69 -- Spy on all 20 vases
### Moves 70-95 -- Tank all but best two
### Moves 96-97 -- Spy on the best 2, pick a winner
### Moves 98-99 -- Tank the worse of the best two
### Move 100    -- Place our coin in vase 20.
### Note that we can put exactly one of our token into every vase.  This can occasionally help.
######################################################################################################

function dropcoin(p::I,v::I); d = gi(); println("$v $p"); flush(stdout); end
function spyvase(v::I); dropcoin(0,v); x = gis(); return x[1]; end

function solve()
    randcoins::VI = shuffle(collect(1:99))
    for i in 1:19; dropcoin(100,i); end
    for j in 11:20; for k in 1:3; dropcoin(pop!(randcoins),j); end; end
    spyvals::VPI = [(spyvase(i),i) for i in 1:20]
    sort!(spyvals); targ1 = popfirst!(spyvals); targ2 = popfirst!(spyvals)
    #print(stderr,"User DBG: spyvals: $spyvals\n")
    #print(stderr,"User DBG: targ1:$targ1 targ2:$targ2\n")
    for i in 1:26
        dropcoin(pop!(randcoins),spyvals[1][2])
        spyvals[1] = (spyvals[1][1]+1,spyvals[1][2])
        sort!(spyvals)  ## Should use minheap, but lazy
    end
    v1 = spyvase(targ1[2]); v2 = spyvase(targ2[2])
    loser = v1 >= v2 ? targ1[2] : targ2[2]
    #print(stderr,"User DBG: targ1:$targ1 v1:$v1 targ2:$targ2 v2:$v2 loser:$loser\n")
    for i in 1:2; dropcoin(pop!(randcoins),loser); end
    dropcoin(100,20)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        solve()
    end
end

Random.seed!(8675309)
main()
