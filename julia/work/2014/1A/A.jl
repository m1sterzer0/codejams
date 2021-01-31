######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = [parse(Int64,x) for x in split(readline(infile))]
        outlets = [parse(Int64,x,base=2) for x in split(readline(infile))]
        shota   = [parse(Int64,x,base=2) for x in split(readline(infile))]
        answers = Set(outlets)
        best = 60
        for o in outlets
            for s in shota
                xorstr = o ⊻ s
                done = true
                for ss in shota
                    if ss ⊻ xorstr ∉ answers; done = false; break; end
                end
                if done
                    trial = 0
                    for i in 0:39
                        if xorstr & (1 << i) > 0; trial += 1; end
                    end
                    best = min(best,trial)
                end
            end
        end
        if best == 60
            print("NOT POSSIBLE\n")
        else
            print("$best\n")
        end
    end
end

main()
