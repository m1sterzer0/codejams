######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        K,L,S = [parse(Int64,x) for x in split(readline(infile))]
        kk = strip(readline(infile))
        ll = strip(readline(infile))

        ## Step 1: figure out if any prefix of the target lines up with any suffix, so we know where we reset to
        resetPos = 0
        for i in 1:(L-1)
            if ll[1:i] == ll[end-i+1:end]; resetPos = i; end
        end
        
        ## Step 2: calculate max bananas -- first need to see if the keyboard contains all of the necessary keys
        lset = Set(ll)
        kset = Set(kk)
        maxBananas = issubset(lset,kset) ? 1 + (S-L) ÷ (L-resetPos) : 0

        ## Step3 : now we need to create the state transition probability matrix
        ##       : we have L+1 states.  Between each state transition we will move the terms in the "complete" state (L+1) back to the reset position
        A = zeros(Int64,L+1,L+1)
        for i in 1:L
            for k in kk
                vv = (i==1 ? "" : ll[1:i-1]) * "$k"
                best = 0
                for j in 1:length(vv)
                    if ll[1:j] == vv[end-j+1:end]; best = j; end
                end
                A[best+1,i] += 1
            end
        end
        Af = float(A) ./ K


        ## Step4 : Run the simulation for K steps and see what we get
        state = zeros(Float64,L+1); state[1] = 1.00
        expectedBananas = 0.00
        for i in 1:S
            state = Af * state
            expectedBananas += state[L+1]
            state[resetPos+1] += state[L+1]
            state[L+1] = 0.00
        end

        ans = maxBananas - expectedBananas
        print("$ans\n")
    end
end

main()
    
