######################################################################################################
### Two key ideas
### -- The outer arrow in each row and column cannot point outer
### -- If one arrow is the singleton arrow in both a row and a column, then we are screwed.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = [parse(Int64,x) for x in split(readline(infile))]
        map = fill('.',R,C)
        for i in 1:R
            map[i,:] = [x for x in strip(readline(infile))]
        end

        singletonRowSet = Set{Tuple{Int64,Int64}}()
        singletonColSet = Set{Tuple{Int64,Int64}}()
        changeSet = Set{Tuple{Int64,Int64}}()

        ## Do the rows first
        for i in 1:R
            found = []
            for j in 1:C
                if map[i,j] == '.'; continue; end
                push!(found,j)
            end
            if length(found) == 0
                continue
            elseif length(found) == 1
                push!(singletonRowSet,(i,found[1]))
                if map[i,found[1]] == '<' || map[i,found[1]] == '>'; push!(changeSet,(i,found[1])); end
            else
                if map[i,found[1]] == '<';   push!(changeSet,(i,found[1])); end
                if map[i,found[end]] == '>'; push!(changeSet,(i,found[end])); end
            end
        end

        ## Do the columns second
        for j in 1:C
            found = []
            for i in 1:R
                if map[i,j] == '.'; continue; end
                push!(found,i)
            end
            if length(found) == 0
                continue
            elseif length(found) == 1
                push!(singletonColSet,(found[1],j))
                if map[found[1],j] == '^' || map[found[1],j] == 'v'; push!(changeSet,(found[1],j)); end
            else
                if map[found[1],j] == '^';   push!(changeSet,(found[1],j)); end
                if map[found[end],j] == 'v'; push!(changeSet,(found[end],j)); end
            end
        end

        if length(intersect(singletonRowSet,singletonColSet)) > 0
            print("IMPOSSIBLE\n")
        else
            ans = length(changeSet)
            print("$ans\n")
        end
    end
end

main()
