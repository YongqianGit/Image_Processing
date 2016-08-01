function [x0,y0]=invinterp(x,y,y0)
% Find the crossing points between two curves.
% Solution inspired by other researchers' idea online.

        n=numel(y);

        if y0<min(y) || y0>max(y)

            x0=[];y0=[];

        else

            below=y<y0;

            above=y>=y0;

            kth=(below(1:n-1) & above(2:n)) | (above(1:n-1) & below(2:n));

            kp1=[false;kth];

            alpha=(y0-y(kth))./(y(kp1)-y(kth));

            x0=alpha.*(x(kp1)-x(kth))+x(kth);

            y0=repmat(y0,size(x0));

        end 
        
        
return        