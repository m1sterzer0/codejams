using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        tokens = split(readline(infile))
        si = [parse(Int64,string(x)) for x in tokens[2]]
        standing = 0
        added = 0
        for (idx,val) in enumerate(si)
            if standing < (idx-1)
                added += (idx-1)-standing
                standing = idx-1
            end
            standing += val
        end
        print("$added\n")
    end
end

main()
