######################################################################################################
### We do a binary search on the time and figure out whether that work.
######################################################################################################

function check(t,R,B,C,M,S,P)
    bitsPerCashier = [max(0,min(M[i],(t-P[i])÷S[i])) for i in 1:C]
    reverse!(sort!(bitsPerCashier))
    b = sum(bitsPerCashier[1:R])  ## bitsPerCashier capped at 10^9, so the sum is capped at 10^12
    return b >= B
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,B,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        M,S,P = fill(0,C),fill(0,C),fill(0,C)
        for i in 1:C
            M[i],S[i],P[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        (l,u) = (0,typemax(Int64))
        while u-l > 1
            m = (u+l) ÷ 2
            (l,u) = check(m,R,B,C,M,S,P) ? (l,m) : (m,u)
        end
        print("$u\n")
    end
end

main()
