######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        P::Int64,Q::Int64,N::Int64 = [parse(Int64,x) for x in split(readline(infile))]
        H::Vector{Int64} = fill(0,N)
        G::Vector{Int64} = fill(0,N)
        for i in 1:N
            H[i],G[i] = [parse(Int64,x) for x in split(readline(infile))]
        end

        ## We consider ourselves of having two currencies -- banked shots and gold
        ## For each monster (in order), we can decide to kill it, or not
        ## We keep track of our gold and banked shots after each scenario, and purge fully dominated positions

        function compress(last::Vector{Tuple{Int64,Int64}}, cur::Vector{Tuple{Int64,Int64}})
            sort!(cur,rev=true)
            empty!(last)
            while !isempty(cur)
                while !isempty(last) && last[end][2] <= cur[end][2]; pop!(last); end
                push!(last,cur[end])
                pop!(cur)
            end
        end

        lastnk::Array{Tuple{Int64,Int64}} = [(0,0)]
        lastk::Array{Tuple{Int64,Int64}} = []
        curnk::Array{Tuple{Int64,Int64}} = []
        curk::Array{Tuple{Int64,Int64}}  = []

        for i in 1:N
            towerShots = (H[i] + Q - 1) ÷ Q
            myShots = (H[i] - (towerShots-1)*Q + P - 1) ÷ P

            for (g,s) in lastnk; push!(curnk,(g,s+towerShots));end    ## (last,cur) = (nk,nk) case.  Here we bank shots, and we go first.
            for (g,s) in lastk;  push!(curnk,(g,s+towerShots-1));end  ## (last,cur) = (k,nk)  case.  Here we bank shots, but tower goes first.

            netShots = towerShots-myShots
            for (g,s) in lastnk;
                if s+netShots >= 0; push!(curk,(g+G[i],s+netShots)); end
            end
            netShots -= 1 ## (for the kill->kill case, we get even one fewer free shot)
            for (g,s) in lastk;
                if s+netShots >= 0; push!(curk,(g+G[i],s+netShots)); end
            end
            compress(lastnk,curnk)
            compress(lastk,curk)
        end
        ans = 0
        if !isempty(lastnk); ans = max(ans,lastnk[end][1]); end
        if !isempty(lastk);  ans = max(ans,lastk[end][1]); end
        print("$ans\n")
    end
end

main()
