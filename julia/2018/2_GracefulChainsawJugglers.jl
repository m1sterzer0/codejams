######################################################################################################
### * It never makes sense to give 1 juggler more than 31 chain saws of one color, since 1+2+...+32 = 528 
### * We can set up a quick DP here, where DP[red][blue][j] is the best we can do restricting ourself
###   to jugglers with less than or equal to j red chain saws. (There are other ways to set up
###   the DP too).
### * The DP is a bit expensive, but we only have to run it once.
### * Dealing with the one indexing is a bit tricky
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin

    ##Do the DP
    dp::Array{Int64,2}     = fill(0,501,501)
    dplast::Array{Int64,2} = fill(0,501,501)
    triang::Vector{Int64}  = [(i-1)*i ÷ 2 for i in 1:33]
    for i in 0:31
        dplast .= dp
        for n in 1:32
            tr,tb = i*n,triang[n]
            for r in tr:500
                for b in tb:500
                    dp[r+1,b+1] = max(dp[r+1,b+1],n+dplast[r-tr+1,b-tb+1])
                end
            end
        end
    end

    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ans = dp[R+1,B+1] - 1 ## Have to subtract off the (0,0) case
        print("$ans\n")
    end
end

main()
