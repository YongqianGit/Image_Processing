% Bore track code by Yongqian
% Definition of "bore front": the moving inundation boundary when tsunami
% runs onshore

% First part: synchronize all videos frames to the same start
% Second part: substract background from each instantaneous frame, then
% detect the bore fronts in the difference frame
% Third part: smooth bore fronts to elimiate spikes
% Forth part: calculate speed from orthogonal distances between each
% two bore fronts. Each pixel along a bore front can obtain a bore speed
% from computation, resulting in high-resolution field of velocity



clear 
fclose all;
close all

tic
dirc='./';
% Directory of video folder

im_format='.png';
fs = 59.94; %Hz, frame rate of videos
dt = 1./fs; % s

%-----------Different experimental scenarios and trials
section = 'Scenario7/';
% setup = {'S7R1T'};
% trial = {[8]};
setup={'S7R1T','S7R2T','S7R3T'};
trial={[8,9,10,14,17,18,19,22,29,31,32,33,43,44,45,47,48,51,52,55],...  %S7R1
     [3,4,6,8,9,15,16,17,18,24,25,26,27,28,33,38,40,42,43,47,48,51,52,54,57],...%S7R2
     [2,3,5,6,9,11,12,18,19,20,33,36,37,39,40,41,43,45,46,49,52,53,54]};   %S7R3
% Selected video trials for image processig
%-----------------------------------------------------

top=1;bottom=950;left=160;right=730;
% Subdomain of video view for analysis

scrsz = get(0,'ScreenSize');

