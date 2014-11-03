function stimulus = stimulus_from_java_movie(movie)
% stimulus_from_java_movie     get stimulus information from an java movie object
%
% usage:  stimulus = stimulus_from_java_movie(movie)
%
% arguments:  movie - java object generated by edu.ucsc.neurobiology.vision.matlab.Matlab.computeMovie(<xml_path>,<triggers>)
%
% outputs:     stimulus - struct with the following fields
%
% stimulus.field_height     # of stixels top to bottom
% stimulus.field_width      # of stixels left to right
% stimulus.interval         # of monitor updates per stimulus refresh
% stimulus.independent      'nil' or 't'
% stimulus.separated        field only created if 't'
% stimulus.type             ':gaussian' or ':binary'
% stimulus.seed             initial seed, e.g. 11111
% 
%
%
% gauthier 2009-09
%
%




% assume monitor_refresh_rate is 120 Hz
% in the future, there should be a separate place to specify this so that it can vary
monitor_refresh_rate = 120;  % Hz

% refresh interval
stimulus.interval = round(movie.getRefreshTime * monitor_refresh_rate / 1000);

% X and Y size
stimulus.field_height = movie.getHeight;
stimulus.field_width = movie.getWidth;

% seed
stimulus.seed = movie.getUnderlyingMovie.startSeed;

% color
switch movie.getUnderlyingMovie.colorType.toString.toCharArray'
    case 'INDEPENDENT'
        stimulus.independent = 't';
    case 'DEPENDENT'
        stimulus.independent = 'nil';
    case 'SEPARATED'
        stimulus.independent = 't';
        stimulus.separated = 't';
    otherwise
        error('Color type ''%s'' not recognized.',movie.getUnderlyingMovie.colorType.toString.toCharArray')
end

% noise type
switch movie.getUnderlyingMovie.noiseType.toString.toCharArray'
    case 'GAUSSIAN_MOVIE'
        stimulus.type = ':gaussian';
    case 'BINARY_MOVIE'
        stimulus.type = ':binary';
    otherwise
        error('Noise type ''%s'' not recognized.',movie.getUnderlyingMovie.noiseType.toString.toCharArray')
end

% random number generator
%   nowhere to store this...
switch movie.getUnderlyingMovie.rng.toString.toCharArray'
    case 'JAVA_RANDOM_V2'
        
    case 'MAC_RANDOM'
        fprintf('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n   NOTE: this movie uses the mac random number generator\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
    otherwise
        error('Random number generator type ''%s'' not recognized.',movie.getUnderlyingMovie.rng.toString.toCharArray')
end

% contrast
% NOTE: contrast can be different on each gun, but the movie assumes the contrast is the same on every gun
% therefore this value can not be trusted.  The value is obtained by movie.getUnderlyingMovie.contrastValue

