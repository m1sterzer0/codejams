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
        if N <= 2 || K <= 4; print("$K\n"); continue; end
  
        best = K
        for base1 in 1:N  ## Assume base1 is the bigger base
            for base2 in 1:base1
                for ht in 3:M
                    if base1-base2 > 2*(ht-1); continue; end
                    s = base1+base2+(ht-2)*2
                    if s >= best; continue; end
                    k,w = base1+base2,base1
                    for i in 2:ht-1
                        w = min(base2+2*(ht-i),w+2,N)
                        k += w
                    end
                    if k >= K;
                        best = s;
                    end
                end
            end
        end
        print("$best\n")
    end
end

main()
