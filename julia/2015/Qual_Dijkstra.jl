using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################


function buildQuaternionTable()
    ## (1,i,j,k,-1,-i,-j,-k) --> (1,2,3,4,5,6,7,8)

    a = fill(1,8,8)
    a[1,1:4] = [1,2,3,4]
    a[2,1:4] = [2,5,4,7]
    a[3,1:4] = [3,8,5,2]
    a[4,1:4] = [4,3,6,5]
    a[5:8,5:8] = a[1:4,1:4]  ## Negatives commute and 2 negatives cancel
    for i in 5:8
        for j in 1:4
            a[i,j] = a[i-4,j] + 4
            if a[i,j] > 8; a[i,j] -= 8; end
            a[j,i] = a[j,i-4] + 4
            if a[j,i] > 8; a[j,i] -= 8; end
        end
    end
    return a 
end            

function findi(qq,arr)
    val = 1
    for (i,v) in enumerate(arr)
        val = qq[val,v]
        if val == 2; return i; end
    end
    return -1
end

function findk(qq,arr)
    val = 1
    for (i,v) in enumerate(reverse(arr))
        val = qq[v,val]
        if val == 4; return i; end
    end
    return -1
end

function main(infn="")
    mtable = buildQuaternionTable()
    char2code(x) = x == 'i' ? 2 : x == 'j' ? 3 : 4
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        L,X = [parse(Int64,x) for x in split(readline(infile))]
        earr = [char2code(x) for x in readline(infile)]
        earrprod = 1
        for ee in earr; earrprod = mtable[earrprod,ee]; end
        xmod = X % 4

        ## Check if string product is -1
        if (earrprod == 1) || (xmod == 0) || (xmod in [1,3] && earrprod != 5) || (xmod == 2 && earrprod == 5); print("NO\n"); continue; end


        ## Note that x^4 == 1 for all elements in Q8, so we only need to look at 4 copies of the string
        prelen = findi(mtable,repeat(earr,4))
        postlen = findk(mtable,repeat(earr,4))
        if (prelen > 0) && (postlen > 0) && (prelen+postlen < L*X)
            print("YES\n")
        else
            print("NO\n")
        end
    end
end

main()
