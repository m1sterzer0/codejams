######################################################################################################
### I LOVE the interactive problems!!
###
### The obvious strategy here seems to be just to sell the "most rare" flavors (based on the
### flavors requested so far) amongs the set of pops we still have available and that the customer likes, 
### saving the popular flavors for the final customers when the inventory is low.
######################################################################################################
using Random
Random.seed!(8675309)

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        N = parse(Int64,rstrip(readline(infile)))
        seen = fill(0,N)
        used = Set{Int64}()
        for i in 1:N
            darr = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
            if darr[1] == -1 exit(1); end;
            if darr[1] == 0; print("-1\n"); continue; end
            darr = copy(darr[2:end])
            for d in darr; seen[d+1] += 1; end
            remaining = [d for d in darr if d ∉ used]
            if length(remaining) == 0; print("-1\n"); continue; end
            targ = minimum([seen[x+1] for x in remaining])
            vals = [d for d in remaining if seen[d+1] == targ]
            v = Random.rand(vals)
            push!(used,v)
            print("$v\n"); flush(stdout)
        end
    end
end

main()
