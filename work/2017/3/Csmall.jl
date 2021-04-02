using Printf

######################################################################################################
### For the small, the key observation is that each of the camps have two possibilities for the 
### order in which we take the camps, so we just try them all and report the best one.
######################################################################################################

function simulate(cfg,C,E,L,D)
    big = typemax(Int64)
    visits = fill(0,C)
    d,h,c = 0,0,1
    for i in 1:2C
        if visits[c] >= 2; return big; end
        visits[c] += 1
        hidx = (2*c - 2) + ((1 << (c-1) & cfg == 0) ? visits[c] : 3 - visits[c])  ## maps adder to 1/2 or 2/1 depending on the config
        if L[hidx] < h; d += 1; end  ## Have to wait an extra day at the camp
        h = L[hidx] + D[hidx]
        d += h ÷ 24
        h = h % 24
        c = E[hidx]
    end
    return c == 1 ? 24*d + h : big
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        C = parse(Int64,rstrip(readline(infile)))
        E = fill(0,2C)
        L = fill(0,2C)
        D = fill(0,2C)
        for i in 1:2C
            E[i],L[i],D[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        best = typemax(Int64)
        for i in 1:2^C
            res = simulate(i-1,C,E,L,D)
            best = min(best,res)
        end
        print("$best\n")
    end
end

main()
