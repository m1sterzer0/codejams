using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        digString = readline(infile)
        N = length(digString)
        C::Vector{Int8} = [parse(Int8,x) for x in digString]
        dp = zeros(Int32,N,10)
        for i in 1:N; dp[i,1] = i; end

        ## Get array of indices for each cost
        carr::Vector{Vector{Int32}} = []
        for i in 1:9
            cc::Vector{Int32} = []
            for j in 1:N
                if C[j] == i; push!(cc,j); end
            end
            push!(carr,cc)
        end
        cidxarr = zeros(Int32,9)

        ##Max cost is 20 compares * cost of 9.  Round up to 200 to be safe
        for c in 1:200
            ci = (c % 10) + 1
            cj = ((c-1) % 10) + 1
            for i in 1:N; dp[i,ci] = dp[i,cj]; end
            for d in 1:9
                if c-d < 0; continue; end
                mycarr = carr[d]
                lmycarr = length(mycarr)
                myidx = 0
                refcol = ((c-d) % 10) + 1
                for i in 1:N
                    while (myidx+1 <= lmycarr && mycarr[myidx+1] <= dp[i,refcol])
                        myidx += 1
                    end
                    if myidx == 0; continue; end
                    newcand = mycarr[myidx] == N ? N+1 : dp[mycarr[myidx]+1,refcol]
                    dp[i,ci] = max(dp[i,ci],newcand)
                end
            end
            if dp[1,ci] == N+1; print("$c\n"); break; end
        end
    end
end

main()
