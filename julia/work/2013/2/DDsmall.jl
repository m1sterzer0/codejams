
function solve1(A::Int64, B::Int64, C::Int64)
    s::Int64 = 0
    if s == C; return 0; end
    for i in 1:A
        s = (s+B) % A
        if s == C; return i; end
    end
    return -1
end

function solve2(A::Int64, B::Int64, C::Int64)
    #print("DBG: solve2($A,$B,$C)\n")
    if B >= A; return -1; end
    if C == 0; return 0; end
    if B+B > A; return solve2(A,A-B,A-C); end
    q1::Int64 = C ÷ B
    base = q1*B
    if base == C; return q1; end
    rem = C-base

    ## Go backward
    q2::Int64 = A ÷ B
    base2 = B*q2
    if base2 == A; return -1; end
    backward = A-base2
    aa = solve2(B,backward,B-rem)
    if aa == -1; return -1; end
    return q2*aa+(backward*aa+C)÷B
end

using Random
function main()
    Random.seed!(8675309)
    for i in 1:1000
        #A = Random.rand(10:1000000)
        A = Random.rand(5:1000000)
        B = Random.rand(1:A)
        C = Random.rand(0:A-1)
        print("Case $i: $A $B $C\n")
        x1 = solve1(A,B,C)
        x2 = solve2(A,B,C)
        if x1 == x2; print("    --p-- $A $B $C $x1 $x2\n")
        else;        print("    ERROR $A $B $C $x1 $x2\n")
        end
    end
end

main()
        
