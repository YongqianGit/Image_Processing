function pline=Manual_Adjust(rev,boundary,pline,i,dir,f_img,f_img2,bw3)

% Manually adjust the detected bore fronts after the automatic process.
% Needed only in the initial development of algorithm. After improvement
% in 2014, this manual adjustment is no longer needed.

        if rev

                reply = input('Need to midify edge points? Y/N (return for Y) \n', 's');

                if (isempty(reply) || reply == 'y' || reply == 'Y');  
                    ycov2 = 1

                    reply3 = input('Ger rid of some point first ? Y/N (return for Y) \n', 's');
                    if (isempty(reply3) || reply3 == 'y' || reply3 == 'Y');
                        rmv = 1;
                    else
                        rmv = 0;
                    end                    

                else
                    ycov2 = 0
                end;

                while (ycov2);

                    boundary = sortrows(boundary,[-2, 1]);

                    dd = 1; nd = 0;
                    while rmv & dd<=size(boundary,1)

                        plot(boundary(dd,2),boundary(dd,1),'+m','markersize',8)
                        axis([boundary(dd,2)-40 boundary(dd,2)+40 boundary(dd,1)-40 boundary(dd,1)+40])

                        reply2 = input('Remove this point? -  Y(y): yes, N(n) or Return: no, X(x): done \n', 's');

                        if any([reply2 == 'y' , reply2 == 'Y']);  

                            plot(boundary(dd,2),boundary(dd,1),'+k','markersize',8)
                            boundary(dd,:) = [];
                            nd = nd+1


                        elseif any([isempty(reply2),reply2 == 'N',reply2 == 'n']); 

                            dd = dd+1;

                        else

                            rmv = 0;
                        end;

                    end
                    disp([num2str(length(nd)),' points Manually eliminated along the edge \n']);

                    bond = []; pline =  [];
                    bond=sortrows(boundary,[1, -2]);
                    p=1; pline = bond(1,:);

                    for w=2:length(bond(:,1))
                        if (pline(p,1) < bond(w,1));
                            p=p+1;
                            pline(p,:) = bond(w,:);
                        end
                    end
                    plot(pline(:,2),pline(:,1),'g','linewidth',2);
                    axis([0 640 0 382])

                    disp(['Click to add points and press ''Return'' to complete addition']);
                    [bx by] = ginput;
                    disp([num2str(length(by)),' points Manually added along the edge']); 
                    boundary = cat(1,boundary,[round(by) ceil(bx)]);

                    bond = []; pline =  [];
                    bond=sortrows(boundary,[1, -2]);
                    p=1; pline = bond(1,:);

                    for w=2:length(bond(:,1))
                        if (pline(p,1) < bond(w,1));
                            p=p+1;
                            pline(p,:) = bond(w,:);
                        end
                    end

                    plot(bond(:,2), bond(:,1), 'c', 'LineWidth', 1.2)  

                    reply = input('Need to add more points? Y/N (return for Y) \n', 's');                        
                    if (isempty(reply) || reply == 'y' || reply == 'Y');  
                        ycov2 = 1
                    else
                        ycov2 = 0
                        rev = 0;
                    end;

                end

        %=================previoud end of "if"
            udspk=pline;
            wvedge{2,i} = udspk ;
            save([dir,f_img,'/Edge_txy'],'wvedge');

            immask = zeros(size(bw3));
            for ymsk = 1:size(pline,1)
                    immask(1:pline(ymsk,1),ymsk)=1;
            end

            bwold = immask;
            for k = 1:size(immask,1)
                [ex iex]=max(find(immask(k,:)));
                bwold(k,iex+1:end) = 0;
            end
            imwrite(bwold,[f_img2,'/defaultmask.bmp'],'bmp')


        end %===========new end of "if"

    
return