######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

mmul(a::Int64,b::Int64)::Int64 = (a*b) % 1000000007
function mfact(a::Int64)
    ans = 1
    for i in 1:a; ans = mmul(ans,i); end
    return ans
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        trains = split(readline(infile))

        left = fill(-1,26)
        right = fill(-1,26)
        singletons = fill(0,26)
        used = fill(false,26)

        done = false
        for i in 1:N
            t = trains[i]
            ## Check for a singleton train
            if t[1] == t[end]
                for c in t
                    if c != t[1]; done = true; break; end
                end
                lval = t[1] - '`'
                singletons[lval] += 1
            ## Ok, we have two different ends.  Now we need to deal with the middle
            else
                j = 1; while(t[j+1] == t[1]); j+=1; end
                k = length(t); while(t[k-1] == t[end]); k-=1; end
                for ii in j+1:k-1
                    if t[ii] == t[ii-1]; continue; end
                    lval = t[ii] - '`'
                    if used[lval]; done=true; break; end
                    used[lval] = true
                end
                if done; break; end
                leftval,rightval = Int64(t[1]-'`'),Int64(t[end]-'`')
                if left[leftval] != -1; done=true; break; end
                if right[rightval] != -1; done=true; break; end
                left[leftval] = i; right[rightval] = i
            end
        end
        if done; print("0\n"); continue; end

        ## Now check to see if any of the cars inner letters match the edge letters of a different car
        for i in 1:26
            if !used[i]; continue; end
            if left[i] != -1; done=true; break; end
            if right[i] != -1; done=true; break; end
        end
        if done; print("0\n"); continue; end

        ## Now we count cars
        ans = 1
        for i in 1:26
            if singletons[i] > 0; ans = mmul(ans,mfact(singletons[i])); end
        end
        ncars = 0
        scoreboard = fill(false,26)
        for i in 1:26
            if scoreboard[i]; continue; end
            if  left[i] == -1 && right[i] == -1 && singletons[i] == 0; continue; end
            if  left[i] == -1 && right[i] == -1 && singletons[i] > 0; ncars += 1; scoreboard[i] = true; continue; end

            ncars += 1
            carnum = left[i] > 0 ? left[i] : right[i]

            ## Chase left
            num,c = carnum,i
            scoreboard[c] = true
            while right[c] != -1
                num = right[c]
                c = Int64(trains[num][1] - '`')
                if scoreboard[c]; done=true; break; end
                scoreboard[c] = true
            end
            ## Chase right
            num,c = carnum,Int64(trains[carnum][end]-'`')
            scoreboard[c] = true
            while left[c] != -1
                num = left[c]
                c = Int64(trains[num][end] - '`')
                if scoreboard[c]; done=true; break; end
                scoreboard[c] = true
            end
            if done; break; end
        end
        if done; print("0\n"); continue; end
        ans = mmul(ans,mfact(ncars))
        print("$ans\n")
    end
end

main()

