function value=Load_SynTime(fname,comment_of_interest)

% Load the value of start time for synchronization.
% Each video has a meta file which recorded its 
% start time relative to tsunami generation. Synchronize
% all videos at the same relative moment to tsnunami 
% generation, which is necessary for the following ensemble
% averaging process.


        fid=fopen(fname);

        found=0;

        while ~found
            tline = fgetl(fid);
            if tline == -1 % can't find it
                error('ERROR: cannot find synchronization info!');
            else
               if strfind(tline,comment_of_interest)
                   disp(tline)
                   found=1;
                   value = textscan(tline((strfind(tline,':')+1):length(tline)),'%f');
                   value=cell2mat(value);
               end
            end
        end


        fclose(fid);
        
        
return
