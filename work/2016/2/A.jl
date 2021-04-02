using Printf

######################################################################################################
### We make two observations
### a) If we choose the winner (i.e. R, P, or S), we determine the whole tree (logically, not lexically)
### b) We can lexically sort the resultant tree while maintaining "tree-equivalence" by simply by
### swapping branches in the tournament as needed while iterating from left to right (as we normally
### draw a tournament tree).
###
### Thus, we simply try the three cases of 'P', 'R', 'S" winning, compute the tree, see if it is
### consistent with the R,P,S given values, and if so, sort the tree to the lexical minimum.  We
### simply output the lexical minimum of these candidate strings (or IMPOSSIBLE if none exist).
######################################################################################################

function buildIt(sb::Array{Char,2},n::Int64)
    for i in 1:n
        l = 2^(i-1)
        sb[i+1,1:2:2*l] = sb[i,1:l]
        sb[i+1,2:2:2*l] = [x == 'R' ? 'S' : x == 'P' ? 'R' : 'P' for x in sb[i,1:l]]
    end
 end

function checkIt(sb::Array{Char,2},n::Int64,r::Int64,p::Int64,s::Int64)
    if count(x->x=='R',sb[n+1,1:2^n]) != r; return false; end
    if count(x->x=='P',sb[n+1,1:2^n]) != p; return false; end
    if count(x->x=='S',sb[n+1,1:2^n]) != s; return false; end
    return true
 end

function sortIt(sb::Array{Char,2},n::Int64)
    b = sb[n+1,1:2^n]
    for i in 1:n
        a = b[:]
        l = length(a)
        b = [min(x*y,y*x) for (x,y) in zip(b[1:2:l],b[2:2:l])]
    end
    return b[1]
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    sb = fill('x',13,4096)
    for qq in 1:tt
        print("Case #$qq: ")
        N,R,P,S = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ans = []
        for seed in "PRS"
            sb[1,1] = seed
            buildIt(sb,N)
            if checkIt(sb,N,R,P,S)
                push!(ans,sortIt(sb,N))
            end
        end
        sort!(ans)
        if length(ans) == 0
            print("IMPOSSIBLE\n")
        else
            print("$(ans[1])\n")
        end
    end
end

main()