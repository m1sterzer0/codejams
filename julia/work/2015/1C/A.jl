######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,W = [parse(Int64,x) for x in split(readline(infile))]
        ans = (C % W == 0) ? R * (C ÷ W) + (W-1) : R * (C ÷ W) + W
        print("$ans\n")
    end
end

main()
    
