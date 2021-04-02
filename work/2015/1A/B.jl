using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function served(M,m)
    ans = 0
    for x in M
        ans += (m + x -1) ÷ x
    end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")

        B,N = [parse(Int64,x) for x in split(readline(infile))]
        M = [parse(Int64,x) for x in split(readline(infile))]

        l,u,m = [0,10^17+1,0]

        while (u-l > 1) 
            m = (u+l) ÷ 2
            l,u = N <= served(M,m) ? [l,m] : [m,u]
        end
        x = served(M,l)
        #print(stderr,"DEBUG x=$x l=$l N=$N B=$B M=$M\n")
        for i in 1:B
            if l % M[i] == 0
                x += 1
                if x == N
                    print("$i\n")
                    break
                end
            end
        end
    end
end

main()
