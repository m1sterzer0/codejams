######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B,K = [parse(Int64,x) for x in split(readline(infile))]
        ans::Int64 = 0
        for a in 0:A-1
            for b in 0:B-1
                if a & b < K; ans += 1; end
            end
        end
        print("$ans\n")
    end
end

main()
