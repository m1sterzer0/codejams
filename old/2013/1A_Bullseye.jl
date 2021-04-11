
## One ring is (r+1)^2 - r^2     = 2r + 1  = 2r + 0 + 1
## 2nd ring is (r+3)^2 - (r+2)^2 = 2r + 5  = 2r + 4 + 1
## 3rd ring is (r+5)^2 - (r+4)^2 = 2r + 9  = 2r + 8 + 1
## 4th ring is (r+7)^2 - (r+6)^2 = 2r + 13 = 2r + 12 + 1
##
## Sum from ring 1 to k is 2*r*k + k + 4 * (0+1+2+3+...+(k-1))
##      = 2rk + k + 2*(k-1)*k

## For a bound, we restrict 2*r*k < 4*10^18 and we restrict k + 2*(k-1)*k < ~4*10^18
## for the second term 14*10^8 seems to be a good enough bound

paintReq(r::Int64,k::Int64)::Int64 = 2*r*k + k + 2*(k-1)*k

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        r,t = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        l=0
        u=min(14*10^8,2*10^18÷r)
        if paintReq(r,u) <= t; print("$u\n"); end
        while (u-l) > 1
            m = (u+l)÷2
            if paintReq(r,m) <= t; l = m; else; u = m; end
        end
        print("$l\n")
    end
end

main()

