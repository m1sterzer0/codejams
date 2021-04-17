using Printf

######################################################################################################
### 1) As long as we don't create "shortcuts" through the graph and instead just vaguely "erode away"
###    corners/stubs, the most a block removal will do is to shorten the best path by 2 (it could also
###    leave the shortest path untouched).
###
### 2) This leads to the following algorithm proposal
###    * Run Bfs to get the current shortest path length (and check IMPOSSIBLE)
###    * Order all of the walls in a legal removal order (more details below)
###    * Run a binary search on the removal order to find one with the right path length
###
### 3) In ordering the walls, we make 2 observations
###    --- We can always remove a wall with 3-4 exposed sides
###    --- We can "most" of the time remove a corner (2 adjacent exposed sides), but we have to
###        check the diagonal rule.  If we fail the diagonal check, we save it for later.
###    To do this, we maintain 2 queues -- one for the blocks with 3 exposed sides, and then one 
###    for the corners.  For each step, we prioritize the 3 exposed sides. 
######################################################################################################

function findStartFinish(board::Array{Char,2})
    (R,C) = size(board)
    sqS = (-1,-1)
    sqF = (-1,-1)
    for i in 1:R
        for j in 1:C
            if     board[i,j] == 'S'; sqS = (i,j)
            elseif board[i,j] == 'F'; sqF = (i,j)
            end
        end
    end
    return (sqS,sqF)
end

function printBoard(board::Array{Char,2})
    (R,C) = size(board)
    for i in 1:R
        ss = join(board[i,:],"")
        print("$ss\n")
    end
end

function constructBoard(board::Array{Char,2}, wallOrder::AbstractVector{Tuple{Int64,Int64}})
    bb = copy(board)
    for (i,j) in wallOrder; bb[i,j] = '.'; end
    return bb
end

function doBfs(board::Array{Char,2},sqS::Tuple{Int64,Int64},sqF::Tuple{Int64,Int64},copyFlag::Bool)::Int64
    bb = copyFlag ? copy(board) : board
    bb[sqS[1],sqS[2]] = 'X'
    bb[sqF[1],sqF[2]] = '.'
    (R,C) = size(bb)
    qq = Vector{Tuple{Int64,Int64,Int64}}()
    push!(qq,(0,sqS[1],sqS[2]))
    while !isempty(qq)
        (d,i,j) = popfirst!(qq)
        if (i,j) == sqF; return d; end
        #println("DEBUG: d:$d i:$i j:$j")
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

function processRemoval(borderCount::Array{Int8,2},board::Array{Char,2},i::Int64,j::Int64,ready::Vector{Tuple{Int64,Int64}}, corner::Vector{Tuple{Int64,Int64}})
    borderCount[i,j] = -1
    board[i,j] = '.'
    for (ci,cj) in [(i,j-1),(i,j+1),(i-1,j),(i+1,j)] 
        if borderCount[ci,cj] > 0
            borderCount[ci,cj] -= 1
            edges = borderCount[ci,cj]
            if edges >= 3;                                         continue
            elseif edges <= 1;                                     push!(ready,(ci,cj))
            elseif board[ci-1,cj] == '#' && board[ci+1,cj] == '#'; continue
            elseif board[ci,cj-1] == '#' && board[ci,cj+1] == '#'; continue
            else;                                                  push!(corner,(ci,cj))
            end
        end
    end
end

function checkCorner(board::Array{Char,2},i::Int64,j::Int64)
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
    bb = copy(board)
    R,C = size(board)
    borderCount = fill(Int8(-1),R,C)
    ready  = Vector{Tuple{Int64,Int64}}()
    corner = Vector{Tuple{Int64,Int64}}()
    res = Vector{Tuple{Int64,Int64}}()
    for i in 2:R-1
        for j in 2:C-1
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

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        board = fill('.',R,C)
        for i in 1:R; board[i,:] = [x for x in rstrip(readline(infile))]; end
        (sqS,sqF) = findStartFinish(board)
        curDist = doBfs(board,sqS,sqF,true)
        bestPossible = abs(sqS[1]-sqF[1]) + abs(sqS[2]-sqF[2]) 
        ## Couple of special cases
        if D == curDist
            print("POSSIBLE\n")
            printBoard(board)
        elseif curDist < D || bestPossible > D
            print("IMPOSSIBLE\n")
        elseif (curDist - D) % 2 != 0  ## Wrong parity
            print("IMPOSSIBLE\n")
        else
            wallOrder = orderWalls(board)
            lb,ub = 0,length(wallOrder)
            done = false
            while (!done && ub-lb > 1)
                mid = (ub+lb) ÷ 2
                bb = constructBoard(board,wallOrder[1:mid])
                d = doBfs(bb,sqS,sqF,false)
                if d == D
                    print("POSSIBLE\n")
                    bb = constructBoard(board,wallOrder[1:mid])
                    printBoard(bb)
                    done = true
                else
                    (lb,ub) = d < D ? (lb,mid) : (mid,ub)
                end
            end
            if !done; print("ERROR\n"); end
        end
    end
end
        
main()