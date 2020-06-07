using Printf

######################################################################################################
### Note our first potential move (at say the left end) is fixed depending on pancake 1.  After that
### if fixed, our next potential move is fixed by pancake 2.  This continues all the way through pancake
### N-K+1.  The limits are small enough that we can be sloppy and just simulate the process directly
### and check the last K-1 pancakes and see if they need to be flipped.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S,K = split(rstrip(readline(infile)))
        N = length(S)
        K = parse(Int64,K)
        row = [x == '+' ? true : false for x in S]
        flipcnt = 0
        for i in 1:N-K+1
            if row[i]; continue; end
            flipcnt += 1
            row[i:i+K-1] = .!row[i:i+K-1]
        end
        res = reduce(&,row[N-K+2:N])
        print( res ? "$flipcnt\n" : "IMPOSSIBLE\n" )
    end
end

main()
