% CLEANUP from ExperimentSettings.m (removing redundant and confusing settings variables)

if settings.VariableFixationDur
    % Remove constant fixation duration setting if a variable fixation
    % duration has been indicated
    settings = rmfield(settings,'FixationDur');
else
    % If variable fixation duration has not been indicated, remove settings
    % for fixation duration distribution parameters
    settings = rmfield(settings, 'FixDurMean');
    settings = rmfield(settings, 'FixDurMin');
    settings = rmfield(settings, 'FixDurMax');
end