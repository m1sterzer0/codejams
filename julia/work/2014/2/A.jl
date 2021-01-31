######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,X = [parse(Int64,x) for x in split(readline(infile))]
        S = [parse(Int64,x) for x in split(readline(infile))]
        sort!(S)
        discs,filesLeft,i,j = 0,N,1,N
        i,j = 1,N
        while(j>i)
            if S[i]+S[j] <= X
                filesLeft -= 2
                discs += 1
                i += 1
            end
            j -= 1
        end
        discs += filesLeft
        print("$discs\n")
    end
end

main()
