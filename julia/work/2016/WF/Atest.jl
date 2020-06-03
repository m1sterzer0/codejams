using Printf

######################################################################################################
### Observations
######################################################################################################

function main(infn="")
    p = [[1//1], [0//1,0//1]]
    for i in 1:20
        if i >= 3 
            pp = [0//1 for i in 1:i]
            sf = 1//(i-1)
            for j in 1:i-1   ## Loop over the possible placements of a family in the segment
                seg1len = j-1
                seg2len = i - seg1len - 2
                for k in 1:j-1
                    pp[k] += sf*p[seg1len][k]
                end
                for k in j+2:i
                    pp[k] += sf*p[seg2len][i-k+1]
                end
            end
            push!(p,pp)
        end
        sss = @sprintf("%3d ",i) * join([@sprintf("%-20s",string(x)) for x in p[i]]," ")
        println("$sss")
    end

    for i in 1:20
        pp = [ p[k][1] * p[i-k+1][1] for k in 1:i ]
        sss = @sprintf("%3d ",i) * join([@sprintf("%-20s",string(x)) for x in pp]," ")
        println("$sss")
    end 

    qq = [1,0,1//2]
    s1,s0 = [1, 3//2]
    for i in 4:20
        a = 1//(i-1) * s1
        push!(qq,a)
        s1,s0 = s0,a+s0
    end
    sss = join([@sprintf("%-20s",string(x)) for x in qq]," ")
    println("$sss")

end

main()