using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        N = parse(Int64,readline(infile))
        M = [parse(Int64,x) for x in split(readline(infile))]

        maxSlope = 0
        minEaten = 0
        for i in 1:(N-1)
            maxSlope = max(maxSlope,M[i]-M[i+1])
            minEaten += max(0,M[i]-M[i+1])
        end 
        constRateEaten = 0
        for i in 1:(N-1)
            constRateEaten += min(maxSlope,M[i])
        end
        print("$minEaten $constRateEaten\n")
    end
end

main()
