function could(m::Int64, N::Int64, P::Int64)
    numbetter = m
    numworse = 2^N-m-1
    for r in N-1:-1:0
        if (P-1) & (1<<r) == 0 ## This is win
            if numworse == 0; return false; end
            numworse = (numworse-1)÷2
        end
    end
    return true
end

function guaranteed(m::Int64, N::Int64, P::Int64)
    numbetter = m
    numworse = 2^N-m-1
    for r in N-1:-1:0
        if (P-1) & (1<<r) == 0 ## This is win
            if numbetter > 0; return false; end
        else ## This is a loss
            numbetter -= 1
            numbetter ÷= 2
        end
    end
    return true
end



function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        ## Search for the best we can get. Binary search for the answer
        ## Easiest to get wins at the beginning  -- check powers of 2 for prizes
        ## Need to see how few wins we need to get a prize
        PP = 2^N
        while PP > P; PP = PP ÷ 2; end
        l,u = 0,2^N-1
        while u-l > 1
            m = (u+l)>>1
            if could(m,N,PP); l=m; else; u=m; end
        end
        z = (P == 2^N ? 2^N-1 : l)

        l,u = 0,2^N-1
        while u-l > 1
            m = (u+l)>>1
            if guaranteed(m,N,P); l=m; else; u=m; end
        end
        y = (P == 2^N ? 2^N-1 : l)

        print("$y $z\n")
    end
end

main()
