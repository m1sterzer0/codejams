######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ans = 0
        N,A,B = [parse(Int64,x) for x in split(readline(infile))]
        ## consider the function NN(d) which tells us the maximum number
        ## of foods we can resolve given d days.  Then we have
        ## * NN(0) = 1
        ## * for d < A, NN(d) = 1
        ## * for a <= d < B, NN(d) = N(d-A) + 1
        ## * for d >= B, NN(d) = NN(d-A) + NN(d-B)
        ## * Finally, NN(d) >= 2^(d/B)
        ##   -- For B <= 100, this means NN(50*100) >= NN(50*B) >= 2^50 >= 10^15
        ## This gives us a simple DP to solve the small
        nn::Vector{Int64} = fill(0,5001)
        for d in 0:5000
            if d < A; nn[d+1] = 1
            elseif d < B; nn[d+1] = 1 + nn[d-A+1]
            else; nn[d+1] = nn[d-A+1]+nn[d-B+1]
            end
            if d == 5000 || nn[d+1] >= N; print("$d\n"); break; end
        end
    end
end

main()
