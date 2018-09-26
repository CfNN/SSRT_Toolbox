function [trials, settings, subjectNumber, sessionNumber, subjectHandedness, sessionStartDate] = convert_eprime(T, headervars)
    %[T,headervars] = eprimetxt2vars(['eprime_input/' filename]);
    
    % Rename fields of headervars with dots
    i = find(not(cellfun('isempty',  strfind(headervars(:, 1), 'DataFile.Basename')  )));
    headervars{i, 1} = 'DataFileBasename';
    i = find(not(cellfun('isempty',  strfind(headervars(:, 1), 'Display.RefreshRate')  )));
    headervars{i, 1} = 'DisplayRefreshRate';
    
    headervars = cell2struct(headervars(12:end, 2), headervars(12:end, 1), 1);
    
    
    % subjectNumber = cell2mat(table2array(T(   ~cellfun(@isempty,   table2cell(T(:, {'Subject'}))  )   , {'Subject'})));
    
    subjectNumber = headervars.Subject;
    sessionNumber = headervars.Session;
    % TODO handedness? "Group" in headervars?
    
    settings.FixationDuration = cell2mat(table2array(T(   ~cellfun(@isempty,   table2cell(T(:, {'FixationDuration'}))  )   , {'FixationDuration'})));
    
    
    trialRowInds = find(~cellfun(@isempty,   table2cell(T(:, {'StopBlock'}))  ));
    n_trials = numel(trialRowInds);
    
    trials(n_trials) = struct();
    
    temp = table2cell(   (T(trialRowInds, {'Stimulus'}))  );
    [trials.Stimulus] = deal(temp{:});
    
    temp = table2cell(   (T(trialRowInds, {'Go__OnsetTime'}))  );
    [trials.GoSignalOnsetTimestamp] = deal(temp{:});
    
end