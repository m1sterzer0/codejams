using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function presolve()
    sarr = zeros(Int64,1000000)
    rarr = zeros(Int64,1000000)
    larr = zeros(Int64,1000000)
    for i in 1:1000000
        sarr[i] = i
        larr[i] = length(string(i))
        rarr[i] = parse(Int64,lstrip(reverse(string(i)),['0']))
    end
    done = false
    passes = 1
    while (!done)
        #print(stderr,"Pass number $passes\n")
        done = true
        for i in 2:1000000
            if sarr[i-1] + 1 < sarr[i]
                done = false
                sarr[i] = sarr[i-1]+1
            end
            if larr[i] == larr[rarr[i]] && sarr[rarr[i]] + 1 < sarr[i]
                done = false
                sarr[i] = sarr[rarr[i]] + 1
            end
        end
        passes += 1
    end
    return sarr
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    sarr = presolve()
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        ans = N > 1000000 ? 0 : sarr[N]
        print("$ans\n")
    end
end

main()
