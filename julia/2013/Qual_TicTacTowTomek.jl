
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        board = fill('.',4,4)
        for i in 1:4
            board[i,:] = [x for x in rstrip(readline(infile))]
        end
        readline(infile) ## Throwaway spacer line

        xwin,owin = false,false
        gamedone = count(x->x in ".", board) == 0
        diag1 = [board[1,1],board[2,2],board[3,3],board[4,4]]
        diag2 = [board[4,1],board[3,2],board[2,3],board[1,4]]
        for line in [board[1,:],board[2,:],board[3,:],board[4,:],board[:,1],board[:,2],board[:,3],board[:,4],diag1,diag2]
            if count(x->x in "XT",line)==4; xwin = true; end 
            if count(x->x in "OT",line)==4; owin = true; end
        end

        if     xwin;     print("X won\n")
        elseif owin;     print("O won\n")
        elseif gamedone; print("Draw\n")
        else;            print("Game has not completed\n")
        end
    end
end

main()

