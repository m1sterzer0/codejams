
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        J = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = popfirst!(J)
        ansarr = fill(0.00,N)
        sb = []
        for i in 1:N; push!(sb,(J[i],i)); end
        sort!(sb,rev=true)
        audiencepoints = sum(J)
        pointsleft = 2*audiencepoints
        playersleft = N
        for (curscore,j) in sb
            thresh = pointsleft/playersleft
            if curscore > thresh
                ansarr[j] = 0.00
                pointsleft -= curscore
                playersleft -= 1
            else
                ansarr[j] = 100.0 * (thresh-curscore) / audiencepoints
            end
        end
        ansstr = join(ansarr," ")
        print("$ansstr\n")
    end
end

main()
