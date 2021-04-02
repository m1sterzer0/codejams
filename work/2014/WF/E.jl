######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

comb(n::Int64,k::Int64)::BigInt = k < 0 ? 0 : 
                                  k == 0 ? 1 :
                                  k == 1 ? n :
                                  k < n ? comb(n,k-1) * (n-k+1) ÷ k :
                                  k == n ? 1 : 0  

function nn(d::Int64,A::Int64,B::Int64)::BigInt
    ans::BigInt = 0
    if d < A; return 1; end
    ## Part 1: Count the number of valid strings that end in a right
    ## This equals the number of prefixes that consume more than
    ## d-(A+B) days but no more than (d-A) days

    for r::Int64 in 0:50
        drem = d - r*B
        if drem < A; break; end
        lmin = (drem-A-B) < 0 ? 0 : (drem-A-B) ÷ A + 1 
        lmax = (drem-A) ÷ A
        if lmax < lmin; continue;
        elseif lmax == lmin; ans += comb(lmin+r,r)
        else
            ans += comb(lmax+r+1,r+1)  ## Using hockey stick identity
            ans -= comb(lmin+r,r+1)    ## Using hockey stick identity
        end
    end

    ## Part 2: Count the number of valid strings that end in a left
    ## This equals the number of prefixes that consume more than
    ## (d-2A) days but no more than (d-A) days. Remainder theorem
    ## coveres the (d-2A) case.
    for r::Int64 in 0:50
        drem = d - r*B
        if drem < A; break; end
        lnum = (drem-A) ÷ A
        ans += comb(lnum+r,r)
    end
    return ans
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ans = 0
        N,A,B = [parse(Int64,x) for x in split(readline(infile))]
        if N == 1; print("0\n"); continue; end
        dmin,dmax = 0,50*B
        Nbig = BigInt(N)
        while(dmax-dmin>1)
            m = (dmin+dmax)÷2
            if nn(m,A,B) >= Nbig; dmax = m
            else; dmin = m
            end
        end
        print("$dmax\n")
    end
end

main()
