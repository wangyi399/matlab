function calc_sta(path2stimfile, path2analysis)

[wn_movie_name, stix_size] = get_wn_movie_names(path2stimfile);
tmp = dir([path2analysis, 'data*']);

for i=1:length(tmp)

    datapath = fullfile(path2analysis,  tmp(i).name);
    
    if ~isempty(wn_movie_name{i}) % calculate sta
        if stix_size(i)<3
            config_file = 'primate-1cone_ath.xml';
            my_command = ['/Volumes/Lab/Development/scripts/grind -p -c /Volumes/Lab/Development/vision-xml/current/', config_file,...
            ' ', datapath, ' ', wn_movie_name{i}];
        else
            config_file = 'primate_ath.xml';
            my_command = ['/Volumes/Lab/Development/scripts/grind -l -c /Volumes/Lab/Development/vision-xml/current/', config_file,...
                ' ', datapath, ' ', wn_movie_name{i}];
        end
    else % make params file
        my_command = ['/Volumes/Lab/Development/scripts/vision-calc-grind ',...
            '''Make Parameters File'' ''MainFilePath::/', datapath, ''' ',...
            '''nThreads::10'' ''STAFitCalculator::false'' ''TimeCourseCalculator::false'' ''AutoCalculator::false'''];
    end
    system(my_command);
end
