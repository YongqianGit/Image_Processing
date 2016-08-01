function [bond,pline] = SortBoundary(boundary,im,horizon)

% Sort the boundary coordinates in order


        pline =  [];

        bond=sortrows(boundary,[2, 1]);%sort boundary ascendingly based on 2nd column. And for same values in 
        %2nd column, sort based on 1st column

        %{
        w = 1;

        while w<=size(bond,1) || ~isempty(bond)% |????    % ~isempty(boundary)


            p_ = find(bond(:,2) == min(bond(:,2)));  %what's this for? % find smallest points' indices (usually several  
            % same smallest values) in bond(:,2)?


            [~,idx] = max(p_);

            iw0 = p_(idx); %it is also mxid? %largest x of boundary (position in 'bond') in this y value

            pline = cat(1,pline,bond(iw0,:));% sweep each y in image, and get the last (x,y) in this y (bore) (y is horizontal, x is vertical)



            bond(1:iw0,:) = []; % delete the smallest bond(:,2)

        end
        %}
        %{\
        if horizon>0
            length=size(im,2); %length of bore line in one direction
        else
            length=size(im,1);
        end

        for i=1:length

            p=find(bond(:,2) == min(bond(:,2)));
            [~,idx]=max(p);
            iw0=p(idx);
            if bond(iw0,2)==i
                pline=cat(1,pline,bond(iw0,:));% sweep each y in image, and get the last (x,y) in this y (bore) (y is horizontal, x is vertical)
                bond(1:iw0,:) = []; % delete the smallest bond(:,2)
            else
                pline=cat(1,pline,[NaN,i]);
            end

        end

        %}
return