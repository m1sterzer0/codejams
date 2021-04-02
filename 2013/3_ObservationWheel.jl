function main(infn="")
    ## Prework
    c::Array{Float64,2} = fill(0.0,201,201)
    for i in 0:200
        for j in 0:i
            c[i+1,j+1] = (j==0 || j==i ) ? 1.0 : c[i,j]+c[i,j+1]
        end
    end
    comb(a::Int64,b::Int64) = c[a+1,b+1]

    E::Array{Float64,2} = fill(0.00,201,201)
    P::Array{Float64,2} = fill(0.00,201,201)
    numEmpty::Array{Int64,2} = fill(0,201,201)
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S = rstrip(readline(infile))
        N = length(S)

        ans::Float64 = -1.00
        if '.' ∉ S; ans = 0.00
        elseif S == "."; ans = 1.00
        end
        if ans >= 0; print("$ans\n"); continue; end

        for delta in 0:N-1
            for i::Int64 in 1:N
                j::Int64 = i+delta
                if j > N; j -= N; end
                pj::Int64 = j - 1
                if pj == 0; pj = N; end
                numEmpty[i,j] = (i == j ? 0 : numEmpty[i,pj]) + (S[j] == 'X' ? 0 : 1) 
                ## Base cases
                if S[j] == 'X'; P[i,j] = 0.00; E[i,j] = 0.00; continue; end
                if numEmpty[i,j] == 1; P[i,j] = 1.00; E[i,j] = 0; continue; end
                ## Now the interesting case, we cycle through the "next to last" options
                P[i,j] = 0.00
                E[i,j] = 0.00
                k::Int64 = i
                while (k != j)
                    nk = (k == N) ? 1 : k+1
                    if S[k] == 'X'; k = nk; continue; end
                    ne1 = numEmpty[i,k]
                    ne2 = numEmpty[nk,j]
                    width1 = k-i+1;  if width1 <= 0; width1 += N; end
                    width2 = j-nk+1; if width2 <= 0; width2 += N; end
                    widthtot = width1+width2
                    ## Need ne1-1 balls to go left, then ne2-1 balls to go right, then 1 ball to go left
                    pcase::Float64 = 1.00
                    if ne1+ne2 > 2; pcase *= comb(ne1+ne2-2,ne1-1); end
                    if ne1 > 1; pcase *= (width1 / widthtot) ^ (ne1-1); end
                    if ne2 > 1; pcase *= (width2 / widthtot) ^ (ne2-1); end
                    pcase *= (width1 / widthtot) ## Final ball going to the left
                    pcase *= P[i,k]
                    pcase *= P[nk,j]
                    if pcase > 0
                        ecase = E[i,k] + E[nk,j] + N - 0.5 * (width1-1)
                        P[i,j] += pcase
                        E[i,j] += pcase*ecase
                    end
                    k = nk
                end
                E[i,j] /= P[i,j]  ## P[i,j] should never be zero, since we have at least 2 empty slots
            end
        end

        ans = 0.5 * (N+1)  ## This is for the final person 
        for i in 1:N
            pi = i==1 ? N : i-1
            ans += P[i,pi] * E[i,pi]
        end
        print("$ans\n")
    end
end

main()
