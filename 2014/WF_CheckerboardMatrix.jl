######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        board::Array{Int16,2} = fill(0,2*N,2*N)
        for i in 1:2N
            board[i,:] = [parse(Int16,x) for x in readline(infile)]
        end

        rowmatch = fill(-1,2*N)
        colmatch = fill(-1,2*N)
        antirow1::Vector{Int16} = [1-x for x in board[1,:]]
        anticol1::Vector{Int16} = [1-x for x in board[:,1]]

        ## Do rows
        for i in 1:2*N
            if sum(board[i,:]) != N; break; end  ## Need N 1s in each row
            if sum(board[:,i]) != N; break; end  ## Need N 1s in each column
            if i == 1
                rowmatch[i] = colmatch[i] = 1
            else
                if     board[i,:] == board[1,:]; rowmatch[i] = 1 
                elseif board[i,:] == antirow1;   rowmatch[i] = 0
                else;  break  ## Each row must either match row1 or anti row1
                end

                if     board[:,i] == board[:,1]; colmatch[i] = 1
                elseif board[:,i] == anticol1;   colmatch[i] = 0
                else;  break  ## Each row must either match col1 or anti col1
                end
            end

        end

        ## Check for remaining -1s in the match arrays, and we need exactly half of the rows/cols to match the first row/col.
        if -1 in rowmatch || -1 in colmatch || sum(rowmatch) != N || sum(colmatch) != N 
            print("IMPOSSIBLE\n");
            continue
        end
        rowswaps = min(sum(rowmatch[1:2:2N]),N-sum(rowmatch[1:2:2N]))
        colswaps = min(sum(colmatch[1:2:2N]),N-sum(colmatch[1:2:2N]))
        ans = rowswaps+colswaps
        print("$ans\n")
    end
end
main()
