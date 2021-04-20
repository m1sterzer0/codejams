
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
### I love these interactive problems.  I have no idea whether this strategy is "optimal", but it
### seems good enough in that most of the time I am only waiting for one square to hit and often
### we are doing productive work while that is happening.
###
### OK, our stragegy is as follows
### - Deploy once, and whatever comes back is the upper left corner of our array. WLOG, call it 1,1
###   We refer to coordinates by (row, column) (so it looks like (y,x), with increasing y pointed down).
### - SMALL: we deploy at (2,2), (3,2), (4,2), (5,2), (6,2)
### - LARGE: we deply at (2,2), (3,2), (4,2), ... (19,2), THEN...
###                      (2,3), (3,3), (4,3), ... (19,3). THEN...
###                      ...
###                      (2,9), (3,9), (4,9), ... (19,9) (up to 144 deployments)
###   For both cases, our "move-on" criteria depends on whether we are in a non-final row & column
###   -- Non-final row and non-final column -- move on when the upper-left square is filled
###   -- Final row, non-final column -- move on when all 3 squares on the left are filled
###   -- Non-final row, final column -- move on when the top 3 squares are filled
###   -- final row, final column -- move on when all 9 squares are filled.
###
### I ran a 1000 cases with the python based tester, and I ended up with a mean of 497 (on the 200 case)
### and a stddev of 44. maximum --> minimum was (367 to 667) (-2.9 sigma to +3.8 sigma)  This appears
### to have a healthy margin to the 1000 limit.
######################################################################################################

function trySquare(i::I,j::I)::PI
    print("$i $j\n"); flush(stdout); ny,nx = gis(); return (ny,nx)
end

function isdone(grid::Array{I,2},ei::I,ej::I,ci::I,cj::I)::Bool
    if grid[ci-1,cj-1] == 0; return false; end
    if ci == ei-1
        if grid[ci,cj-1] == 0; return false; end
        if grid[ci+1,cj-1] == 0; return false; end
    end
    if cj == ej-1
        if grid[ci-1,cj] == 0; return false; end
        if grid[ci-1,cj+1] == 0; return false; end
    end
    if ci == ei-1 && cj == ej-1; return false; end
    return true
end

function solve(A::I)
    ## Prepare the grid
    (N,M) = (A == 20) ? (7,3) : (20,10)
    grid::Array{I,2} = fill(0,N+3,M+3)
    cnt = 0
    ## Get a starter square
    (si,sj) = trySquare(2,2); cnt += 1; grid[si,sj] = 1
    (ei,ej) = (si+N-1,sj+M-1)
    (ci,cj) = (si+1,sj+1)
    while true
        (vi,vj) = trySquare(ci,cj); cnt += 1
        if vi == vj == 0; break; end
        cnt += 1; grid[vi,vj] = 1
        while isdone(grid,ei,ej,ci,cj)
            (ci,cj) = ci < ei-1 ? (ci+1,cj) : (si+1,cj+1)
        end
    end
    return cnt
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        #print("Case #$qq: ")
        A = gi()
        ans = solve(A)
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

