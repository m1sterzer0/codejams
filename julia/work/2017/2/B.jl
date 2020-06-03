using Printf

######################################################################################################
### We first figure out how many roller coaster rides we must have, and after that, we figure out
### how to accomplish that with the fewest promotions.
###
### It seems there for sure three things that can limit the number of rides that we must make
###    a) The number of tickets sold to any one person.
###    b) The number of tickets solt for the first seat
###    c) The total number of tickets sold for the "first N" seats
### If we can choose the minimum number of rides that satisfies all three of these constraints, then
### we are good.
###
### After we have these numbers, we simply fill our rides from back to front, and we promote only as
### much as needed.  This will count the promotions, and serve as a "check" on whether our math
### was right for the first part.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,C,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        P,B = zeros(Int64,M),zeros(Int64,M)
        for i in 1:M
            P[i],B[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))] 
        end

        ## Constraint 1
        pc = zeros(Int64,C)
        for i in 1:M; pc[B[i]] += 1; end
        rides = maximum(pc)

        ## Constraints 2 & 3
        bc = zeros(Int64,N)
        for i in 1:M; bc[P[i]] += 1; end
        s = 0
        for i in 1:N
            s += bc[i]
            rides = max(rides,(s+i-1) ÷ i)
        end

        ## Figure out how many promotions we need
        promotions = 0
        for i in N:-1:1
            promotions += max(0,bc[i]-rides)
        end

        print("$rides $promotions\n")
    end
end

main()
