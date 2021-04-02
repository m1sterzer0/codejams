using Printf

######################################################################################################
### Since horses can't pass each other, we need to reach the finish line when the last horse
### would reach the line if it were unimpeded.  Thus, all we have to do is to calculate the finish
### time of all of the other horses, pick the last one, and calculate our speeed.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        D,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        K = zeros(Int64,N)
        S = zeros(Int64,N)
        for i in 1:N
            K[i],S[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        finishTimes = [(D-K[i])//S[i] for i in 1:N]
        worstFinish = maximum(finishTimes)
        ans = Float64(D // worstFinish)
        @printf("%.8f\n",ans)
    end
end

main()
