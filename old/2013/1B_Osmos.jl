
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        sort!(M)
        best,idx = N,1
        for i in 0:N
            if i > 0; A = 2*A-1; end
            while idx <= N && A > M[idx]; A += M[idx]; idx += 1; end
            best = min(best,i+(N+1-idx))
        end
        print("$best\n")
    end
end

main()

