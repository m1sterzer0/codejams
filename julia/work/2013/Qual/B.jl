
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        B::Array{Int64,2} = fill(0,N,M)
        for i in 1:N
            B[i,:] = [parse(Int64,x) for x in split(readline(infile))]
        end
        ## Key observation is that we can't mow any row/col shorter than the tallest entry contained
        ## therein, and there is no incentive to mow the row/col taller than that.  Thus, we just
        ## set the mow height of each row/col above and then check to see that each square's final
        ## height is the minimum of the row mow height and the col mow height
        colheight = [maximum(B[:,j]) for j in 1:M]
        rowheight = [maximum(B[i,:]) for i in 1:N]
        good = true
        for i in 1:N
            for j in 1:M
                if B[i,j] != min(rowheight[i],colheight[j]); good = false; end
            end
        end
        ans = good ? "YES" : "NO"
        print("$ans\n")
    end
end

main()
