function [T,headervars]=eprimetxt2vars(ifile,xlsxFile)
% ***Function and documentation provided by Github user yuval-harpaz***
% turns nasty e-prime txt files into matlab tables, and if requested, to xlsx
% ifile is input txt file, output of E-Prime
% xlsxFile is output file name (optional).
% T is a table thingy
% dots are replaced with __ in variable names to avoid a serious mess.
% you can get your RT like this: Wait1__RT=cell2mat(T.Wait1__RT)
% headervars is a cell array with subject, session etc. If you write xlsx
% it should appear as a seperate sheet
% ***Function and documentation provided by Github user yuval-harpaz***
 
T=[];
% get header variables
fid = fopen(ifile);
tline = fgets(fid);
Counter=0;
headervars={};
isHeader=true;
while isHeader
    %disp(tline)
    tline(uint8(tline)==0) = [];
    if ~isempty(strfind(tline,'Header End'))
        isHeader=false;
    end
    if isHeader
        fieldi=strfind(tline,':');
        if ~isempty(fieldi)
            Counter=Counter+1;
            headervars{Counter,1}=tline(1:fieldi-1);
            headervars{Counter,2}=tline(fieldi+1:end);
        end
    end
    tline = fgets(fid);
end
fclose(fid);

% get rid of returns
try
    for vari=1:size(headervars)
        var={};
        str0=strrep(headervars{vari,2},char(13),'');
        if isstrprop(str0(1),'wspace')
            str0=str0(2:end);
        end
        headervars{vari,2}=str0;
    end
catch
    disp('failed removing returns and spaces from header variables')
end

%% get variables
fid = fopen(ifile);
tline = fgets(fid);
Counter=0;
logLine=0;
isHeader=true;
while ischar(tline)
    %disp(tline)
    tline(uint8(tline)==0) = [];
    if ~isempty(strfind(tline,'Header End'))
        isHeader=false;
    end
    if ~isHeader
        logStarti=strfind(tline,'LogFrame Start');
        if ~isempty(logStarti)
            logLine=logLine+1;
        end
        fieldi=strfind(tline,':');
        if ~isempty(fieldi)
            % content=tline(fieldi+length(field)+1:end);
            %if content>99
            Counter=Counter+1;
            tmpvars{Counter,1}=tline(1:fieldi-1);
            tmpvars{Counter,2}=tline(fieldi+1:end);
            %opvar{Counter,1}=content;
            line(Counter,1)=logLine;
            %end
        end
    end
    tline = fgets(fid);
end
fclose(fid);
% replace . with __
for tmpi=1:length(tmpvars)
    tmpvars{tmpi}=strrep(tmpvars{tmpi},'.','__');
end
vars=unique(tmpvars(:,1));
if line(1)==0;
    line=line+1;
end
% pile to variables
for vari=1:length(vars)
    var=vars{vari};
    tmpvarsi=find(ismember(tmpvars,var));
    eval([var,'=tmpvars(tmpvarsi);']);
    eval([var,'i=line(tmpvarsi);']);
    eval([var,'={};']);
    eval([var,'(line(tmpvarsi),1)=tmpvars(tmpvarsi,2);']);
end
for vari=1:length(vars)
    var=vars{vari};
    eval(['ln(',num2str(vari),')=length(',var,');']);
end
maxLn=max(ln);
for vari=1:length(vars)
    try
        var=vars{vari};
        lnv=length(eval(var));
        if length(eval(var))<maxLn
            eval([var,'(lnv+1:maxLn)=repmat({[]},maxLn-lnv,1);']);
        end
    catch
        disp('lost data!')
    end
end
% make table
str=[];
for vari=1:length(vars)
    str=[str,',',vars{vari}];
end
eval(['T=table(',str(2:end),');'])
% convert numeric strings
try
    disp(['converting numbers, pass 1 of 2, (',num2str(size(T,2)),' vars):  '])
    fprintf('\b')
    for vari=1:size(T,2)
        rowMark=[];
        for rowi=1:size(T,1)
            numCell=all(isstrprop(T{rowi,vari}{1},'digit') | isstrprop(T{rowi,vari}{1},'wspace'));
            rowMark(rowi)=numCell | isempty(T{rowi,vari}{1});
        end
        varIsNumeric(vari)=all(rowMark);
        prog(vari)
    end
    fprintf('\n')
    disp(['converting numbers, pass 2 of 2, (',num2str(size(T,2)),' vars):  '])
    fprintf('\b')
    for vari=find(varIsNumeric)
        var={};
        for rowi=1:size(T,1)
            if isempty(T{rowi,vari}{1})
                var(rowi,1)={[]};
            else
                var(rowi,1)={str2num(T{rowi,vari}{1})};
            end
        end
        T(:,vari)=var;
        prog(vari)
    end
catch
    disp('failed converting numbers')
end
% get rid of returns
try
    fprintf('\n')
    disp(['removing returns and first char spaces (',num2str(length(find(~varIsNumeric))),'):  '])
    fprintf('\b')
    count=0;
    for vari=find(~varIsNumeric)
        count=count+1;
        var={};
        for rowi=1:size(T,1)
            if isempty(T{rowi,vari}{1})
                str1='';
            else
                str1=strrep(T{rowi,vari}{1},char(13),'');
                if isstrprop(str1(1),'wspace')
                    str1=str1(2:end);
                end
            end
            var(rowi,1)={str1};
        end
        T(:,vari)=var;
        prog(count);
    end
catch
    disp('failed removing returns and spaces')
end
if nargin>1
    disp('writing file')
    warning off
    try
        writetable(T,xlsxFile,'Sheet','data')
    catch
        disp('failed to write xlsx for data');
    end
    try
        writetable(cell2table(headervars),xlsxFile,'Sheet','header','WriteVariableNames',false);
    catch
        disp('failed to write xlsx for header');
    end
    warning on
end
fprintf('\n')
disp('done')

function prog(ii)
% display progress of a loop, uses backspace  \b to stay on one line
if ii==1
    fprintf(num2str(ii))
else
    txt=[repmat('\b',1,length(num2str(ii-1))),num2str(ii)];
    fprintf(txt)
end