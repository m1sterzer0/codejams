######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,M,K = [parse(Int64,x) for x in split(readline(infile))]
        if M<N; (N,M) = (M,N); end
        
        ## If the smallest dimension is <= 2, we can only enclose stones 
        ans = 0
        if N <= 2 || K <= 4; 
            ans = K
        elseif N == 3 && M == 3
            ans = K-1
        elseif N == 3 && M == 4
            ans = K < 8 ? K-1 : K-2
        elseif N == 3 && M == 5
            ans = K < 8 ? K-1 : K < 11 ? K-2 : K-3
        elseif N == 3 && M == 6
            ans = K < 8 ? K-1 : K < 11 ? K-2 : K < 14 ? K-3 : K-4
        elseif N == 4 && M == 4
            ans = K < 8 ? K-1 : K < 10 ? K-2 : K < 12 ? K-3 : K-4
        elseif N == 4 && M == 5
            ans = K < 8 ? K-1 : K < 10 ? K-2 : K < 12 ? K-3 : K < 14 ? K-4 : K < 16 ? K - 5 : K - 6
        end
        print("$ans\n")
    end
end

main()
