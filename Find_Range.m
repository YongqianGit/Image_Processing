function region=Find_Range(line1,line2,region,ratio,real_diff)

%Find the region range for catching the bore line

%line(cross,along)
            line1(:,1)=interp1(line1(:,2),line1(:,1),line1(:,2),'spline'); %eliminate NaN
            line2(:,1)=interp1(line2(:,2),line2(:,1),line2(:,2),'spline');

            
            avg_pre1=mean( line1( ~isnan( line1(:,1) ),1 ) );

            avg_pre2=mean( line2( ~isnan( line2(:,1) ),1 ) );
            
            
            if ~ratio==0
                for j=1:size(line1(:,1))



                    %{ 

                    if(avg_pre2>avg_pre1 && line1(j,1)-5*(avg_pre2-avg_pre1)>0 && int16(line1(j,1)-5*(avg_pre2-avg_pre1))>0)

                        region(int16(line1(j,1)-5*(avg_pre2-avg_pre1)):int16(line2(j,1)+max(5*(avg_pre2-avg_pre1),30)),j)=1;

                    elseif (avg_pre2>avg_pre1 && line1(j,1)-5*(avg_pre2-avg_pre1)>0 && int16(line1(j,1)-5*(avg_pre2-avg_pre1))<=0)
                        region(1:int16(line2(j,1)+max(5*(avg_pre2-avg_pre1),30)),j)=1;
                    else    
                        region(max(int16(line1(j,1)-20),1):int16(line2(j,1)+30),j)=1;
                    end
    %                end
                    %}
                    %comment on 2014/10/07

                    diff=abs(avg_pre1-avg_pre2)*ratio;
                    if line1(j,1)<=line2(j,1) && line1(j,1)-diff>=1
                        region(int16(line1(j,1)-diff):int16(line2(j,1)+diff),j)=1;
                    elseif line1(j,1)<=line2(j,1) && line1(j,1)-diff<1 
                        region(1:int16(line2(j,1)+diff),j)=1;
                    elseif line2(j,1)<=line1(j,1) && line2(j,1)-diff>=1
                        region(int16(line2(j,1)-diff):int16(line1(j,1)+diff),j)=1;
                    elseif line2(j,1)<=line1(j,1) && line2(j,1)-diff<1 
                        region(1:int16(line1(j,1)+diff),j)=1;
                    end
                end                
            else
                for j=1:size(line1(:,1)) 
                    if line1(j,1)<=line2(j,1) && line1(j,1)-real_diff>=1
                        region(int16(line1(j,1)-real_diff):int16(line2(j,1)+real_diff),j)=1;
                    elseif line1(j,1)<=line2(j,1) && line1(j,1)-real_diff<1 
                        region(1:int16(line2(j,1)+real_diff),j)=1;
                    elseif line2(j,1)<=line1(j,1) && line2(j,1)-real_diff>=1
                        region(int16(line2(j,1)-real_diff):int16(line1(j,1)+real_diff),j)=1;
                    elseif line2(j,1)<=line1(j,1) && line2(j,1)-real_diff<1 
                        region(1:int16(line1(j,1)+real_diff),j)=1;
                    end
                end        
            end
            
            
            if size(region,1)>1008
                    region(1009:end,:)=[];
            end
            
return