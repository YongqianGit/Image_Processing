function imavg = BackGroundAvg(dirc,fileread,filesave,prefix,tot,format)

% Read 'tot' background photos and average them to create
% a reference background frame.
% 'tot == 1' is sufficient.

for cnt = 1:tot
    
    fname = [dirc,fileread,prefix,num2str(cnt,'%05d'),format];
    
    if ~exist(fname, 'file')        
        error([fname ' does NOT exist!'])
    else
            im = double(imread(fname)); 

            if cnt==1; 
                imtot = (zeros(size(im)));                    
            end

            imtot =imtot+im;
            if cnt <=tot;  %Take average of 'tot' figures to make a backgroup pic
                eval(['im',num2str(cnt,'%02d'),' = uint8(im) ;'])
            end

            if cnt==tot;

                if ~exist([dirc,filesave],'dir'); mkdir([dirc,filesave]); end
                
                imavg = imtot/cnt;
                imavg = rgb2gray(uint8(imavg));
                imwrite(imavg,[dirc,filesave,'img_avrg.tif']); %write imavg to img_avrg.tif

            end
           
    end

    
end
