using Printf

######################################################################################################
### 1) For the small, it is clear that the product is maximized when we improve the smallest element
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        U = parse(Float64,rstrip(readline(infile)))
        P = [parse(Float64,x) for x in split(rstrip(readline(infile)))]

        ### Lazy binary search
        lb,ub = minimum(P),1.00
        while ub-lb > 1e-10
            m = 0.5 * (ub+lb)
            x = sum(x -> x<m ? m-x : 0.0, P)
            (lb,ub) = x < U ? (m,ub) : (lb,m)
        end
        m = 0.5*(ub+lb)
        ans = prod(x -> max(x,m), P)
        @printf("%.8f\n", ans)
    end
end

main()
