function out = get_features_running(y, fs, ...
    show_progress, fragment_length, F0_min, F0_max)

% INPUT
% x ... vector of samples
% fs ... sampling frequency

% SETUP (optional)
% show_progress     -> print the info about fragments processed 
%                      (default = true)
% fragment_length   -> limit of fragment length to process phonation [s]
%                      (default = 0.1)
% F0_min            -> minimum fundamental frequency for voicing
%                      (default = 75)
% F0_max            -> maximum fundamental frequency for voicing 
%                      (default = 400)


% OUTPUT
% out.CPP ... mean value of cepstral peak prominence
% out.HRF ... mean value of harmonic richness factor
% out.NAQ ... mean value of normalised amplitude quotient
% out.QOQ ... mean value of quasi opened quotient
% out.Jitter ... mean value of five-point Period Perturbation Quotient
% out.Shimmer ... mean value of five-point Amplitude Perturbation Quotient


%% setup

if nargin < 3 || isempty(show_progress)
    show_progress = false;
end

if nargin < 4 || isempty(fragment_length)
    fragment_length = 0.1;
end

if nargin < 5 || isempty(F0_min)
    F0_min = 75;
end

if nargin < 6 || isempty(F0_max)
    F0_max = 400;
end

addpath(genpath([pwd '\external\' 'Praat']))
addpath(genpath([pwd '\external\' 'Covarep']))
addpath(genpath([pwd '\external\' 'Troparion']))

%% ---------------------------- process -------------------------------- %%

y = y(:,1);
y = y(find(y,1,'first'):find(y,1,'last'));
vad = praat_VAD(y, fs, [], F0_min, [], [], length(y));

%% ----------------------------- Phonation -------------------------------%

voiced = praat_voicing(y, fs, F0_min, F0_max, length(y));

y_clear = (vad.*y.*voiced)';

i0 = diff(strfind([0,y_clear,0],0));
y_frag = mat2cell(y_clear(y_clear ~= 0),1,i0(i0 > 1) - 1);

n_fragments_longer = 0;
n_fragments = length(y_frag);

% ------------------- loop through voiced fragments -------------------

if show_progress
    disp(['Processing a recording: (' num2str(length(y_frag)) ...
          ') voiced fragments in total'])
end

for fragment = 1:length(y_frag)

    matrix_mean{fragment}=NaN([1, 6]);
    matrix_std{fragment}=NaN([1, 6]);

    y_short = (y_frag{fragment})';

    if length(y_short) < fs*fragment_length
            continue
    end
    n_fragments_longer = n_fragments_longer + 1;
    
    %---- Cepstral peak prominance

    CPP = cpp(y_short, fs);

        if isempty(CPP)
            CPP = NaN;
        end
        matrix_mean{fragment}(1,1) = mean(CPP(:,1));

    % Glottal Analysis

    [glot] = glottal(y_short,fs);

        %---- Harmonic richness factor 
    
        if isempty(glot.HRF)
            glot.HRF = NaN;
        end
        matrix_mean{fragment}(1,2) = mean(glot.HRF);
        
        %---- Normalised amplitude quotient
    
        if isempty(glot.NAQ)
            glot.NAQ = NaN;
        end
        matrix_mean{fragment}(1,3) = mean(glot.NAQ);
    
        %---- Quasi-open quotient
    
        if isempty(glot.QOQ)
            glot.QOQ = NaN;
        end
        matrix_mean{fragment}(1,4) = mean(glot.QOQ);
    
    % Perturbations

    [per] = F0_perturbations(y_short,fs,'speech');

        %---- Jitter (PPQ)

        if isempty(per.J_ppq5)
            per.J_ppq5 = NaN;
        end
        matrix_mean{fragment}(1,5) = per.J_ppq5;


        %---- Shimmer (APQ)

        if isempty(per.S_apq5)
            per.S_apq5 = NaN;
        end
        matrix_mean{fragment}(1,6) = per.S_apq5;


    if show_progress
        disp([num2str(n_fragments_longer) ' fragments longer than ',...
            num2str(fragment_length) ' s'])
    end

end

% calculate the mean value from voiced fragments

labels_desc = {[],[],[],[],[],[]};

for c = 1:size(matrix_mean{1},2)
    clear vector
    v = 0;
    for m = 1:n_fragments
       if ~isnan(matrix_mean{m}(1,c))
           v = v+1;
           vector(v)=matrix_mean{m}(1,c);
       end
    end
    if exist('vector', 'var')
        labels_desc{1,c} = mean(vector);
    end
end  

if (n_fragments_longer) == 0 && show_progress
    disp(['No fragments longer than ', num2str(fragment_length) ' s'])
end

out.CPP = labels_desc{1,1};
out.HRF = labels_desc{1,2};
out.NAQ = labels_desc{1,3};
out.QOQ = labels_desc{1,4};
out.Jitter = labels_desc{1,5};
out.Shimmer = labels_desc{1,6};
