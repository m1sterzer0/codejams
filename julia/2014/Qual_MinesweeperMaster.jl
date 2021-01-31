######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C,M = [parse(Int64,x) for x in split(readline(infile))]
        F = R*C-M
        r = min(R,C)
        c = max(R,C)
        board = fill('.',r,c)
        board[1,1] = 'c'
        if F == 1
            board = fill('*',r,c)
            board[1,1] = 'c'
        elseif r == 1
            ## We can always make 1 work
            for i in F+1:c; board[1,i] = '*'; end
        elseif r == 2
            ## We need an even number of mines
            ## Also, we can't make F==2 work
            if F==2 || M%2 == 1; print("Impossible\n"); continue; end
            fc = F ÷ 2
            for i in 1:2
                for j in fc+1:c
                    board[i,j] = '*'
                end
            end
        else
            if F in [2,3,5,7]; print("Impossible\n"); continue; end
            if F > 2*c+1
                ## Here we can just fill them in from bottom to top, but have to watch out for the singleton left
                m,i = M,r
                while(m > 0)
                    if m >= c
                        board[i,:] = ['*' for xx in 1:c]
                        m -= c
                        i -= 1
                    elseif m == c-1
                        board[i,3:c] = ['*' for xx in 1:c-2]
                        i -= 1
                        m -= (c-2)
                    else
                        board[i,c-m+1:c] = ['*' for xx in 1:m]
                        m = 0
                    end
                end
            else
                for i in 4:r; board[i,:] = ['*' for xx in 1:c]; end
                left = 3*c
                j = c
                while (left > F)
                    if left >= F+3
                        board[1:3,j] = ['*','*','*']
                        left -= 3
                        j -= 1
                    else
                        board[3,j] = '*'
                        j -= 1
                        left -= 1
                    end
                end
            end
        end

        if R > C
            for i in 1:c
                s = join(board[:,i])
                print("$s\n")
            end
        else 
            for i in 1:r
                s = join(board[i,:])
                print("$s\n")
            end
        end
    end
end

main()
