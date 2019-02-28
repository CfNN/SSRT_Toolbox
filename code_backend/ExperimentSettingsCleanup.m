% CLEANUP from ExperimentSettings.m (removing redundant and confusing settings variables)

settings.QuitKeyCodes = zeros(1, numel(settings.QuitKeyNames));
for n = 1:numel(settings.QuitKeyNames)
    settings.QuitKeyCodes(n) = KbName(settings.QuitKeyNames{n});
end

settings.RespondLeftKeyCodes = zeros(1, numel(settings.RespondLeftKeyNames));
for n = 1:numel(settings.RespondLeftKeyNames)
    settings.RespondLeftKeyCodes(n) = KbName(settings.RespondLeftKeyNames{n});
end

settings.RespondRightKeyCodes = zeros(1, numel(settings.RespondRightKeyNames));
for n = 1:numel(settings.RespondRightKeyNames)
    settings.RespondRightKeyCodes(n) = KbName(settings.RespondRightKeyNames{n});
end

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