using Printf

######################################################################################################
### a) We observe that the answer involves picking from the extremes.  To see this, suppose the
###    optimum has a point X for with P(y) < P(X) < P(Z) where Y and Z are not in the optimal set.
###    Fix the other members of the set, and let a/b be the probability that there are "half-1"/"half"
###    votes from the fixed members.  Then the probability of a tie is a * P(X) + b * (1-P(X)) which is
###    linear in P(X).  Thus, at least one of {Y,Z} should a better answer (or at least as good of an
###    answer in the case if a == b).
###
### b) Given 1:N ordered members, each with probability P(i) to vote yes, we can calculate the probability
###    of k yes votes after the first i members have votes with the recurrance
###            P(i,k) = P(i) * P(i-1,k-1) + (1-P(i)) * P(i-1,k)
###
### c) Out of an abundance of paranoia, we will use BigFloat for the math to avoid precision errors.
###
### d) This means we simply need to iterate through (K+1) sets of K folks.  The algorithm is then
###    O(K^3) + O(NlogN) (ignoring the need to grow the precision with increasing)
######################################################################################################
function calcIt(aa::Array{BigFloat,1}, m::Int64)
    one,zero = BigFloat(1.0),BigFloat(0.0)
    new = [one]
    old = []
    for p in aa 
        old = new
        new = vcat(old,[zero]) .* (one - p) + vcat([zero],old) .* p
    end
    return new[m+1]
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        P = [parse(BigFloat,x) for x in split(rstrip(readline(infile)))]
        sort!(P)
        best = BigFloat(0.0)
        m = K ÷ 2
        for numleft in 0:K
            numright = K-numleft
            aa = vcat(P[1:numleft],P[N-numright+1:N])
            best=max(best,calcIt(aa,m))
        end
        #print("$(best)\n")
        @printf("%.8f\n",Float64(best))
    end
end

main()