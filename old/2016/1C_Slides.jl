using Printf

######################################################################################################
### Simple strategy
### 1) We have a directed acyclic graph (if there are cycles, then there are infinite ways)
### 2) Directed acyclic graphs correspond to a topological sorting, so we can assume that 
###    all paths are in order from node 1 to node B
### 3) If we maximally connect the directed graph, we notice that we get powers of 2 (namely 2^(B-2))
###    B = 2,  #paths =  1
###    B = 3,  #paths =  1 + 1
###    B = 4,  #paths =  2 + 1 + 1
###    B = 5,  #paths =  4 + 2 + 1 + 1
###    B = 6,  #paths =  8 + 4 + 2 + 1 + 1
###    B = 7,  #paths = 16 + 8 + 4 + 2 + 1 + 1
### 4) We can easily pick any number less than this by first maximally connecting the nodes from 2:B and then
###    carefully choosing which which connections we make from node 1 using a "binary representation" of M to guide
###    us.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        B,M = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        if M > 2^(B-2)
            print("IMPOSSIBLE\n")
            continue
        end

        print("POSSIBLE\n")
        g = [i > 1 && i < B && j > i ? 1 : 0 for i in 1:B,j in 1:B]
        if M == 2^(B-2)
            g[1,:] = [j>1 ? 1 : 0 for j in 1:B]
        else
            ## Inner B-2 elements of row 1 should be the binary representation of M
            g[1,:] = [j>1 && j<B && (M & (1 << (B-1-j))) > 0 ? 1 : 0 for j in 1:B]
        end
        sarr = [ join(g[i,:],"") for i in 1:B ]
        s = join(sarr,"\n")
        print("$s\n")
    end
end

main()