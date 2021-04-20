######################################################################################################
### This is a little tricky.  Each polled person contributes K + R/N to the unrounded percentage.
### We can ignore the K terms.  Then, our goal is to be as greedy as possible in how we allocate
### our remaining "R/N" adders to maximize the rounded total sum. A few cases
### -- If R/N == 0, then this whole thing is moot, as each person contributes exactly a whole number
###    of percentage points, and the answer will always be 100%
### -- If R/N >= 0.5, then our most efficient method to boost our score is just to make up new
###    languages for all of the remaining people, since each one will add one to the percentage. Getting
###    one point for each R/N term is the best we can ever hope for.
### -- If R/N is less than 0.5, we can make several more observations
###    * It never makes sense to add items to one that is already "rounded up", since in that case
###      it is at least as good to create new entries.  The new entries only need to make it to 0.5,
###      while the already rounded up terms need to make it to 0.5 + more.
###    * For the rounded down terms, we need to figure out how many we need to add to get to 0.5, and
###      we process these in sorted order of required elements.  Once we get to the same as the number
###      it takes to get a point from creating a new language, we switch over. 
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]

        K = 100 ÷ N
        R = 100 % N ## Each added lines adds 1/N to the fraction == 100/N to the unrounded percentage = (K + R/N)
        if R == 0; print("100\n"); continue; end

        numLeft = N - sum(C)
        threshold = (N+1) ÷ 2
        baseline = sum(100x ÷ N for x in C) + count(x->100x % N >= threshold, C) + K * numLeft
        if 2R >= N; print("$(baseline+numLeft)\n"); continue; end  ## Here we can get a full remainder point by creating a new language with one pollster.

        needed = [ (threshold - (100x % N) + R - 1) ÷ R for x in C if (100x % N) < threshold ]
        sort!(needed)
        newLang = (threshold + R - 1) ÷ R
        for i in needed
            if numLeft < i || i >= newLang; break; end
            numLeft -= i
            baseline += 1
        end
        baseline += numLeft ÷ newLang
        print("$baseline\n")
    end
end

main()
