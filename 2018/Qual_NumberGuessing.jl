######################################################################################################
### Very straightforward.  We simply prioritize the rightmost shots, since they are worth the most.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        x,P = split(rstrip(readline(infile)))
        D = parse(Int64,x)
        scnt = count(x -> x == 'S', P)
        if scnt > D; print("IMPOSSIBLE\n"); continue; end  ## More shots than allowed damage
        totdmg,dmgval,didx = 0,1,1
        svals = fill(0,32)
        for c in P
            if c == 'S'; totdmg += dmgval; svals[didx] += 1
            else       ; dmgval *= 2; didx += 1
            end 
        end
        swaps = 0
        while (D < totdmg)
            if svals[didx] == 0; didx -= 1; dmgval ÷= 2
            else svals[didx] -=1; svals[didx-1] += 1; totdmg -= dmgval ÷ 2; swaps += 1
            end
        end
        print("$swaps\n")
    end
end

main()
