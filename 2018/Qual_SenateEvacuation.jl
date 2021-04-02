######################################################################################################
### The key observation is that the proposed algorithm sorts the even indexed entries and the odd
### indexed entries separately, so we just do the same and then check the result
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        V = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        A = V[1:2:end]
        B = V[2:2:end]
        sort!(A)
        sort!(B)
        result = fill(0,N)
        result[1:2:end] = A
        result[2:2:end] = B
        sidx = -1
        for i in 1:N-1
            if result[i] > result[i+1]; sidx = i-1; break; end
        end
        if sidx < 0; print("OK\n")
        else; print("$sidx\n")
        end
    end
end

main()
