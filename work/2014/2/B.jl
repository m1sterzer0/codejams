######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        A = [parse(Int64,x) for x in split(readline(infile))]
        ans = 0
        SA = sort(A)
        for s in SA
            idx = findall(x->x==s,A)[1]
            ans += min(idx-1,length(A)-idx)
            splice!(A,idx)
        end
        print("$ans\n")
    end
end

main()
