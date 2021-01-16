######################################################################################################
### -- If you run right/left from the origin, you must always stop on a quail before you turn around.
### -- If you run right/left, you must always run AT LEAST as far as the fastest quail before you turn
###    around, otherwise there was nothing gained by running that far (i.e. your time in that direction
###    would before limited either by the fastest quail or another quail beyond the faster quail, neither
###    of which were ameliorated by stopping early.)
### -- We realize that when we are at the origin, the current time and the identity of the fastest quail
###    not caught on either side is enough to fully specify the relevant details of the current state.
###    --- quails faster than the current fastest quail on each side have been caught already
###    --- quails slower than the current fastest and closer will be caught when we catch the fastest
###        and are thus irrelevant. 
######################################################################################################

struct quail
    p0::Int64
    s::Int64
end

Base.isless(a::quail,b::quail) = (a.s <= b.s) || (a.s == b.s) && (a.p0 < b.p0)

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        solveit(infile)
        #@time solveit(infile)
    end
end

function solveit(infile)
    Y,N =  [parse(Int64,x) for x in split(readline(infile))]
    P   =  [parse(Int64,x) for x in split(readline(infile))]
    S   =  [parse(Int64,x) for x in split(readline(infile))]

    leftQuail = Vector{quail}()
    rightQuail = Vector{quail}()
    for i in 1:N
        if P[i] > 0
            push!(rightQuail,quail(P[i],S[i]))
        else
            push!(leftQuail,quail(-P[i],S[i]))
        end
    end
    reverse!(sort!(leftQuail))
    reverse!(sort!(rightQuail))
    
    initialLeftFastest = length(leftQuail) > 0 ? 1 : 0
    initialRightFastest = length(rightQuail) > 0 ? 1 : 0

    scoreboard = fill(1e99,length(leftQuail)+1,length(rightQuail)+1)
    scoreboard[1,1] = 0.00
    ##print("\n")
    ##print("DBG: Y:$Y\n")
    ##print("DBG: leftQuail:$leftQuail\n")
    ##print("DBG: leftQuail:$rightQuail\n")

    for i in 0:length(leftQuail)
        for j in 0:length(rightQuail)
            starttime = scoreboard[i+1,j+1]
            if starttime >= 1e99; continue; end

            
            ##print("DBG: ($i,$j)starttime:$starttime\n")
            ## Run left
            lastincr = 0.00
            for k in i+1:length(leftQuail)
                incr = (float(leftQuail[k].p0) + starttime * float(leftQuail[k].s)) / (float(Y)-float(leftQuail[k].s))
                ##print("DBG: ($k,$j)incr:$incr\n")
                if incr <= lastincr; continue; end
                if k-1 > i; scoreboard[k,j+1] = min(scoreboard[k,j+1],starttime+2*lastincr); end
                lastincr = incr
            end
            scoreboard[length(leftQuail)+1,j+1] = min(scoreboard[length(leftQuail)+1,j+1],starttime+(j == length(rightQuail) ? 1 : 2)*lastincr)
            ##print("DBG: scoreboard:$scoreboard\n")


            ## Run right
            lastincr = 0.00
            for k in j+1:length(rightQuail)
                incr = (float(rightQuail[k].p0) + starttime * float(rightQuail[k].s)) / (float(Y)-float(rightQuail[k].s))
                ##print("DBG: ($i,$k)incr:$incr\n")
                if incr <= lastincr; continue; end
                if k-1 > j; scoreboard[i+1,k] = min(scoreboard[i+1,k],starttime+2*lastincr); end
                lastincr = incr
            end
            scoreboard[i+1,length(rightQuail)+1] = min(scoreboard[i+1,length(rightQuail)+1],starttime+(i == length(leftQuail) ? 1 : 2)*lastincr)
            ##print("DBG: scoreboard:$scoreboard\n")

        end
    end
    ans = scoreboard[length(leftQuail)+1,length(rightQuail)+1]
    print("$ans\n")
end

main()