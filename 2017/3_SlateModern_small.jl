using Printf

######################################################################################################
### a) One key observation is that every square x is limited by min(B(vi) + D(vi,x)) where D is the
###    Manhattan distance.  This is a necessary condition.
### b) It isn't too hard to see that if all of the fixed values are consistent with this minimum
###    (i.e. they are limited by this brightness value), then the necessary condition is also a
###    sufficient condition, for the condition guarantees that adjacent squared cannot differ by
###    more than D.
### c) For the small, we merely need to check the pairs to see if they are compatible, and then we
###    construct the array of distances.  O(R*C*N)
######################################################################################################

######################################################################################################
### BEGIN MODULAR ARITHMETIC CODE
######################################################################################################

function modadd(a::Int64,b::Int64,m::Int64)
    s = a + b
    return s > m ? s-m : s
end

######################################################################################################
### END MODULAR ARITHMETIC CODE
######################################################################################################

MOD = 1000000007
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,N,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        RR = fill(zero(Int64),N)
        CC = fill(zero(Int64),N)
        BB = fill(zero(Int64),N)
        for i in 1:N
            RR[i],CC[i],BB[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        good = true
        for i in 1:N-1
            for j in i:N
                if abs(BB[i]-BB[j]) > D * (abs(RR[i]-RR[j]) + abs(CC[i]-CC[j]))
                    good = false
                end
            end
        end
        if !good; print("IMPOSSIBLE\n"); continue; end;
        ansarr = fill(typemax(Int64),R,C)
        for idx in 1:N
            ansarrrow = D .* [abs(RR[idx] - i) for i in 1:R]
            ansarrcol = D .* [abs(CC[idx] - j) for j in 1:C]
            x = repeat(ansarrcol',R,1) .+ repeat(ansarrrow,1,C) .+ BB[idx]
            ansarr = min.(ansarr,x)
        end
        ans = 0
        for i in 1:R
            for j in 1:C
                ans = (ans + ansarr[i,j]) % 1_000_000_007
            end
        end
        print("$ans\n")
    end
end

main()
