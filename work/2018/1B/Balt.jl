######################################################################################################
### For fun, this is the linear solution that appears in the answers.
###     At each point i, we maintain 6 pieces of information
###         * mstart/nstart:   the start of the maximal subsequence ending in i that has its M/N-value forced by i 
###         * mnval/nmval:     The associated N/M value of the maximal subsequence ending in i that has its M/N-value forced by i
###         * mxstart/nxstart: the start of the last contiguous sequence of M/N values
###     We can move forward and use these to calcualte the same values for the next term in the sequence.
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S::Int64 = parse(Int64,rstrip(readline(infile)))
        D,A,B = fill(0,S),fill(0,S),fill(0,S)
        for i in 1:S
            D[i],A[i],B[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        M::Vector{Int64} = D .+ A
        N::Vector{Int64} = D .- B
        best,nbest = 1,1

        mstart,mxstart,mnval = 1,1,typemax(Int64)
        nstart,nxstart,nmval = 1,1,typemax(Int64)

        mstartNxt,mxstartNxt,mnvalNxt = 0,0,0
        nstartNxt,nxstartNxt,nmvalNxt = 0,0,0

        for i in 2:S
            (mstartNxt,mxstartNxt,mnvalNxt) = (M[i] == M[i-1]) ? (mstart,mxstart,mnval) : (M[i] == nmval)  ? (nstart,i,N[i-1]) : (nxstart,i,N[i-1])
            (nstartNxt,nxstartNxt,nmvalNxt) = (N[i] == N[i-1]) ? (nstart,nxstart,nmval) : (N[i] == mnval)  ? (mstart,i,M[i-1]) : (mxstart,i,M[i-1])

            (mstart,mxstart,mnval) = (mstartNxt,mxstartNxt,mnvalNxt)
            (nstart,nxstart,nmval) = (nstartNxt,nxstartNxt,nmvalNxt)

            lbest = max(i-mstart+1,i-nstart+1)
            if lbest > best; (best,nbest) = (lbest,1)
            elseif lbest == best; nbest += 1
            end
        end
        print("$best $nbest\n")
    end
end

main()
