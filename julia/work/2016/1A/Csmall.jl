using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### For Csmall, we just iterate throught the 3.6M possible permutations and look for possible circles.
### Blindly iterating through the permutations takes a bit too much time, so we have to do it
### in a slightly smarter way with recursion to limit the false branches.
######################################################################################################

function findBestWithPre(arr,F,n)
    best = 0
    choices = [x for x in 1:n if x ∉ arr]
    for c in choices
        prefix = arr[:]
        push!(prefix,c)
        while F[prefix[end]] ∉ prefix; push!(prefix,F[prefix[end]]); end
        if F[prefix[end]] ∉ (prefix[1],prefix[end-1]); continue; end
        ## Cases: a) Prefix uses all entries
        ##        b) prefix is len >2 and loops back to 1
        ##        c) prefix[end] points to prefix[end-1].  Last case requires recursion
        best = max(best,length(prefix))
        if length(prefix) == n
            break
        elseif (length(prefix) > 2) && (F[prefix[end]] == prefix[1])
            continue
        else
            best = max(best,findBestWithPre(prefix,F,n))
        end
    end
    return best
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        F = [parse(Int64,x) for x in split(readline(infile))]
        best = findBestWithPre([],F,N)
        print("$best\n")
    end
end

main()

