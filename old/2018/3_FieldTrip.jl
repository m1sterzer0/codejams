######################################################################################################
### The furthest out people will always "move in" after every step (assuming the teacher does
### something sane), so we are just limited by the time it takes to get everyone to "move to the middle"
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        R = fill(0,N)
        C = fill(0,N)
        for i in 1:N
            R[i],C[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end 
        ans = max( (maximum(R)-minimum(R)+1) ÷ 2, (maximum(C) - minimum(C) + 1) ÷ 2)
        print("$ans\n")
    end
end

main()
