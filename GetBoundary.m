function boundary=GetBoundary(B)

% Get the boundary coordinates in matrix

        szB = ones(size(B));

        for k = 1:length(B)                    
            szB(k,1) = length(B{k});  %length (number of boundary pix) of each region in B                  
        end

        [~,iszB] = sortrows(szB,-1); % descending sorting  %'szB' is sorted values, 'iszB' is indices
        BB = B(iszB); % boundary cell sorted descendingly based on region sizes


        boundary = [];                    
        for ii=1:size(BB,1) %size(BB,1): length of BB rows 
            boundary = cat(1,boundary,BB{ii}); %combine two matrix

        end
    
return     