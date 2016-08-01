function Ext_CR = Preprocess()

% Manually specify initial range for tracking.
% In the figure, the whole domain is divided into
% 8 sub-regions in horizontal direction. In each
% sub-region, use mouse to pick up a left-top and
% a right-bottom locations to define the sub-range
% for each sub-region to start with.

        
        plot([65,65],[1,1000],'r')
        plot([160,160],[1,1000],'r')
        plot([280,280],[1,1000],'r')
        plot([380,380],[1,1000],'r')
        plot([500,500],[1,1000],'r')
        plot([600,600],[1,1000],'r')
        plot([725,725],[1,1000],'r')

        Chosen_Region=ginput(16); 
        % Choose the region of the bore by user in the first image. 
        % Will only use the left-up and right-bottom points

        row_leftup1=Chosen_Region(1,2);
        row_rightbottom1=Chosen_Region(2,2);
        Ext_CR1(row_leftup1:row_rightbottom1,1:end)=1;

        row_leftup2=Chosen_Region(3,2);
        row_rightbottom2=Chosen_Region(4,2);
        Ext_CR2(row_leftup2:row_rightbottom2,1:end)=1;

        row_leftup3=Chosen_Region(5,2);
        row_rightbottom3=Chosen_Region(6,2);
        Ext_CR3(row_leftup3:row_rightbottom3,1:end)=1;

        row_leftup4=Chosen_Region(7,2);
        row_rightbottom4=Chosen_Region(8,2);
        Ext_CR4(row_leftup4:row_rightbottom4,1:end)=1;

        row_leftup5=Chosen_Region(9,2);
        row_rightbottom5=Chosen_Region(10,2);
        Ext_CR5(row_leftup5:row_rightbottom5,1:end)=1;

        row_leftup6=Chosen_Region(11,2);
        row_rightbottom6=Chosen_Region(12,2);
        Ext_CR6(row_leftup6:row_rightbottom6,1:end)=1;

        row_leftup7=Chosen_Region(13,2);
        row_rightbottom7=Chosen_Region(14,2);
        Ext_CR7(row_leftup7:row_rightbottom7,1:end)=1;

        row_leftup8=Chosen_Region(15,2);
        row_rightbottom8=Chosen_Region(16,2);
        Ext_CR8(row_leftup8:row_rightbottom8,1:end)=1;

        Ext_CR=[Ext_CR1,Ext_CR2,Ext_CR3,Ext_CR4,Ext_CR5,Ext_CR6,Ext_CR7,Ext_CR8];


return