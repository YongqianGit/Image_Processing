function [along_crossing,cross_crossing,along_norm_fit,cross_norm_fit]=...
    Find_Crossing(itrack,bore_back,bore_front,interval,dt,speedlimit,combine,it)

% Find the crossing point between two borelines
% Find_Crossing(track # alongshore,back bore,front bore,...
% bore interval,time interval,speed range,combined flow existence or not).
% Kept fixing bugs during image processing, without combining some
% potential tedious operation. May need optimization at some point in the
% future


        if bore_back(itrack,2) <= bore_front(itrack,2)
        %bore(along,cross)
                coef=polyfit(bore_back(itrack-1:2:itrack+1,2),bore_back(itrack-1:2:itrack+1,1),1);%(crossshore, alongshore)


                cross_norm_fit=bore_back(itrack,2):0.1:bore_back(itrack,2)+15;
                along_norm_fit=-1*coef(1)^(-1)*(cross_norm_fit-bore_back(itrack,2))+bore_back(itrack,1);%perpendicular line
                along_norm_fit=along_norm_fit';
                cross_norm_fit=cross_norm_fit';

                if abs(coef(1))<1e5
                    along_front_interp=along_norm_fit;
                    cross_front_interp=interp1(bore_front(150:740,1),bore_front(150:740,2),along_front_interp);
                    along_crossing=invinterp(along_norm_fit,cross_front_interp-cross_norm_fit,0);%find the crossing in front bore
                    cross_crossing=interp1(along_norm_fit,cross_norm_fit,along_crossing);
                else %vertical perpendicular line crossing curved front bore 
                    along_crossing=bore_front(itrack,1);
                    cross_crossing=bore_front(itrack,2);
                end


                cross_back=bore_back(itrack,2);%point on back bore for velocity calculation
                along_back=bore_back(itrack,1);
                if isempty(along_crossing)%if cannot find crossing point
                    along_crossing=along_back+10;
                    cross_crossing=cross_back+10;%make a very high displacement, then replace by combine flow or replace with NaN 
                end


                if length(cross_crossing)>1 %for case of two crossing points, choose the nearer one
                    d=(cross_crossing-cross_back).^2+(along_crossing-along_back).^2;
                    [~, id_sort]=sortrows(d);
                    along_crossing=along_crossing(id_sort(1));
                    cross_crossing=cross_crossing(id_sort(1));
                end

                        cross_front=cross_crossing;
                        along_front=along_crossing;
                        if combine~=0
                            %combined flow in middle
                            if ((it>=80 && it <=120) || (it>=200 && it<=220 )) && itrack>=420 && itrack<=470 &&...
                                    bore_back(itrack,2)~=min(bore_back(420:470,2)) %for not-minimum
                                if sqrt((cross_front-cross_back)^2+(along_front-along_back)^2)*0.01/(interval*dt)>speedlimit                            
                                    if min(bore_back(420:470,2))<=min(bore_front(420:470,2))%find start and end point of line between minimum
                                        [max_cross,ind_max_cross]=min(bore_front(420:470,2));
                                        max_along=bore_front(419+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_back(420:470,2));
                                        min_along=bore_back(419+ind_min_cross,1);
                                    else
                                        [max_cross,ind_max_cross]=min(bore_back(420:470,2));
                                        max_along=bore_back(419+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_front(420:470,2));
                                        min_along=bore_front(419+ind_min_cross,1);
                                    end
                                        line_crossing(:,2)=min_cross-5:0.1:max_cross+15;%min of back to min of front (crossshore)
                                        line_crossing(:,1)=linspace(min_along,max_along,length(line_crossing(:,2)));

                                        if line_crossing(1,1)~=line_crossing(end,1)
                                            line_crossing_interp(:,1)=along_norm_fit;
                                            line_crossing_interp(:,2)=interp1(line_crossing(:,1),line_crossing(:,2),line_crossing_interp(:,1),'linear','extrap');
                                            along_crossing=invinterp(along_norm_fit,line_crossing_interp(:,2)-cross_norm_fit,0);
                                            cross_crossing=interp1(along_norm_fit,cross_norm_fit,along_crossing);                            
                                        else %for vertical line
                                            line_crossing_interp(:,2)=cross_norm_fit;
                                            line_crossing_interp(:,1)=interp1(line_crossing(:,2),line_crossing(:,1),line_crossing_interp(:,2),'linear','extrap'); 
                                            cross_crossing=invinterp(cross_norm_fit,line_crossing_interp(:,1)-along_norm_fit,0);
                                            along_crossing=line_crossing(1,1);
                                        end                                

                                end
                            elseif ((it>=80 && it <=120) || (it>=200 && it<=220 )) && itrack>=420 && itrack<=470 &&...
                                    bore_back(itrack,2)==min(bore_back(420:470,2)) %for minimum
                                [min_cross,ind_min_cross]=min(bore_front(420:470,2));
                                cross_crossing=min_cross;
                                along_crossing=bore_front(419+ind_min_cross,1);                        
                            %===================================================    
                            %combined flow on left
                            elseif (it>=130 && it <=170)  && itrack>=200 && itrack<=250 &&...
                                    bore_back(itrack,2)~=min(bore_back(200:250,2)) %for not-minimum
                                if sqrt((cross_front-cross_back)^2+(along_front-along_back)^2)*0.01/(interval*dt)>speedlimit                            
                                    if min(bore_back(200:250,2))<=min(bore_front(200:250,2))%find start and end point of line between minimum
                                        [max_cross,ind_max_cross]=min(bore_front(200:250,2));
                                        max_along=bore_front(199+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_back(200:250,2));
                                        min_along=bore_back(199+ind_min_cross,1);
                                    else
                                        [max_cross,ind_max_cross]=min(bore_back(200:250,2));
                                        max_along=bore_back(199+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_front(200:250,2));
                                        min_along=bore_front(199+ind_min_cross,1);
                                    end
                                        line_crossing(:,2)=min_cross-5:0.1:max_cross+15;%min of back to min of front (crossshore)
                                        line_crossing(:,1)=linspace(min_along,max_along,length(line_crossing(:,2)));


                                        if line_crossing(1,1)~=line_crossing(end,1)
                                            line_crossing_interp(:,1)=along_norm_fit;
                                            line_crossing_interp(:,2)=interp1(line_crossing(:,1),line_crossing(:,2),line_crossing_interp(:,1),'linear','extrap');
                                            along_crossing=invinterp(along_norm_fit,line_crossing_interp(:,2)-cross_norm_fit,0);
                                            cross_crossing=interp1(along_norm_fit,cross_norm_fit,along_crossing);
                                        else %for vertical line
                                            line_crossing_interp(:,2)=cross_norm_fit;
                                            line_crossing_interp(:,1)=interp1(line_crossing(:,2),line_crossing(:,1),line_crossing_interp(:,2),'linear','extrap'); 
                                            cross_crossing=invinterp(cross_norm_fit,line_crossing_interp(:,1)-along_norm_fit,0);
                                            along_crossing=line_crossing(1,1);
                                        end                                


                                end
                            elseif (it>=130 && it <=170) && itrack>=200 && itrack<=250 &&...
                                    bore_back(itrack,2)==min(bore_back(200:250,2)) %for minimum
                                [min_cross,ind_min_cross]=min(bore_front(200:250,2));
                                cross_crossing=min_cross;
                                along_crossing=bore_front(199+ind_min_cross,1);
                            %===================================================    
                            %combined flow on right   
                            elseif (it>=130 && it <=170)  && itrack>=645 && itrack<=695 &&...
                                    bore_back(itrack,2)~=min(bore_back(645:695,2)) %for not-minimum
                                if sqrt((cross_front-cross_back)^2+(along_front-along_back)^2)*0.01/(interval*dt)>speedlimit 
                                    if min(bore_back(645:695,2))<=min(bore_front(645:695,2))%find start and end point of line between minimum
                                        [max_cross,ind_max_cross]=min(bore_front(645:695,2));
                                        max_along=bore_front(644+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_back(645:695,2));
                                        min_along=bore_back(644+ind_min_cross,1);
                                    else
                                        [max_cross,ind_max_cross]=min(bore_back(645:695,2));
                                        max_along=bore_back(644+ind_max_cross,1);
                                        [min_cross,ind_min_cross]=min(bore_front(645:695,2));
                                        min_along=bore_front(644+ind_min_cross,1);
                                    end
                                        line_crossing(:,2)=min_cross-5:0.1:max_cross+15;%min of back to min of front (crossshore)
                                        line_crossing(:,1)=linspace(min_along,max_along,length(line_crossing(:,2)));

                                        if line_crossing(1,1)~=line_crossing(end,1)
                                            line_crossing_interp(:,1)=along_norm_fit;
                                            line_crossing_interp(:,2)=interp1(line_crossing(:,1),line_crossing(:,2),line_crossing_interp(:,1),'linear','extrap');
                                            along_crossing=invinterp(along_norm_fit,line_crossing_interp(:,2)-cross_norm_fit,0);
                                            cross_crossing=interp1(along_norm_fit,cross_norm_fit,along_crossing);
                                        else %for vertical line
                                            line_crossing_interp(:,2)=cross_norm_fit;
                                            line_crossing_interp(:,1)=interp1(line_crossing(:,2),line_crossing(:,1),line_crossing_interp(:,2),'linear','extrap'); 
                                            cross_crossing=invinterp(cross_norm_fit,line_crossing_interp(:,1)-along_norm_fit,0);
                                            along_crossing=line_crossing(1,1);
                                        end                                                            

                                end
                            elseif (it>=130 && it <=170) && itrack>=645 && itrack<=695 &&...
                                    bore_back(itrack,2)==min(bore_back(645:695,2)) %for minimum
                                [min_cross,ind_min_cross]=min(bore_front(645:695,2));
                                cross_crossing=min_cross;
                                along_crossing=bore_front(644+ind_min_cross,1);
                            %=========================
                            else                                       
                                if sqrt((cross_front-cross_back)^2+(along_front-along_back)^2)*0.01/(interval*dt)>speedlimit 
                                    along_crossing=NaN;
                                    cross_crossing=NaN;
                                    along_norm_fit=NaN;
                                    cross_norm_fit=NaN;
                                end
                            end

                        end

        elseif it>=220%too close to ending time, speed could be zero
            along_crossing=bore_back(itrack,1);
            cross_crossing=bore_back(itrack,2);
            along_norm_fit=bore_back(itrack,1);
            cross_norm_fit=bore_back(itrack,2);    
        else
            along_crossing=NaN;
            cross_crossing=NaN;
            along_norm_fit=NaN;
            cross_norm_fit=NaN;
        end

        if isempty(along_crossing) || isempty(cross_crossing)
            along_crossing=NaN;
            cross_crossing=NaN;
            along_norm_fit=NaN;
            cross_norm_fit=NaN;
        end
     
return