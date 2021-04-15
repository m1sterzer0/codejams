######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C,D,V = [parse(Int64,x) for x in split(readline(infile))]
        Darr = [parse(Int64,x) for x in split(readline(infile))]
        dptr = 1
        addedDenoms = 0
        canMakeCap = 0
        while(canMakeCap < V)
            if dptr <= length(Darr) && Darr[dptr] <= canMakeCap + 1
                canMakeCap += C * Darr[dptr]
                dptr += 1
            else
                canMakeCap += C * (canMakeCap + 1)
                addedDenoms += 1
            end
        end
        print("$addedDenoms\n")
    end
end

main()
    
