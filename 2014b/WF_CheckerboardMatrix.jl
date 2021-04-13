
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

function solve(N::I,preboard::Array{Char,2})::String
    board::Array{Char,2} = copy(preboard)
    rowmatch::VI = fill(-1,2*N)
    colmatch::VI = fill(-1,2*N)
    antirow1::VC = [x == '0' ? '1' : '0' for x in board[1,:]]
    anticol1::VC = [x == '0' ? '1' : '0' for x in board[:,1]]
    imp::String = "IMPOSSIBLE"
    ## Do rows
    for i in 1:2*N
        if count(x->x=='1',board[i,:]) != N; return imp; end  ## Need N 1s in each row
        if count(x->x=='1',board[:,i]) != N; return imp; end  ## Need N 1s in each column
        if i == 1
            rowmatch[i] = colmatch[i] = 1
        else
            if     board[i,:] == board[1,:]; rowmatch[i] = 1 
            elseif board[i,:] == antirow1;   rowmatch[i] = 0
            else;  return imp ## Each row must either match row1 or anti row1
            end

            if     board[:,i] == board[:,1]; colmatch[i] = 1
            elseif board[:,i] == anticol1;   colmatch[i] = 0
            else;  return imp  ## Each row must either match col1 or anti col1
            end
        end

    end

    ## Check for remaining -1s in the match arrays, and we need exactly half of the rows/cols to match the first row/col.
    if sum(rowmatch) != N || sum(colmatch) != N; return imp; end
    rowswaps = min(sum(rowmatch[1:2:2N]),N-sum(rowmatch[1:2:2N]))
    colswaps = min(sum(colmatch[1:2:2N]),N-sum(colmatch[1:2:2N]))
    ans = rowswaps+colswaps
    return "$ans"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        board::Array{Char,2} = fill('.',2N,2N)
        for i in 1:2N; board[i,:] = [x for x in gs()]; end
        ans = solve(N,board)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
