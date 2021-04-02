using Printf

######################################################################################################
### a) We notice that our total surface area will be area of the top circular surface of the bottom
###    pancake + the area of the "edges" of ALL the pancakes in the stack.
### b) This leads to a nice little O(n^2) algorithm which should be fast enough.  We sort the pancakes
###    by 2*r*h, and then we iterate through all of the candidates as possible bases.
### c) We can move to N log(N) with a more complex data structure, but not worth it for these limits.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        R,H = fill(0,N), fill(0,N)
        for i in 1:N
            R[i],H[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        byEdge = reverse(sort([(2*R[i]*H[i],i) for i in 1:N]))
        best = 0
        for (baseArea,baseIdx) in byEdge
            working = baseArea + R[baseIdx]^2; stackCount = 1
            if K == 1; best = max(working,best); continue; end
            for (pArea,pIdx) in byEdge
                if pIdx != baseIdx && R[pIdx] <= R[baseIdx]
                    working += pArea; stackCount += 1
                    if K == stackCount; best = max(working,best); continue; end
                end
            end
        end
        ans = best * pi
        @printf("%.8f\n",ans)
    end
end

main()
