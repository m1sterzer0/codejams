
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S,N = [x for x in split(rstrip(readline(infile)))]
        ls = length(S)
        n = parse(Int64,N)
        strends = []
        streak = 0
        for (i,c) in enumerate(S)
            if c in "aeiou"
                streak = 0
            else
                streak += 1
                if streak >= n
                    push!(strends,i)
                end
            end
        end
        strbeginnings = [x-(n-1) for x in strends]
        if length(strbeginnings) == 0; print("0\n"); continue; end
        ptr = 1
        ans = 0
        for i in 1:strbeginnings[end]
            if strbeginnings[ptr] < i; ptr += 1; end
            strend = strends[ptr]
            ans += (ls-strend+1)
        end
        print("$ans\n")
    end
end

main()
