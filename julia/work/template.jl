######################################################################################################
### 
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ##N = parse(Int64,rstrip(readline(infile)))
        ##S[1,:] = [x for x in rstrip(readline(infile))]
        ans = 0
        print("$ans\n")
    end
end

main()
