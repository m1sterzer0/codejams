
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        LL = []
        for i in 1:N
            a,b = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            push!(LL,(a,b))
        end
        status = [0 for i in 1:N]
        numstars = 0
        numplayed = 0

        ## Priority 1 -- any levels where we can do the pair
        ## Priority 2 -- any levels we have partially completed
        ## Priority 3 -- any levels where we can do the first one,
        ##               breaking ties with the highest second number

        while (numstars < 2N)
            cand1,cand2,cand3 = 0,0,0
            for i in 1:N
                if status[i] == 0 && numstars >= LL[i][2]
                    cand1 = i; break
                elseif status[i] == 1 && numstars >= LL[i][2]
                    cand2 = i
                elseif status[i] == 0 && numstars >= LL[i][1] && (cand3 == 0 || LL[cand3][2] < LL[i][2])
                    cand3 = i
                end
            end
            if cand1 == 0 && cand2 == 0 && cand3 == 0; break; end
            numplayed += 1
            if cand1 > 0
                numstars += 2; status[cand1] = 2
            elseif cand2 > 0
                numstars += 1; status[cand2] = 2
            else
                numstars += 1; status[cand3] = 1
            end
        end
        if numstars < 2N
            print("Too Bad\n")
        else
            print("$numplayed\n")
        end
    end
end

main()

