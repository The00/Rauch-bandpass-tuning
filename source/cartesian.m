function C = cartesian( a, b)

    a_s = size(a);
    a_s = a_s(1,2);
    b_s = size(b);
    b_s = b_s(1,2);

    C = zeros(0,a_s*b_s);
    y=1;
    for i = 1:a_s
        for x = 1:b_s
            C(1,y)=b(1,x)*a(1,i);
            y=y+1;
        end
    end     
end

