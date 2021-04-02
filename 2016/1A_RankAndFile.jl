using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
###
### The key observation is to note that the height of each soldier is written down on two different
### lists, so if I look at the concatenation of all of the lists, the height will show up an even
### number of times.  If we are missing one list, the concatenation will have exactly N heights that
### appear an odd number of times.  This is the list that we want.
###
### Note that the heights are all less than or equal to 2500, so an array makes sense (vs. a dict).
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        heights = zeros(Int64,2500)
        h = zeros(Int64,N,2*N-1)
        for i in 1:2N-1
            h[:,i] = [parse(Int64,x) for x in split(readline(infile))]
        end
        for c in eachcol(h)
            for hh in c
                heights[hh] += 1
            end
        end
        missingHeights = join([x for x in 1:2500 if heights[x] % 2 != 0], " ")
        print("$missingHeights\n")
    end
end

main()