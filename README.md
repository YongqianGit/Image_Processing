#------------------Basic Info------------------
Automatic detection of tsunami inundation lines from videos and bore speed
computation


##Project: NEES tsunami project in Oregon State University in 2013 and 2014.

The image processing codes are developed using MATLAB by Yongqian Yang as part
of Ph.D. research in Coastal Engineering. The codes analyze the videos of
experimental tsunami inundation frame by frame, and automatically detact the
inundation boundaries (i.e., bore fronts) in each instantaneous frame. The codes
also compute the speed of tsunami inundation from the videos.

"Bore_track_YY_2014_debug" is the main algorithm for bore-front detection and
tsunami speed computation, while the other files are functions called in the main algorithm.

##The main steps are:
      1. Synchronize all videos frames to the same start
      2. Substract background from each instantaneous frame, then detect the bore fronts in the difference frame
      3. Smooth bore fronts to elimiate spikes
      4. Calculate speed from orthogonal distances between each two bore fronts. Each pixel along a bore front can obtain a bore speed from computation, resulting in high-resolution field of velocity

