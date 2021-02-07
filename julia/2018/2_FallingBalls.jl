######################################################################################################
### * We notice that since the first and last columns must be clear, we must have that both
###   B[1] and B[C] are > 0, otherwise we are IMPOSSIBLE
### * Otherwise, we can just figure out where we need each ball to land and build a diagonal ramp
###   to get it there.  Note that the path of the balls will never cross.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C = parse(Int64,rstrip(readline(infile)))
        B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        if B[1] == 0 || B[C] == 0; print("IMPOSSIBLE\n"); continue; end
        
        ## Generate the target column for each of the balls
        nxtball = 1
        target = fill(0,C)
        for i in 1:C
            for j in 1:B[i]
                target[nxtball] = i; nxtball+=1
            end
        end

        ## figure out how many rows we need
        R = 1 + maximum(abs(target[x]-x) for x in 1:C)
        print("$R\n")

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

        for i in 1:R
            bs = join(board[i,:],"")
            print("$bs\n")
        end
    end
end

main()
