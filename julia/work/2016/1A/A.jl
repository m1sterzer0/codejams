using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### We observe that the greedy solution of choosing
###    * left when the character is >= the left edge of the current string
###    * right otherwise
### is optimal.  This is easy enough to implement.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        res = []
        for c in S
            if length(res) > 0 && c >= res[1]
                pushfirst!(res,c)
            else
                push!(res,c)
            end
        end
        ans = join(res,"")
        print("$ans\n")
    end
end

main()