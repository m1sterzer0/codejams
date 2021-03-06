
function prework(n)
    nonspecial = fill(false,31)
    special = fill(false,31)

    for a in 0:10
        for b in 0:10
            for c in 0:10
                if max(a,b,c) < n; continue; end
                if max(a,b,c) - min(a,b,c) > 2; continue; end
                s = a+b+c
                if max(a,b,c) - min(a,b,c) > 1; special[s+1] = true; else nonspecial[s+1] = true; end
            end
        end
    end
    return (nonspecial,special)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        XX = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = popfirst!(XX)
        S = popfirst!(XX)
        p = popfirst!(XX)
        (nonspecial,special) = prework(p)
        ans = 0
        for x in XX
            if nonspecial[x+1]; ans += 1
            elseif special[x+1] && S > 0; ans += 1; S -= 1
            end
        end
        print("$ans\n")
    end
end

main()
