function VisualizeSessions(filenames)
% VISUALIZESESSION - Generates various plots for exploratory data analysis,
% based on data from one or more experiment sessions. Note that you are 
% responsible for ordering the filenames as you want them displayed in the 
% plots, and ensuring that each file represents a whole, single session.  
%
% filenames: A cell array of the names of files in session_files to be used
% to generate the plots
%
% Example usage: VisualizeSession( {'subj1_sess1_SSRT.mat','subj1_sess2_SSRT.mat'} );

trialsCell = cell(1, length(filenames));
goTrialsPerFile = zeros(1, length(filenames));
stopTrialsPerFile = zeros(1, length(filenames));

for n = 1:length(filenames)
    trialsCell(n) = struct2cell(load(['session_files/' filenames{n}], 'trials'));
    
    %Trim trial arrays to size if there are unused elements (eg struct
    %was set up for 48 trials, but only 24 were carried out) 
    
    thisTrials = trialsCell{n};
    
    goTrialsPerFile(n) = nnz(strcmpi({thisTrials.Procedure}, 'StGTrial'));
    stopTrialsPerFile(n) = nnz(strcmpi({thisTrials.Procedure}, 'StITrial')) + nnz(strcmpi({thisTrials.Procedure}, 'StITrial2'));
    
    trialsCell{n} = thisTrials(1:length([thisTrials.GoSignalOnsetTimestamp]));
end

combinedTrials = [trialsCell{1:end}];

% Plot the go trial reaction times over the course of the experiment
% sessions(s)
GoRTplot(combinedTrials, goTrialsPerFile)

% Plot stop-signal delay values for both staircases over the course of the
% experiment session(s)
SSDplot(combinedTrials, stopTrialsPerFile);

end

function GoRTplot(trials, goTrialsPerFile)

figure;

meanGoRT = nanmean([trials(strcmpi({trials.Procedure}, 'StGTrial')).GoRT]);

meanCorrectGoRT = nanmean([trials(strcmpi({trials.Procedure}, 'StGTrial') & [trials.Correct]).GoRT]);

plot([trials(strcmpi({trials.Procedure}, 'StGTrial')).GoRT], 'LineWidth', 3);
title({'Go trial reaction times', ['Mean GoRT = ' num2str(meanGoRT) ' s'], ['Mean GoRT (correct responses only) = ' num2str(meanCorrectGoRT) ' s']});
ylabel('Reaction time (s)');
xlabel('Go trial number');

% Draw vertical lines representing start of new experiment sessions
if length(goTrialsPerFile) > 1
    for f = 2:length(goTrialsPerFile)
        firstTrialInd = sum(goTrialsPerFile(1:f-1)) + 1;
        vline(firstTrialInd, '-k', 'new session');
    end
end

end

function SSDplot(trials, stopTrialsPerFile)

figure;

st1markers = zeros(1, nnz(strcmpi({trials.Procedure}, 'StITrial')));
st2markers = zeros(1, nnz(strcmpi({trials.Procedure}, 'StITrial2')));

stopTrialCounter = 1;
for t = 1:numel(trials)
    if strcmpi(trials(t).Procedure, 'StITrial')
        st1markers(find(st1markers == 0, 1)) = stopTrialCounter;
        stopTrialCounter = stopTrialCounter + 1;
    elseif strcmpi(trials(t).Procedure, 'StITrial2')
        st2markers(find(st2markers == 0, 1)) = stopTrialCounter;
        stopTrialCounter = stopTrialCounter + 1;
    end
end

plot(st1markers, [trials(strcmpi({trials.Procedure}, 'StITrial')).SSD_actual], 'LineWidth', 3); hold on;
plot(st2markers, [trials(strcmpi({trials.Procedure}, 'StITrial2')).SSD_actual], 'LineWidth', 3);
plot([trials(~isnan([trials.SSD_actual])).SSD_actual]);
title('Stop signal delay (SSD)');
ylabel('SSD');
xlabel('Stop trial number');
legend({'Staircase 1 (StITrial)', 'Staircase 2 (StITrial2)', 'Both staircases'});

% Draw vertical lines representing start of new experiment sessions
if length(stopTrialsPerFile) > 1
    for f = 2:length(stopTrialsPerFile)
        firstTrialInd = sum(stopTrialsPerFile(1:f-1)) + 1;
        vline(firstTrialInd, '-k', 'new session');
    end
end

end

function hhh=vline(x,in1,in2)
% function h=vline(x, linetype, label)
% 
% Draws a vertical line on the current axes at the location specified by 'x'.  Optional arguments are
% 'linetype' (default is 'r:') and 'label', which applies a text label to the graph near the line.  The
% label appears in the same color as the line.
%
% The line is held on the current axes, and after plotting the line, the function returns the axes to
% its prior hold state.
%
% The HandleVisibility property of the line object is set to "off", so not only does it not appear on
% legends, but it is not findable by using findobj.  Specifying an output argument causes the function to
% return a handle to the line, so it can be manipulated or deleted.  Also, the HandleVisibility can be 
% overridden by setting the root's ShowHiddenHandles property to on.
%
% h = vline(42,'g','The Answer')
%
% returns a handle to a green vertical line on the current axes at x=42, and creates a text object on
% the current axes, close to the line, which reads "The Answer".
%
% vline also supports vector inputs to draw multiple lines at once.  For example,
%
% vline([4 8 12],{'g','r','b'},{'l1','lab2','LABELC'})
%
% draws three lines with the appropriate labels and colors.
% 
% By Brandon Kuczenski for Kensington Labs.
% brandon_kuczenski@kensingtonlabs.com
% 8 November 2001

if length(x)>1  % vector input
    for I=1:length(x)
        switch nargin
        case 1
            linetype='r:';
            label='';
        case 2
            if ~iscell(in1)
                in1={in1};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            label='';
        case 3
            if ~iscell(in1)
                in1={in1};
            end
            if ~iscell(in2)
                in2={in2};
            end
            if I>length(in1)
                linetype=in1{end};
            else
                linetype=in1{I};
            end
            if I>length(in2)
                label=in2{end};
            else
                label=in2{I};
            end
        end
        h(I)=vline(x(I),linetype,label); %#ok<AGROW>
    end
else
    switch nargin
    case 1
        linetype='r:';
        label='';
    case 2
        linetype=in1;
        label='';
    case 3
        linetype=in1;
        label=in2;
    end

    
    
    
    g=ishold(gca);
    hold on

    y=get(gca,'ylim');
    h=plot([x x],y,linetype);
    if ~isempty(label)
        xx=get(gca,'xlim');
        xrange=xx(2)-xx(1);
        xunit=(x-xx(1))/xrange;
        if xunit<0.8
            text(x+0.01*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        else
            text(x-.05*xrange,y(1)+0.1*(y(2)-y(1)),label,'color',get(h,'color'))
        end
    end     

    if g==0
    hold off
    end
    set(h,'tag','vline','handlevisibility','off')
end % else

if nargout
    hhh=h;
end

end