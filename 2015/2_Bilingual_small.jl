function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        wcnt = 0
        wordLookup = Dict{String,Int64}()
        sentences = Vector{Vector{Int64}}()
        for i in 1:N
            s = Vector{Int64}()
            words = split(readline(infile))
            setWords = Set(words)
            for w in setWords
                if !haskey(wordLookup,w); wcnt += 1; wordLookup[w] = wcnt; end
                push!(s,wordLookup[w])
            end
            push!(sentences,s)
        end

        best = wcnt
        baseScoreboard = fill(0,wcnt)
        for w in sentences[1]; baseScoreboard[w] |= 1; end
        for w in sentences[2]; baseScoreboard[w] |= 2; end

        if N == 2
            bcnt::Int64 = 0
            for i in 1:wcnt
                if baseScoreboard[i] == 3; bcnt += 1; end
            end
            print("$bcnt\n")
        else
            #print("\n")
            for mask in 0:2^(N-2)-1
                scoreboard = copy(baseScoreboard)
                for sidx in 3:N
                    amt = mask & (1 << (sidx-3)) > 0 ? 2 : 1
                    for w in sentences[sidx]; scoreboard[w] |= amt; end
                end
                cnt::Int64 = 0
                for i in 1:wcnt
                    if scoreboard[i] == 3; cnt += 1; end
                end
                #print("DBG: mask=$mask cnt:$cnt scoreboard:$scoreboard\n")
                best = min(cnt,best)
            end
            print("$best\n")
        end
    end
end

main()
