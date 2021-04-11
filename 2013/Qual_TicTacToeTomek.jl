
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

function solve(board::Array{Char,2})::String
    xwin::Bool,owin::Bool = false,false
    gamedone = count(x->x == '.', board) == 0
    diag1 = [board[1,1],board[2,2],board[3,3],board[4,4]]
    diag2 = [board[4,1],board[3,2],board[2,3],board[1,4]]
    for line in [board[1,:],board[2,:],board[3,:],board[4,:],board[:,1],board[:,2],board[:,3],board[:,4],diag1,diag2]
        if count(x->x in "XT",line)==4; xwin = true; end 
        if count(x->x in "OT",line)==4; owin = true; end
    end
    return xwin ? "X won" : owin ? "O won" : gamedone ? "Draw" : "Game has not completed"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        board::Array{Char,2} = fill('.',4,4)
        for i in 1:4
            board[i,:] = [x for x in gs()]
        end
        gs() ## Throwaway spacer line
        ans = solve(board)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
