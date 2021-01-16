using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        d = parse(Int64,readline(infile))
        p = [parse(Int64,x) for x in split(readline(infile))]
        best = 1000
        for batchsize in 1:1000
            if batchsize > best; break; end
            moves = batchsize
            for pp in p
                moves += (pp-1) ÷ batchsize
            end
            best = min(best,moves)
        end
        print("$best\n")
    end
end

main()
