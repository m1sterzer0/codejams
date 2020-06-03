using Printf

######################################################################################################
### Three step plan for evacuation
### 1) We whittle down the most populous party one-by-one until it matches the cardinality of the
###    second most populous party.
### 2) We evacuate everyone not in the top two parties one-by-one
### 3) We evacuate the two most populous parties two-by-two to prevent the majority condition
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        print("Case #$qq: ")
        N = parse(Int64,readline(infile))
        P = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        counts = [(p,i) for (i,p) in enumerate(P)]
        sort!(counts,rev=true)
        s1 = [alph[counts[1][2]] for i in 1:counts[1][1]-counts[2][1] ]
        s2 = [alph[counts[i][2]] for i in 3:N for j in 1:counts[i][1] ]
        s3 = [alph[counts[1][2]] * alph[counts[2][2]] for i in 1:counts[2][1]]
        ans = join(vcat(s1,s2,s3)," ")
        print("$ans\n")
    end
end

main()