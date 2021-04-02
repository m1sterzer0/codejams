using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### If N==0, we just dump out INSOMNIA
### For any other number, we just simulate the process
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        if N == 0
            print("INSOMNIA\n")
            continue
        end
        sb = Set(0:9)
        mult = 1
        while true
            digits = [parse(Int64,x) for x in string(N*mult)]
            for d in digits
                if d in sb; pop!(sb,d); end
            end
            if length(sb) == 0; break; end
            mult += 1
        end
        print("$(mult*N)\n")
    end
end

main()
