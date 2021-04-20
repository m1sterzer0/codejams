######################################################################################################
### Pretty straigtforward.  For each position, we calculate the number of theoretical prefixes and 
### compare that to the number of actual prefixes.  If there is a discrepency, we find a missing prefix
### and append that to the suffix of the first word.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        words = Vector{String}()
        for i in 1:N
            push!(words,rstrip(readline(infile)))
        end

        ## Calc the letters per position
        lettersPerPos = [Set{String}() for i in 1:L]
        substringsPerPos = [Set{String}() for i in 1:L]
        for w in words
            for i in 1:L
                push!(lettersPerPos[i],w[i:i])
                push!(substringsPerPos[i],w[1:i])
            end
        end

        ans = ""
        comb = 1
        for i in 1:L
            comb *= length(lettersPerPos[i])
            if comb <= length(substringsPerPos[i]); continue; end
            prefixSet = i == 1 ? Set{String}([""]) : substringsPerPos[i-1]
            for prefix in prefixSet
                for postfix in lettersPerPos[i]
                    if prefix*postfix ∉ substringsPerPos[i]
                        ans = prefix*postfix*words[1][i+1:L]
                        break
                    end
                end
                if length(ans) > 0; break; end
            end
            if length(ans) > 0; break; end
        end
        print(length(ans) == 0 ? "-\n" : "$ans\n")
    end
end

main()
