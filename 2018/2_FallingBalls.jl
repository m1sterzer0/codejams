
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
### * We notice that since the first and last columns must be clear, we must have that both
###   B[1] and B[C] are > 0, otherwise we are IMPOSSIBLE
### * Otherwise, we can just figure out where we need each ball to land and build a diagonal ramp
###   to get it there.  Note that the path of the balls will never cross.
######################################################################################################

function solve(C::I,B::VI)::VS
    if B[1] == 0 || B[C] == 0; return ["IMPOSSIBLE"]; end
        
    ## Generate the target column for each of the balls
    nxtball::I = 1
    target::VI = fill(0,C)
    for i::I in 1:C
        for j::I in 1:B[i]
            target[nxtball] = i; nxtball+=1
        end
    end

    ## figure out how many rows we need
    ans::VS = []
    R::I = 1 + maximum(abs(target[x]-x) for x in 1:C)
    push!(ans,"$R")

    ## make the board
    board = fill('.',R,C)
    for i in 1:C
        movement = target[i] - i
        if movement > 0
            for j in 1:movement
                board[j,i+j-1] = '\\'
            end
        elseif movement < 0
            movement = -movement
            for j in 1:movement
                board[j,i-j+1] = '/'
            end
        end
    end

    for i in 1:R; push!(ans,join(board[i,:],"")); end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        C = gi()
        B::VI = gis()
        ans = solve(C,B)
        for l in ans; print("$l\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

