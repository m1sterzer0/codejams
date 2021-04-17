
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

function findStartFinish(board::Array{Char,2})::Tuple{PI,PI}
    (R::I,C::I) = size(board)
    sqS::PI = (-1,-1)
    sqF::PI = (-1,-1)
    for i::I in 1:R
        for j::I in 1:C
            if     board[i,j] == 'S'; sqS = (i,j)
            elseif board[i,j] == 'F'; sqF = (i,j)
            end
        end
    end
    return (sqS,sqF)
end

function stringifyBoard(board::Array{Char,2})::VS
    ans::VS = []
    (R::I,C::I) = size(board)
    for i in 1:R; push!(ans,join(board[i,:],"")); end
    return ans
end

function constructBoard(board::Array{Char,2}, wallOrder::Vector{PI})::Array{Char,2}
    bb = copy(board)
    for (i,j) in wallOrder; bb[i,j] = '.'; end
    return bb
end

function doBfs(board::Array{Char,2},sqS::PI,sqF::PI,copyFlag::Bool)::I
    bb::Array{Char,2} = copyFlag ? copy(board) : board
    bb[sqS[1],sqS[2]] = 'X'
    bb[sqF[1],sqF[2]] = '.'
    (R::I,C::I) = size(bb)
    qq::Vector{TI} = []
    push!(qq,(0,sqS[1],sqS[2]))
    while !isempty(qq)
        (d::I,i::I,j::I) = popfirst!(qq)
        if (i,j) == sqF; return d; end
        ## Don't have to do bounds checking because border is guaranteed
        for c in [(i-1,j),(i+1,j),(i,j-1),(i,j+1)]
            if bb[c[1],c[2]] == '.'
                bb[c[1],c[2]] = 'X'
                push!(qq,(d+1,c[1],c[2]));
            end
        end
    end
    return -1
end

function processRemoval(borderCount::Array{Int8,2},board::Array{Char,2},
                        i::I,j::I,ready::Vector{PI}, corner::Vector{PI})
    borderCount[i,j] = -1
    board[i,j] = '.'
    for (ci,cj) in [(i,j-1),(i,j+1),(i-1,j),(i+1,j)] 
        if borderCount[ci,cj] > 0
            borderCount[ci,cj] -= 1
            edges::Int8 = borderCount[ci,cj]
            if edges >= 3;                                         continue
            elseif edges <= 1;                                     push!(ready,(ci,cj))
            elseif board[ci-1,cj] == '#' && board[ci+1,cj] == '#'; continue
            elseif board[ci,cj-1] == '#' && board[ci,cj+1] == '#'; continue
            else;                                                  push!(corner,(ci,cj))
            end
        end
    end
end

function checkCorner(board::Array{Char,2},i::I,j::I)
    for (c1,c2,c3,c4,c5,c6) in [(i+1,j,i,j+1,i+1,j+1),
                                (i+1,j,i,j-1,i+1,j-1),
                                (i-1,j,i,j+1,i-1,j+1),
                                (i-1,j,i,j-1,i-1,j-1)]
        if board[c1,c2] == '#' && board[c3,c4] == '#' && board[c5,c6] != '#'
            return false
        end
    end
    return true
end
function orderWalls(board::Array{Char,2})
    bb::Array{Char,2} = copy(board)
    R::I,C::I = size(board)
    borderCount::Array{Int8,2} = fill(Int8(-1),R,C)
    ready::VPI = []; corner::VPI = []; res::VPI = []
    for i::I in 2:R-1
        for j::I in 2:C-1
            if board[i,j] != '#'; continue; end
            edges::Int8 = ( (board[i-1,j] == '#' ? 1 : 0) +
                            (board[i+1,j] == '#' ? 1 : 0) +
                            (board[i,j+1] == '#' ? 1 : 0) +
                            (board[i,j-1] == '#' ? 1 : 0) )
            borderCount[i,j] = edges
            if edges >= 3;                                       continue
            elseif edges <= 1;                                   push!(ready,(i,j))
            elseif board[i-1,j] == '#' && board[i+1,j] == '#'; continue
            elseif board[i,j-1] == '#' && board[i,j+1] == '#'; continue
            else;                                                push!(corner,(i,j))
            end
        end
    end
    while !isempty(ready) || !isempty(corner)
        while !isempty(ready)
            (i,j) = pop!(ready)
            if borderCount[i,j] == -1; continue; end
            push!(res,(i,j))
            processRemoval(borderCount,bb,i,j,ready,corner)
        end
        foundCorner = false
        for _i in 1:length(corner)
            (i,j) = pop!(corner)
            if borderCount[i,j] != 2
                continue  ## Must have been removed already
            elseif !checkCorner(bb,i,j)
                pushfirst!(corner,(i,j))
                continue
            end
            foundCorner = true
            push!(res,(i,j))
            processRemoval(borderCount,bb,i,j,ready,corner)
            break
        end
        if !foundCorner; break; end
    end
    return res
end

function solve(R::I,C::I,D::I,board::Array{Char,2})::VS
    (sqS,sqF) = findStartFinish(board)
    curDist = doBfs(board,sqS,sqF,true)
    bestPossible = abs(sqS[1]-sqF[1]) + abs(sqS[2]-sqF[2]) 
    ## Couple of special cases
    if D == curDist; return vcat(["POSSIBLE"],stringifyBoard(board)); end
    if curDist < D || bestPossible > D; return ["IMPOSSIBLE"]; end
    if (curDist - D) % 2 != 0; return ["IMPOSSIBLE"]; end  ## Wrong Parity
    wallOrder = orderWalls(board)
    lb,ub = 0,length(wallOrder)
    done = false
    while (!done && ub-lb > 1)
        mid = (ub+lb) ÷ 2
        bb = constructBoard(board,wallOrder[1:mid])
        d = doBfs(bb,sqS,sqF,false)
        if d == D
            bb = constructBoard(board,wallOrder[1:mid])
            return vcat(["POSSIBLE"],stringifyBoard(bb))
        end
        (lb,ub) = d < D ? (lb,mid) : (mid,ub)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,D = gis()
        board::Array{Char,2} = fill('.',R,C)
        for i in 1:R; board[i,:] = [x for x in gs()]; end
        ans = solve(R,C,D,board)
        for s in ans; print("$s\n"); end
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

