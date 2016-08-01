function pline=Bore_Despike(pline,window,limit)
% Remove the outlier points in the bore line


        finish=0;
        loop=0;

        while(~finish)
            loop=loop+1;
            bad_num=0;
            for i=1:size(pline,1)-1
                if (abs(pline(i,1)-pline(i+1,1))>=limit) || isnan(pline(i+1,1))


                    bad_index=i+1;
                    bad_num=bad_num+1;
                    pline(bad_index,1)=NaN;
                    try
                        fit_win = max(1,bad_index-floor(window/2)+1) : min(bad_index+floor(window/2)-1,size(pline,1)); 
                        % try +/- half window around each bad point
                        robust_c=robustfit(fit_win,pline(fit_win,1)); 
                        % robust fit in the fit window  %similar to linear regression, but less influenced by outlier
                        pline(bad_index,1) = robust_c(2)*bad_index+robust_c(1);
                    catch ME1 % robust error on half window
                        try
                            window=window*2;
                            fit_win = max(1,bad_index-floor(window/2)+1) : min(bad_index+floor(window/2)-1,size(pline,1)); 
                            % try +/- half window around each bad point
                            robust_c=robustfit(fit_win,pline(fit_win,1)); 
                            % robust fit in the fit window  %similar to linear regression, but less influenced by outlier
                            pline(bad_index,1) = robust_c(2)*bad_index+robust_c(1);
                        catch ME2 
                            try
                                window=window*2;
                                fit_win = max(1,bad_index-floor(window/2)+1) : min(bad_index+floor(window/2)-1,size(pline,1)); 
                                % try +/- half window around each bad point
                                robust_c=robustfit(fit_win,pline(fit_win,1)); 
                                % robust fit in the fit window  %similar to linear regression, but less influenced by outlier
                                pline(bad_index,1) = robust_c(2)*bad_index+robust_c(1);
                            catch ME3
                                pline(bad_index,1)=pline(bad_index,1);
                            end
                        end
                    end

                end

            end

            if bad_num==0
                finish=1;
            end

            if loop>10
                limit=limit+5;

            elseif loop>20
                limit=limit+5;
            elseif loop>30

            elseif loop>50
                [ b1, a1 ] = butter( 9, 0.1, 'low'); % low pass butterworth filter of 9th order
                p_lowpass=filtfilt(b1, a1, pline(:,1)); %filtering
                bad_indice=find(isnan(pline(:,1)));
                pline(bad_indice,1)=p_lowpass(bad_indice,1);
                break;
            end
        end

        pline( pline(:,1)<0 | isnan(pline(:,1)) )=0;



return