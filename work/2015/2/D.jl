######################################################################################################
### After a bit of reasoning, we see that there are only 5 possible patterns that each
### take up a set of full rows that are possible, with some additional stacking restricitons
### -- 2 rows of '3's
### -- 1 row of '2's 
### -- Alternating 2x2 squares of 2s with a vertical 1's "domino"
###    (need C multiple of 3)
###
###     221221221221221221221221...
###     221221221221221221221221...
###
### -- A 2 row pattern of a 'snake' of 2s around staggered horizontal dominoes
###    (need C multiple of 6)
###
###    222112222112222112222112...
###    112222112222112222112222..
###
### -- A 3 row pattern of a 'snake' of 2s around staggered vertical dominoes
###    (need C multiple of 4)
###
###     2122212221222122212221222122...
###     2121212121212121212121212121...
###     2221222122212221222122212221...
###
###  Furthermore, the patterns with 2's cannot border each other
######################################################################################################

function modadd(a::Int64,b::Int64)::Int64
    s::Int64 = a + b; return s >= 1000000007 ? s-1000000007 : s
end

function modsub(a::Int64,b::Int64)::Int64
    s::Int64 = a - b; return s < 0 ? s + 1000000007 : s
end

function modmul(a::Int64,b::Int64)::Int64
    return (a*b) % 1000000007
end

function modinv(a::Int64)::Int64
    ans::Int64 = 1
    factor::Int64 = a
    e::Int64 = 1000000007-2
    while (e > 0)
        if e & 1 ≠ 0; ans = modmul(ans,factor); end
        factor = modmul(factor,factor)
        e = e >> 1
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = [parse(Int64,x) for x in split(readline(infile))]
        dp = fill(0,R,12,3)

        ## Do the starter patterns -- deal with rotations at the end
        dp[1,1,2] = 1 ## Row of 2s
        dp[2,1,3] = 1 ## 2 Rows of 3s
        if C % 3 == 0; dp[2,3,2] = 3; end
        if C % 6 == 0; dp[2,6,2] = 6; end
        if C % 4 == 0 && R>=3; dp[3,4,2] = 4; end

        lcm3 = [lcm(3,x) for x in 1:12]
        lcm4 = [lcm(4,x) for x in 1:12]
        lcm6 = [lcm(6,x) for x in 1:12]

        for i in 1:R-1
            for rpt in [1,3,4,6,12]
                if dp[i,rpt,2] > 0 && i+2 <= R
                    dp[i+2,rpt,3] = modadd(dp[i+2,rpt,3],dp[i,rpt,2])
                end

                if dp[i,rpt,3] == 0; continue; end

                dp[i+1,rpt,2] = modadd(dp[i+1,rpt,2],dp[i,rpt,3])

                if C % 3 == 0 && i+2 <= R
                    dp[i+2,lcm3[rpt],2] = modadd(modmul(3,dp[i,rpt,3]),dp[i+2,lcm3[rpt],2])
                end

                if C % 6 == 0 && i+2 <= R
                    dp[i+2,lcm6[rpt],2] = modadd(modmul(6,dp[i,rpt,3]),dp[i+2,lcm6[rpt],2])
                end

                if C % 4 == 0 && i+3 <= R
                    dp[i+3,lcm4[rpt],2] = modadd(modmul(4,dp[i,rpt,3]),dp[i+3,lcm4[rpt],2])
                end
            end
        end

        ans = 0
        for rpt in [1,3,4,6,12]
            inv = modinv(rpt)
            for e in [2,3]
                ans = modadd(ans,modmul(inv,dp[R,rpt,e]))
            end
        end
        print("$ans\n")
    end
end

main()

