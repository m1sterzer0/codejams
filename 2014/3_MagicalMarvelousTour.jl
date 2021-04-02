######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,p,q,r,s = [parse(Int64,x) for x in split(readline(infile))]
        tt = [((i*p+q) % r) + s for i in 0:N-1]
        ttsum = sum(tt)
        best = ttsum
        l::Int64,r::Int64,ls::Int64,ms::Int64,rs::Int64 = 1,0,0,0,ttsum
        for l in 1:N
            if r < l; r += 1; ms += tt[r]; rs -= tt[r]; end
            while(r < N && max(ls,ms+tt[r+1],rs-tt[r+1]) < max(ls,ms,rs))
                r += 1; ms += tt[r]; rs -= tt[r]
            end
            best = min(best,max(ls,ms,rs))
            ls += tt[l]
            ms -= tt[l]
        end

        ans = float(ttsum-best) / float(ttsum)
        print("$ans\n")
    end
end

main()
