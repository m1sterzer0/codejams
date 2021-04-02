using Printf

######################################################################################################
### For the small, we can simply figure out how many cookies I can cut before I run out of margin,
### and then I can rotate the cuts to the maximum and see on which side of P that lands.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        W = fill(0,N)
        H = fill(0,N)
        for i in 1:N
            W[i],H[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        ## Use Integer math to figure out how many 
        basePerim = 2*W[1] + 2*H[1]
        minAdder = 2*min(W[1],H[1])
        maxAdder = 2*sqrt(W[1]*W[1]+H[1]*H[1])
        ncuts = min(N,(P - N * basePerim) ÷ minAdder)
        minPerim = Float64(basePerim * N + minAdder * ncuts)
        maxPerim = Float64(basePerim * N + maxAdder * ncuts)
        if P <= maxPerim; @printf("%.10f\n",Float64(P))
        else            ; @printf("%.10f\n",maxPerim)
        end
    end
end

main()