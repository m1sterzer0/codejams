
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

######################################################################################################
### Yay!  Another interactive problem
###
### The key to this one is that we can create blocks of exactly 2*10^10.  Our goal is to make ans
### many of these as possible.  The end state will then be
### K blocks of 2*10^10 and M blocks of less than that
### Our priorities are:
###    -- Make 2*10^10 blocks if we can
###    -- Get to an even number of blocks.
###    -- Work our way down to exactly 2 blocks of 2*10^10
###    -- When our opponent picks one of the 2 blocks, we pick the other and act accordingly.
### The rest is bookkeeping
######################################################################################################

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function chooseMove(intervals::VPI)::I
    ## Intervals are encoded as (start,size)
    ## Look for a block at least 30_000_000_000 large to make our 20_000_000_000 block
    iarr::VI = [ x[1] for x in intervals if x[2] >= 30_000_000_000 ]
    if length(iarr) > 0; return iarr[1][1] + 20_000_000_000; end

    ## Get down to the end game
    iarr = [ x[1] for x in intervals if x[2] > 20_000_000_000 ]
    if length(iarr) > 0; return iarr[1][1]; end

    ## If there are an even number of blocks, use one of our 20_000_000_000 blocks
    iarr = [ x[1] for x in intervals if x[2] == 20_000_000_000 && length(intervals) % 2 == 0 ]
    if length(iarr) > 0; return iarr[1][1]; end

    ## If we have more than 2 blocks of size 20_000_000_000, then blow one away
    ## If we have exactly one block of size 20_000_000_000, then blow it away
    iarr = [ x[1] for x in intervals if x[2] == 20_000_000_000]
    if length(iarr) == 1 || length(iarr) > 2; return iarr[1][1]+1; end

    ## Here we don't want to use a 20_000_000_000
    iarr = [ x[1] for x in intervals if x[2] < 20_000_000_000 ]
    if length(iarr) > 0; return iarr[1][1]; end

    ## Otherwise, make any legal move
    return intervals[1][1]
end

function recordMove(intervals::VPI,move::I)::VPI
    newInt::VPI = []
    for (i::I,s::I) in intervals
        l::I,r::I = i,i+s-1
        if move < l || move > r; push!(newInt,(i,s)); continue; end
        m1::I = move-1; m2::I = move+10_000_000_000
        s1::I = m1-i+1; s2::I = r-m2+1
        if s1 >= 10_000_000_000; push!(newInt,(i,s1)); end
        if s2 >= 10_000_000_000; push!(newInt,(m2,s2)); end
    end
    return newInt
end

function solve()::I
    board::VPI = [(1,1_000_000_000_000)]
    while(true)
        p = gi()
        if p == -1; exit(1); end
        if p < 0; return p; end
        board = recordMove(board,p)
        q = chooseMove(board)
        board = recordMove(board,q)
        print("$q\n"); flush(stdout)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I,W::I = gis()
    for qq in 1:tt
        solve()
    end
end

Random.seed!(8675309)
main()

