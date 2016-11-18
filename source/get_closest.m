function [ R ] = get_closest( val, tab)

    [val,indice] = min(abs(tab-val));
    
    R = tab(1, indice);

end

