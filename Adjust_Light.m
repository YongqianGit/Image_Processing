function im_gray = Adjust_Light(i, start_frame, im, imavg)

% Adjust color contrast because the videos of 2014
% changed light brightness suddenly during tsunami
% inundation.
% Still NOT clean at the moment. Needs optimization 
% in future...


        %-----------------------color contract rectification for year 2014
        color_rec_top = 510;
        rec_left = 240 + 160;
        rec_right = 310 + 160;
        rec_top = 920;
        rec_bottom = 950;
        %-----------------------color contract rectification for year 2014

        
        rec_avg_down = imavg(rec_top:rec_bottom,rec_left:rec_right);
        rec_avg_up = imavg(color_rec_top-30:color_rec_top,rec_left:rec_right);
        im_gray = rgb2gray(uint8(im));
        rec_im_gray_down = im_gray(rec_top:rec_bottom,rec_left:rec_right);
        rec_im_gray_up = im_gray(color_rec_top-50:color_rec_top,rec_left:rec_right);
        if mean(mean(rec_avg_down)) - mean(mean(rec_im_gray_down))<4 && i-start_frame<110           
            im_gray(color_rec_top:end,:) = im_gray(color_rec_top:end,:)*0.98;
            
        elseif mean(mean(rec_avg_down)) - mean(mean(rec_im_gray_down))>4 &&...
                i-start_frame>=110 && mean(mean(rec_avg_down))<170         
            im_gray(color_rec_top:end,1:305) = im_gray(color_rec_top:end,1:305)*...
                (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.99);    
            im_gray(color_rec_top:end,600:end) = im_gray(color_rec_top:end,600:end)*...
                (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.99);    
            
        elseif mean(mean(rec_avg_down)) - mean(mean(rec_im_gray_down))<2 && i-start_frame<145   
                im_gray(color_rec_top:end,:) = im_gray(color_rec_top:end,:)*...
                (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.98);
            
        elseif mean(mean(rec_avg_down)) - mean(mean(rec_im_gray_down))<3 && i-start_frame>=145
                im_gray(color_rec_top:end,1:600) = im_gray(color_rec_top:end,1:600)*...
                (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.99);
                im_gray(color_rec_top:end,600:end) = im_gray(color_rec_top:end,600:end)*...
                (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.99);
            if i-start_frame>210
                im_gray(color_rec_top:end,380:500) = im_gray(color_rec_top:end,380:500)*0.99;
            end
        end
        
        rec_im_gray_down=im_gray(rec_top:rec_bottom,rec_left:rec_right);
        
        if i-start_frame>=10
            im_gray(813:815,400:480)=im_gray(813:815,400:480)*0; 
            im_gray(720:723,400:480)=im_gray(720:723,400:480)*0;
            im_gray(595:597,430:600)=im_gray(595:597,430:600)*0;
            im_gray(207:209,555:580)=im_gray(207:209,555:580)*0;
             if i-start_frame<200
                 im_gray(815:854,605:725)=im_gray(815:854,605:725)*...
                     (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.95);%minimize effect of pipes
             end
             if i-start_frame>85 && i-start_frame<120
                 im_gray(540:595,400:490)=im_gray(540:595,400:490)*...
                     (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.99);
             end
             if  mean(mean(rec_avg_down))>170 && i-start_frame>105 && i-start_frame<130 %minimize effect of pipes
                 im_gray(660:720,440:500)=im_gray(660:720,440:500)*...
                     (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.95);      
             end
             if i-start_frame>80 
                 im_gray(855:end,160:280)=im_gray(855:end,160:280)*...
                     (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.95);%minimize effect of pipes
                 im_gray(855:end,605:725)=im_gray(855:end,605:725)*...
                     (mean(mean(rec_avg_down))/mean(mean(rec_im_gray_down))*0.95);%minimize effect of pipes
             end
        end

        if mean(mean(rec_avg_up)) - mean(mean(rec_im_gray_up))>4 && i-start_frame<85            
            im_gray(1:color_rec_top,:)=im_gray(1:color_rec_top,:)*...
            (mean(mean(rec_avg_up))/mean(mean(rec_im_gray_up))*0.98); 
            im_gray(390:color_rec_top,160:280)=im_gray(390:color_rec_top,160:280)*0.95; %minimize effect of pipes
            im_gray(390:color_rec_top,600:720)=im_gray(390:color_rec_top,600:720)*0.98; %minimize effect of pipes
            im_gray(160:260,380:510)=im_gray(160:260,380:510)*...
            (mean(mean(rec_avg_up))/mean(mean(rec_im_gray_up))*0.8); %minimize effect of pipes
        
        elseif mean(mean(rec_avg_up)) - mean(mean(rec_im_gray_up))<2 && i-start_frame<85
            im_gray(1:color_rec_top,:)=im_gray(1:color_rec_top,:)*...
                (mean(mean(rec_avg_up))/mean(mean(rec_im_gray_up))*0.99);
            
        elseif (i-start_frame<80 && i-start_frame>=70) 
            im_gray(1:color_rec_top,601:end)=im_gray(1:color_rec_top,601:end)*...
                (mean(mean(rec_avg_up))/mean(mean(rec_im_gray_up))*0.98);
            im_gray(1:color_rec_top,66:280)=im_gray(1:color_rec_top,66:280)*...
                (mean(mean(rec_avg_up))/mean(mean(rec_im_gray_up))*0.98);
        end               

return