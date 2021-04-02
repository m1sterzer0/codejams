######################################################################################################
### A couple of key observations
### * The stack weight grows geometrically (at least by 7/6, and by quite a bit more than that early),
###   so the stack height limit is actually reasonably small (i.e. < 150).
### * We build a simple DP where we calculate the minimum weight of a stack of size i using using
###   elements in the prefix of the list.  This is still a O(150N) DP, but it seems to be the best we
###   can do.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N::Int64            = parse(Int64,rstrip(readline(infile)))
        W::Vector{Int64}   = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        W6::Vector{Int64}  = [6*x for x in W]
        dp1::Vector{Int64} = fill(0,N)
        dp2::Vector{Int64} = fill(0,N)
        big::Int64 = 10^18
        for i in 1:2000
            (dp1,dp2) = (dp2,dp1)
            if i > N; print("$N\n"); break; end
            dp2[1] = i == 1 ? W[1] : big
            #print("DEBUG N:$N W:$W dp1:$dp1 dp2:$dp2\n")
            for j in 2:N
                dp2[j] = min(dp2[j-1], W6[j] >= dp1[j-1] ? dp1[j-1] + W[j] : big)
            end
            if dp2[N] >= big; print("$(i-1)\n"); break; end
        end
    end
end

main()
