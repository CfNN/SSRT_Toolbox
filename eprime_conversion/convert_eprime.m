function [trials, settings, subjectNumber, sessionNumber, sessionStartDateTime, triggerTimestamp] = convert_eprime(T, headervars)
% CONVERT_EPRIME - generates session file variables from a Table variable 
% produced using ePrimeTxt2vars.m on a text file from an E-Prime experiment
% session. The ePrimeTxt2vars function was provided by GitHub user yuval-harpaz
% (https://github.com/yuval-harpaz)

    TS = table2struct(T);
    
    % Rename specific fields of headervars that are repeated or have dots
    LevelNameNum = 1;
    for i = 1:size(headervars, 1)
        if strcmpi(headervars{i, 1}, 'DataFile.Basename')
            headervars{i, 1} = 'DataFileBasename';
        elseif strcmpi(headervars{i, 1}, 'Display.RefreshRate')
            headervars{i, 1} = 'DisplayRefreshRate';
        elseif strcmpi(headervars{i, 1}, 'LevelName')
            headervars{i, 1} = [headervars{i, 1} num2str(LevelNameNum)];
            LevelNameNum = LevelNameNum + 1;
        end 
    end
    headervars = cell2struct(headervars(:, 2), headervars(:, 1), 1);
    
    subjectNumber = str2double(headervars.Subject);
    sessionNumber = str2double(headervars.Session);
    sessionStartDateTime = headervars.SessionStartDateTimeUtc;
    triggerTimestamp = getSingleVal('SayWaiting__RTTime', T);
    settings.ExperimentName = headervars.Experiment;
    settings.FixationDur = getSingleVal('FixationDur', T);
    settings.StopSignalDur = getSingleVal('InhDur', T);
    settings.TrialDur = getSingleVal('TrialDur', T);
    settings.BlankDur = getSingleVal('BlankDur', T);
    
    TS_RowInds_all = find(~cellfun(@isempty,   table2cell(T(:, {'StopBlock'}))  ));
    trials_RowInds_all = 1:numel(TS_RowInds_all);
    n_trials = numel(TS_RowInds_all);
    trials(n_trials) = struct();
    
    trials = setTrialProcedureVals(trials, TS_RowInds_all, {'Go__OnsetTime', 'Go1s__OnsetTime', 'Go1s2__OnsetTime'}, TS);
    trials = setTrialVals(trials, trials_RowInds_all, TS_RowInds_all, 'Stimulus', 'Stimulus', TS);
    trials = setTrialVals(trials, trials_RowInds_all, TS_RowInds_all, 'CorrectAnswer', 'CorrectAnswer', TS);
    trials = setTrialValsCollapseCols(trials, TS_RowInds_all, 'Answer', {'Go__RESP', 'Go1s__RESP', 'Go1s2__RESP', 'Go2s__RESP', 'Go2s2__RESP', 'Inhs__RESP', 'Inhs2__RESP'}, TS, false, false);
    
    % These are placeholders, they will be set in a loop later
    trials(1).CorrectAnswer = [];
    trials(1).Correct = [];
    trials(1).GoRT = [];
    trials(1).SSD_intended = [];
    trials(1).SSD_actual = [];
    
    trials = setTrialValsCollapseCols(trials, TS_RowInds_all, 'GoSignalOnsetTimestamp', {'Go__OnsetTime', 'Go1s__OnsetTime', 'Go1s2__OnsetTime'}, TS, false, true);
    trials(1).GoSignalOffsetTimestamp = []; % Placeholder - included for completeness
    trials = setTrialValsCollapseCols(trials, TS_RowInds_all, 'StopSignalOnsetTimestamp', {'Inhs__OnsetTime', 'Inhs2__OnsetTime'}, TS, false, true);
    trials(1).StopSignalOffsetTimestamp = []; % Placeholder - included for completeness
    trials = setTrialValsCollapseCols(trials, TS_RowInds_all, 'ResponseTimestamp', {'Go__RTTime', 'Go1s__RTTime', 'Go1s2__RTTime', 'Go2s__RTTime', 'Go2s2__RTTime', 'Inhs__RTTime', 'Inhs2__RTTime'}, TS, true, false);
    
    trials = setTrialVals(trials, trials_RowInds_all, TS_RowInds_all, 'GoDur', 'GoDur', TS);
    trials = setTrialVals(trials, trials_RowInds_all, TS_RowInds_all, 'GoDur2', 'GoDur2', TS);
    for t = 1:n_trials
        if trials(t).Answer == trials(t).CorrectAnswer
            trials(t).Correct = true;
        else
            trials(t).Correct = false;
        end
        
        trials(t).GoRT = trials(t).ResponseTimestamp - trials(t).GoSignalOnsetTimestamp;
        
        if strcmpi(trials(t).Procedure, 'StGTrial')
            trials(t).SSD_intended = NaN;
        elseif strcmpi(trials(t).Procedure, 'StITrial')
            trials(t).SSD_intended = trials(t).GoDur;
        elseif strcmpi(trials(t).Procedure, 'StITrial2')
            trials(t).SSD_intended = trials(t).GoDur2;
        end
        
        trials(t).SSD_actual = trials(t).StopSignalOnsetTimestamp - trials(t).GoSignalOnsetTimestamp;
        
        if isempty(trials(t).SSD_actual)
            trials(t).SSD_actual = NaN;
        end
        if isempty(trials(t).GoRT)
            trials(t).GoRT = NaN;
        end
        if isempty(trials(t).CorrectAnswer)
            trials(t).CorrectAnswer = 0;
        end
        if isempty(trials(t).Answer)
            trials(t).Answer = 0;
        end
        if isempty(trials(t).StopSignalOnsetTimestamp)
            trials(t).StopSignalOnsetTimestamp = NaN;
        end
        if isempty(trials(t).ResponseTimestamp)
            trials(t).ResponseTimestamp = NaN;
        end
        
        % Convert from ms (EPrime) to s (MATLAB). **Leave timestamps alone
        trials(t).GoRT = trials(t).GoRT/1000;
        trials(t).SSD_intended = trials(t).SSD_intended/1000;
        trials(t).SSD_actual = trials(t).SSD_actual/1000;
        
        % Offset timestamps for go and stop signals are not recorded by 
        % E-Prime. They could be calculated with some difficulty, but that
        % is not done so here due to the near irrelevance of these data
        % points (redundant with fields such as ResponseTimestamp,
        % settings.TrialDur, and settings.StopSignalDur).
        trials(t).GoSignalOffsetTimestamp = NaN; 
        trials(t).StopSignalOffsetTimestamp = NaN;
    end
    trials = rmfield(trials, 'GoDur');
    trials = rmfield(trials, 'GoDur2');
    
end

function trials = setTrialProcedureVals(trials, TS_RowInds_all, TS_fieldnames, TS)
    cellvars = getVarsAsCell(TS_fieldnames, TS_RowInds_all, TS);
    
    TS_ProcNames = {'StGTrial', 'StITrial', 'StITrial2'};

    for r = 1:size(cellvars, 1)
        valCount = 0;
        for c = 1:size(cellvars, 2)
            if ~isempty(cellvars{r, c}) && cellvars{r, c} ~= 0
                valCount = valCount + 1;
                trials(r).Procedure = TS_ProcNames{c};
            end
        end
        assert(valCount < 2, ['More than 1 non-empty cell in row ' num2str(r)]);
    end
    
end

function val = getSingleVal(T_fieldname, T)
    val = cell2mat(table2array(T(   ~cellfun(@isempty,   table2cell(T(:, {T_fieldname}))  )   , {T_fieldname})));
    if numel(val) > 1
        val = val(1);
    end
end

function trials = setTrialVals(trials, trials_RowInds, TS_RowInds, trials_fieldname, TS_fieldname, TS)
    temp = {TS(TS_RowInds).(TS_fieldname)};
    [trials(trials_RowInds).(trials_fieldname)] = deal(temp{:});
end

function trials = setTrialValsCollapseCols(trials, TS_RowInds_all, trials_fieldname, TS_fieldnames, TS, ignoreZeros, assert1val)
    cellvar = collapseCellVars(getVarsAsCell(TS_fieldnames, TS_RowInds_all, TS), ignoreZeros, assert1val);
    [trials(:).(trials_fieldname)] = deal(cellvar{:});
end

function cellvars = getVarsAsCell(TS_fieldnames, TS_RowInds_all, TS)
    
    n_trials = numel(TS_RowInds_all);
    cellvars = cell(n_trials, numel(TS_fieldnames));
    
    for f = 1:numel(TS_fieldnames)
        cellvars(:, f) = {TS(TS_RowInds_all).(TS_fieldnames{f})};
    end
end

function cellvar = collapseCellVars(cellvars, ignoreZeros, assert1val)

cellvar = cell(size(cellvars, 1), 1);

    for r = 1:size(cellvars, 1)
        valCount = 0;
        for c = 1:size(cellvars, 2)
            if ~isempty(cellvars{r, c}) && (~ignoreZeros || cellvars{r, c} ~= 0)
                valCount = valCount + 1;
                cellvar{r} = cellvars{r, c};
                if ~assert1val
                    break;
                end
            end
        end
        assert(valCount < 2, ['More than 1 non-empty cell in row ' num2str(r)]);
    end
    
end