for isetup = 1:size(setup,2)
    figure(22);
    set(gcf,'Position',[1 scrsz(4) scrsz(3)*0.7 scrsz(4)*0.4])
    for iall = 1:length( trial{isetup} )    
        
        trial_tmp = trial{isetup}; %to deal with discontinuous trial num of interest   
        fname_pre = [setup{isetup},num2str(trial_tmp(iall))];
        f_img = [section,fname_pre,'/'];
        f_img2 = [f_img,'plots/'];


        imavg = BackGroundAvg(dirc,f_img,f_img2,[fname_pre,'_'],1,im_format); 
        %averaged background image (gray image)
        %function imavg=BackGroundAvg(dirc,fileread,filesave,prefix,tot,format)

        imavg = imrotate(imavg,-90); %rectified


        %-----------Synchronization of all videos to the same start--------
        start_time=Load_SynTime([dirc,f_img,fname_pre,'.txt'],...
            'composite_start_from_wmstart:');
        %Load start_time for synchronization
        
        if start_time>0
            start_frame = round(fs*(1-(start_time-0.5-floor(start_time-0.5))));
        else
            abstime = abs(start_time);
            ttmp = 1-(abstime-floor(abstime));
            if ttmp < 0.5
                ttmp = 1+ttmp;
            end
            start_frame = round(fs*(1.5-ttmp));
        end 
        start_frame = start_frame + 10;%for debugging in 2014
        end_frame = start_frame + 240;  
        t = (30.5 + 10/fs) : dt : (30.5 + 10/fs + 240*dt);%time series
        %-----------Synchronization of all videos to the same start--------
        
        rev = 0; 
        % turn on manual adjustment if rev=1
        manual_prepro = 0; 
        %manual_prepro=1 to choose the range for bore tracking in the first two frames
        
        
        %% Track the bore and save the bore to .mat file


        cross_shore_save = []; %for saving the despiked bore line
        along_shore_save = [];

        for i=start_frame:end_frame
            display( sprintf('Current frame: %d', i - start_frame) );
            f_image=([dirc,f_img,fname_pre,sprintf('_%05d',i),im_format]);

            if ~exist(f_image, 'file')   
                error([f_image 'does NOT exist!']);
            else
                im = imread(f_image);  

                im = imrotate(im,-90);  
                % Rotate to let wave runs from top to bottom,
                % consistent with experimental coordinate system

                Ext_CR1=zeros(size(imavg,1),65);
                Ext_CR2=zeros(size(imavg,1),95);
                Ext_CR3=zeros(size(imavg,1),120);
                Ext_CR4=zeros(size(imavg,1),100);
                Ext_CR5=zeros(size(imavg,1),120);
                Ext_CR6=zeros(size(imavg,1),100);
                Ext_CR7=zeros(size(imavg,1),125);
                Ext_CR8=zeros(size(imavg,1),832-725);
                % Regtion of preprocessing for initial starting range
                

                
                im_gray = Adjust_Light(i, start_frame, im, imavg);
                % Adjust light contrast. Light brightness changed suddenly
                % in most vidoes during inundation in 2014
                
                msim = im_gray - imavg;
                %  Read instantaneous image and sbutract the averaged backgound
                
                
                if i==start_frame || i==start_frame+1 

                    if manual_prepro==1
                        % Manually specify initial range for tracking
                        figure(520)
                        imshow(msim);
                        hold on

                        Ext_CR = Preprocess();
                        
                    else 
                        Ext_CR1(1:140,1:end) = 1;
                        Ext_CR2(1:140,1:end) = 1;
                        Ext_CR3(1:140,1:end) = 1;
                        Ext_CR4(1:140,1:end) = 1;
                        Ext_CR5(1:140,1:end) = 1;
                        Ext_CR6(1:140,1:end) = 1;
                        Ext_CR7(1:140,1:end) = 1;
                        Ext_CR8(1:140,1:end) = 1;
                        Ext_CR = [Ext_CR1,Ext_CR2,Ext_CR3,Ext_CR4,...
                                  Ext_CR5,Ext_CR6,Ext_CR7,Ext_CR8];
                    end     
                    
                    
                else

                    Ext_CR1=Find_Range(pline_pre1(1:65,:),pline_pre2(1:65,:),Ext_CR1,3,0);
                    %(cross,along),pline(cross,along)            
                    
                    if i-start_frame>100 && i-start_frame<160
                        Ext_CR2 = Find_Range(pline_pre1(66:160,:),pline_pre2(66:160,:),Ext_CR2,7,0);
                        Ext_CR3 = Find_Range(pline_pre1(161:280,:),pline_pre2(161:280,:),Ext_CR3,7,0);
                    else
                        Ext_CR2 = Find_Range(pline_pre1(66:160,:),pline_pre2(66:160,:),Ext_CR2,3,0);
                        Ext_CR3 = Find_Range(pline_pre1(161:280,:),pline_pre2(161:280,:),Ext_CR3,3,0);
                    end
                    
                    Ext_CR4 = Find_Range(pline_pre1(281:380,:),pline_pre2(281:380,:),Ext_CR4,3,0);
                    
                    if i-start_frame>=165 && i-start_frame<220 
                        Ext_CR5 = Find_Range(pline_pre1(381:500,:),pline_pre2(381:500,:),Ext_CR5,0,40);
                    elseif i-start_frame>=220
                        Ext_CR5 = Find_Range(pline_pre1(381:500,:),pline_pre2(381:500,:),Ext_CR5,5,0);
                    elseif (i-start_frame>150 && i-start_frame<175) || (i-start_frame>190 && i-start_frame<220)
                        Ext_CR5 = Find_Range(pline_pre1(381:500,:),pline_pre2(381:500,:),Ext_CR5,7,0);
                    elseif i-start_frame>80 && i-start_frame<130
                        Ext_CR5 = Find_Range(pline_pre1(381:500,:),pline_pre2(381:500,:),Ext_CR5,0,30);
                    else               
                        Ext_CR5 = Find_Range(pline_pre1(381:500,:),pline_pre2(381:500,:),Ext_CR5,3,0);
                    end
                    
                    Ext_CR6 = Find_Range(pline_pre1(501:600,:),pline_pre2(501:600,:),Ext_CR6,3,0);
 
                    if i-start_frame>=60 && i-start_frame<195
                        if abs(mean(pline_pre2(501:600,1))-mean(pline_pre1(501:600,1)))>...
                                0.6*abs(mean(pline_pre2(660:725,1))-mean(pline_pre1(660:725,1))) ||...
                                abs(mean(pline_pre2(501:600,1))-mean(pline_pre1(501:600,1)))>...
                                0.6*abs(mean(pline_pre2(600:660,1))-mean(pline_pre1(600:660,1))) 
                            tmp_diff = abs(mean(pline_pre2(501:600,1))-mean(pline_pre1(501:600,1)));
                            Ext_CR7 = Find_Range(pline_pre1(601:725,:),pline_pre2(601:725,:),Ext_CR7,0,30);
                            Ext_CR8 = Find_Range(pline_pre1(726:end,:),pline_pre2(726:end,:),Ext_CR8,0,30);
                            Ext_CR7 = Find_Range(pline_pre1(280:-1:156,:),pline_pre2(280:-1:156,:),Ext_CR7,5,0);
                            %In case too slow, spread to left column range
                        else
                            Ext_CR7 = Find_Range(pline_pre1(601:725,:),pline_pre2(601:725,:),Ext_CR7,5,0);
                            Ext_CR8 = Find_Range(pline_pre1(726:end,:),pline_pre2(726:end,:),Ext_CR8,5,0);
                        end
                    else
                        Ext_CR7 = Find_Range(pline_pre1(601:725,:),pline_pre2(601:725,:),Ext_CR7,3,0);
                        Ext_CR8 = Find_Range(pline_pre1(726:end,:),pline_pre2(726:end,:),Ext_CR8,3,0);
                    end   
                    
                    Ext_CR=[Ext_CR1,Ext_CR2,Ext_CR3,Ext_CR4,Ext_CR5,Ext_CR6,Ext_CR7,Ext_CR8];%Ext_CR(cross,along)

                end

                msim_crop = msim;

                msim_crop = imadjust(msim_crop,[0 0.2],[0 1],1.);
                %imadjust(msim_crop,[0 0.2],[0 1],1.) for 2013

                windsz = 4; 
                % Used to build filter


                if i - start_frame > 70 && i - start_frame < 150
                    thres = 0.12;
                elseif i - start_frame >= 190 
                    thres = 0.18;
                elseif i - start_frame >= 210             
                        thres = 0.12;           
                elseif i - start_frame < 30
                    thres = 0.4;      
                else 
                    thres = 0.15;
                end
                
                msim_crop = uint8(msim_crop);
                bw0 = im2bw( msim_crop,graythresh(msim_crop).*thres );%% <-- modify this part
                % convert grayscale image to binary image using threshold. Output
                % is 1 for white and 0 for black.
                %level = graythresh(I) computes a global threshold (level) that can be used to convert an 
                %intensity image to a binary image with im2bw. level is a normalized intensity value that 
                %lies in the range [0, 1].
                %The graythresh function uses Otsu's method, which chooses the threshold to minimize the 
                %intraclass variance of the black and white pixels
                %im2bw(uint8((msim_crop)),graythresh(uint8((msim_crop))).*1.) in 2013


                if i-start_frame<45
                    bw0(:,380:500) = im2bw((msim_crop(:,380:500)),graythresh(msim_crop(:,380:500)).*0.3);
                end
                
                H2 = fspecial('average',windsz);        
                %h = fspecial(type) creates a two-dimensional filter h of the specified type. fspecial 
                %returns h as a correlation kernel, which is the appropriate form to use with imfilter. 
                %type is a string having one of these values.
                %h = fspecial('average', hsize) returns an averaging filter h of size hsize. The argument
                %hsize can be a vector specifying the number of rows and columns in h, or it can be a 
                %scalar, in which case h is a square matrix. The default value for hsize is [3 3]

                averaged_bw1 = imfilter(bw0,H2,'replicate');
                %averageD_bw1 = imfilter(averageD_bw1,H3,'replicate');
                %B = imfilter(A, H) filters the multidimensional array A with the multidimensional filter H.
                %The array A can be logical or a nonsparse numeric array of any class and dimension. The result
                %B has the same size and class as A.
                %Each element of the output B is computed using double-precision floating point. If A is an 
                %integer or logical array, then output elements that exceed the range of the integer type are
                %truncated, and fractional values are rounded.

                averaged_bw2 = averaged_bw1.*Ext_CR;
                % Only focuse on the range based on calculation from
                % previous steps, for better noise elimination

                bw3 = averaged_bw2 ;           
        

                [B,L] = bwboundaries(bw3,4,'noholes');
                %B = bwboundaries(BW) traces the exterior boundaries of objects, as well as boundaries of holes inside 
                %these objects, in the binary image BW. bwboundaries also descends into the outermost objects (parents)
                %and traces their children (objects completely enclosed by the parents). BW must be a binary image where
                %nonzero pixels belong to an object and 0 pixels constitute the background. The following figure illustrates
                %these components.
                %bwboundaries returns B, a P-by-1 cell array, where P is the number of objects and holes. Each cell in the 
                %cell array contains a Q-by-2 matrix. Each row in the matrix contains the row and column coordinates of a 
                %boundary pixel. Q is the number of boundary pixels for the corresponding region.
                %L is a two-dimensional array of nonnegative integers that represent contiguous regions. The kth region 
                %includes all elements in L that have value k. The number of objects and holes represented by L is equal 
                %to max(L(:)). The zero-valued elements of L make up the background.
                %In other word, 'L' stores the non-zero regions with counting
                %number marking the same sub-region
                
            end

            boundary=GetBoundary(B);

            horizon=1; %catch the bore line in horizontal dir.
            [bond,pline]=SortBoundary(boundary,bw3,horizon);

            window=20;
            limit=10;

            
            pline(:,1)=interp1(pline(:,2),pline(:,1),pline(1,2):pline(end,2),'spline');%for S6
            if i-start_frame>180
                if i-start_frame<220
                    out=860;in=700;
                else
                    out=865;in=780;
                end
                ind_leftout=find(pline(left-5:left+100)>out);
                ind_rightout=find(pline(right-30:right+5)>out);
                ind_leftin=find(pline(left-5:left+100)<in);
                ind_rightin=find(pline(right-30:right+5)<in);
                if ~isempty(ind_leftout)                    
                    pline(ind_leftout+(left-6))=pline_pre2(ind_leftout+(left-6));
                end
                if ~isempty(ind_rightout)
                    pline(ind_rightout+(right-31))=pline_pre2(ind_rightout+(right-31));                  
                end
                if ~isempty(ind_leftin)                    
                    pline(ind_leftin+(left-6))=pline_pre2(ind_leftin+(left-6));
                end
                if ~isempty(ind_rightin)
                    pline(ind_rightin+(right-31))=pline_pre2(ind_rightin+(right-31));                  
                end
            end  


            pline_despiked=pline;
            %set the subrange out of interest same value as raw line, does NOT affect

            pline_despiked(left-2:right+2,1)=Bore_Despike(pline(left-2:right+2,1),window,limit);
            if (i-start_frame>=75 && i-start_frame<120) || (i-start_frame>=190 && i-start_frame<215) 
            %larger limit for combined flow in middle
                if i-start_frame<120
                    tmp_limit=2*limit;                   
                elseif i-start_frame>=190
                    tmp_limit=4*limit;
                end
                pline_despiked(425:460,1)=Bore_Despike(pline(425:460,1),window,tmp_limit);
                int_out=424+find(pline_despiked(425:460,1)<pline_raw_pre(425:460,1)-2);
                if ~isempty(int_out)
                    pline_despiked(int_out,1)=pline_pre2(int_out);
                    %if too small than last bore, set to last smooth bore
                end
            end
            if i-start_frame>=125 && i-start_frame<=170
            %larger limit for combined flow in left & right
                pline_despiked(195:245,1)=Bore_Despike(pline(195:245,1),window,3*limit);
                pline_despiked(630:680,1)=Bore_Despike(pline(630:680,1),window,3*limit);
                int_outleft=194+find(pline_despiked(195:245,1)<pline_raw_pre(195:245,1)-2);
                int_outright=629+find(pline_despiked(630:680,1)<pline_raw_pre(630:680,1)-2);
                if ~isempty(int_outleft)
                    pline_despiked(int_outleft,1)=pline_pre2(int_outleft,1);
                    %if too small than last bore, set to last smooth bore
                elseif ~isempty(int_outright)
                    pline_despiked(int_outright,1)=pline_pre2(int_outright,1);
                    %if too small than last bore, set to last smooth bore    
                end
            end
            if i-start_frame>=90%for retreating flow
                if i-start_frame<210
                    retreat=3;
                else
                    retreat=2;
                end
                int_out=159+find(pline_despiked(160:730,1)<pline_raw_pre(160:730,1)-retreat);
                pline_despiked(int_out,1)=pline_pre2(int_out,1);
            end

            %pline(cross,along)
            if i-start_frame<150
                ghost=15;
                % Extended the use of raw pline points outside the left/right
                % to get nice despiking at left/right
            else 
                ghost=0;
            end
            pline_despiked(left-ghost:right+ghost,1)=interp1(pline_despiked(left-ghost:right+ghost,2),...
                pline_despiked(left-ghost:right+ghost,1),pline_despiked(left-ghost:right+ghost,2),'spline');

            [f,xi,ctun] = ksdensity(pline_despiked(left-ghost:right+ghost,1),...
                pline_despiked(left-ghost:right+ghost,2),'kernel','normal','width',5); 
            %cross_shore's column is in alongshore dir,...
            %including first element to be time

            r=ksr(pline_despiked(left-ghost:right+ghost,2),pline_despiked(left-ghost:right+ghost,1),...
            ctun,length(pline_despiked(left-ghost:right+ghost,2))) ; 
            %start from 2nd element because the 1st is time

            tmp_smooth = pline_despiked;
            tmp_smooth(left-ghost:right+ghost) = r.f';%The smoothed result for the bore line

            if i == start_frame
                pline_pre1 = tmp_smooth; %used for next frame
                pline_pre2 = pline_pre1;
            else
                pline_pre1 = pline_pre2;
                pline_pre2 = tmp_smooth;
            end
            pline_raw_pre = pline_despiked;

            %--------------------------manual adjustment----------------------------
            % Activate by setting 'rev' as 1
            pline = Manual_Adjust(rev,boundary,pline,i,dirc,f_img,f_img2,bw3);
            %-----------------------------------------------------------------------  
            
            
            %-------------------Check and create animation for presentation
                clf; 
                subplot(131); imshow(bw0);  
                axis([left, right, top, bottom])
                
                subplot(132); imshow(bw3);
                axis([left, right, top, bottom])
                
                subplot(133); hold on;
                imshow(im);                              
                plot(pline_despiked(:,2),pline_despiked(:,1),'y','linewidth',0.5)
                plot(pline_despiked(:,2),tmp_smooth(:,1),'b','linewidth',2)
                axis([left, right, top, bottom])
                
                frame = getframe(gcf);                  
                im_ani = frame2im(frame);
                [imind,cm] = rgb2ind(im_ani,256);
                
                % Use "imwrite" to create git. To create other video
                % format, use "VideoWriter" + "writeVideo"
                if i - start_frame == 0;
                    imwrite(imind,cm,'Animation_S7.gif','gif', 'Loopcount',inf);                  
                else                   
                    imwrite(imind,cm,'Animation_S7.gif','gif','WriteMode','append','DelayTime',0.1);                  
                end
                pause(0.01);
            %--------------------------------------------------------------
        
            
            cross_shore_tmp = cat(1,t(i-start_frame+1),pline_despiked(:,1)); 
            %cross-shore coordinates. first element is time
            along_shore_tmp = cat(1,t(i-start_frame+1),pline_despiked(:,2)); 
            %alongshore coordinates. first element is time

            cross_shore_save = cat(2,cross_shore_save,cross_shore_tmp); 
            %cross_shore_save(alonghore, time series)

        end


        boreline{1,1} = cross_shore_save;
        boreline{1,2} = along_shore_tmp;
        %alongshore coordinates. first element is the last time step
        
        save([dirc,f_img,fname_pre,'_boreline'],'boreline');




        %% Load the saved bore or continue last code cell to smooth the bore


        %clf(figure(1))
        figure(233)
        clf(figure(233))
        frame_num = end_frame;
        
        top = 1 + 1;
        bottom = 950 + 1;
        left = 160 + 1;
        right = 730 + 1;
        %+1 because the first element is time 
        
        figure(233);imshow(imavg(top-1:bottom-1,left-1:right-1));hold on;

        
        if exist([dirc,f_img,fname_pre,'_boreline.mat'],'file')
            load([dirc,f_img,fname_pre,'_boreline.mat']);
        else 
            error('Bore front file NOT found!');
        end

        cross_shore_smooth_save=[];
        along_shore_smooth_save=[];

        cross_shore=boreline{1,1};
        along_shore=boreline{1,2};
        cross_shore_smooth=cross_shore;
        along_shore_smooth=along_shore;

        for i=1:1:frame_num-start_frame+1
            
            if i<150            
                ghost=15;                
            else                
                ghost=2;                
            end
            
            [f,xi,ctun] = ksdensity(cross_shore(left-ghost:right+ghost,i),...
            along_shore(left-ghost:right+ghost),'kernel','normal','width',5);
            %cross_shore's column is in alongshore dir,...
            %including first element to be time
                       
            r=ksr(along_shore(left-ghost:right+ghost),cross_shore(left-ghost:right+ghost,i),...
            ctun,length(along_shore(left-ghost:right+ghost))) ; 
            %start from 2nd element because the 1st is time
                        
            cross_shore_smooth(left-ghost:right+ghost,i) = r.f';
            %The smoothed result for the bore line
            
            cross_shore_smooth(1,i) = cross_shore(1,i);%time
            
            along_shore_smooth=along_shore(:);
            
            cross_shore_smooth_save=cat(2,cross_shore_smooth_save,cross_shore_smooth(:,i));
            %cross_shore_smooth_save(alonghore, time series)
            
        %{/           
           plot(along_shore_smooth(left:right)-left+2,cross_shore_smooth(left:right,i),'b');    
        %}            

        end
        
        boreline_smooth{1,1}=cross_shore_smooth_save;        
        boreline_smooth{1,2}=along_shore_smooth;
        save([dirc,f_img,fname_pre,'_boreline_smooth'],'boreline_smooth');
        print('-depsc','-r250',[dirc,'bore_lines_smooth.eps'])



        %% Calculate the velcoty from detected bore fronts
        
        %{/
        along_shore_tracking=[left : right] + 1;%+1 because the first element of bore_back is time 
        
        t = cross_shore(1,:);
        interval = 1;
        figure(2);
        imshow(imavg(top-1:bottom-1,left-1:right-1));
        hold on;
        
        combine=1;%used for strong combine flow velocity

        neighbor=1; % num of points in alongshore dir to calculate slope of the bore at one point
        %load([dirc,f_img,fname_pre,'_velocity.mat']);
        
        velocity = cell( length(along_shore_tracking), 3);
        
        for icount=1:length(along_shore_tracking)
            d_cross = zeros(length(t)-1,1);%crossshore displacement between 2 frames
            d_along = zeros(length(t)-1,1);%alongshore displacement between 2 frames
            u = zeros(length(t)-1,1);%crossshore velocity between 2 frames
            v = zeros(length(t)-1,1);%alongshore velocity between 2 frames
            itrack = along_shore_tracking(icount); %along shore position to calculate velocity

            for it=1:frame_num-start_frame %time series

                bore_back(:,1) =along_shore_smooth(2:end);%last bore
                bore_back(:,2) =cross_shore_smooth(2:end,it);
                bore_front(:,1)=along_shore_smooth(2:end);% next bore
                bore_front(:,2)=cross_shore_smooth(2:end,it+interval);
      
                speedlimit = 5.5;
                [along_crossing,cross_crossing,along_norm_fit,cross_norm_fit] = ...
                Find_Crossing(itrack,bore_back,bore_front,interval,dt,speedlimit,combine,it);

                cross_back = bore_back(itrack,2);%point on back bore for velocity calculation
                along_back = bore_back(itrack,1);

                cross_front = cross_crossing;
                along_front = along_crossing;

                d_cross(it) = cross_front-cross_back;%delta crossshore
                d_along(it) = along_front-along_back;%delta alongshore

                u(it) = d_cross(it)*0.01/(interval*dt); % 1 pix/cm
                v(it) = d_along(it)*0.01/(interval*dt); % 1 pix/cm


         %=================================plot velocity   
         %{/
                if (icount==1)
                    if mod(it,1+interval) == 1                                
                        plot(along_shore_smooth(left:right)-left+2,cross_shore_smooth(left:right,it),'r');
                    end
                end

                if mod(icount,10) == 1 && mod(it,5) == 1
                    quiver(along_back-left+2,cross_back,v(it),u(it),10,'c');%bore_back has no time component in first element       
                    plot(along_norm_fit-left+2,cross_norm_fit,'g:')
                    plot(along_front-left+2,cross_front,'ko','MarkerSize',1.5)
                    plot(along_back-left+2,cross_back,'mo','MarkerSize',1.5)
                end
         
         %=================================plot velocity       
            end

            velocity{icount,1} = t(1:end-1)';
            velocity{icount,2} = u;
            velocity{icount,3} = v;



        end
        save([dirc,f_img,fname_pre,'_velocity'],'velocity');

        print('-depsc','-r250',[dirc,'/bore_lines_quiver','.eps'])
        %}

        
    end



end
toc

