using Printf

######################################################################################################
### We consider each P separately
### a) P == 2
###    -- If we frontload all of the even numbered groups, they will all get fresh chocolate
###    -- For the odd numbered groups, every other one (rounded up) will get fresh chocolate
### b) P == 3
###    -- If we frontload all of the groups div by 3, they will get fresh chocolate.
###    -- If we "pair up" groups between the "remainder 1" and "reaminder 2" groups, one in each pair will get fresh chocolate.
###    -- Every 3rd group (rounded up) of the remainder will get fresh chocolate.
###
### c) P == 4
###    -- If we frontload all of the groups divisible by 4, they will get fresh chocolate.
###    -- If we "pair up" groups divisible by 2, then one of each pair will get fresh chocolate.
###    -- If we "pair up" elements from "remainder 1" and "remainder 3" groups, then one of each pair will get fresh chocolate.
###    After this, we are left with at most 1 '2' and up to "several 1's-3s"
###    -- If there is a 2 left and at least 2 others, we can make a trio where the first person will get fresh chocolate.
###    -- After that, ceil(#/4) get fresh chocolate.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        G = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        rem = zeros(Int64,P)
        for g in G
            x = g % P
            if x == 0; x = P; end
            rem[x] += 1
        end
        ans = rem[P]
        if P == 2
            ans += (rem[1] + 1) ÷ 2
        elseif P == 3
            p1 = min(rem[1],rem[2])
            ans += p1; rem[1] -= p1; rem[2] -= p1
            ans += (2 + max(rem[1],rem[2])) ÷ 3
        else  ## P == 4
            p1 = min(rem[1],rem[3])
            ans += p1; rem[1] -= p1; rem[3] -= p1
            p2 = rem[2] ÷ 2
            ans += p2; rem[2] -= 2 * p2
            remaining = rem[1] + rem[2] + rem[3]
            if rem[2] == 1 && remaining >= 3
                ans += 1; remaining -= 3
            end
            ans += (remaining + 3) ÷ 4
        end
        print("$ans\n")
    end
end

main()
