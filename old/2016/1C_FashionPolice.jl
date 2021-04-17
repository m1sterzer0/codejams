using Printf

######################################################################################################
### 1) If S <= K, we can just fully take all J*P*S tuples.
### 2) Otherwse, we claim we can take J * P * K tuples
###       map JxPxK --> JxPxS by (x1,x2,x3) --> (x1,x2,(x3+x1+x2)%S + 1)
###       -- note every (x1,x2) combination shows up exactly k times
###       -- every (x1,x3) and (x2,x3) combination shows up less than or equal to k times, since we can
###          solve for x1,x2 respectively
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        J,P,S,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        if S <= K
            print("$(J*P*S)\n")
            s = join(["$i $j $k" for i in 1:J for j in 1:P for k in 1:S],"\n")
            print("$s\n")
        else 
            print("$(J*P*K)\n")
            s = join(["$i $j $(1+(i+j+k) % S)" for i in 1:J for j in 1:P for k in 1:K],"\n")
            print("$s\n")
        end
    end
end

main()