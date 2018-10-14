fid = fopen('SMSSpamCollection');            % read file
data = fread(fid);
fclose(fid);
lcase = abs('a'):abs('z');
ucase = abs('A'):abs('Z');
caseDiff = abs('a') - abs('A');
caps = ismember(data,ucase);
data(caps) = data(caps)+caseDiff;     % convert to lowercase
data(data == 9) = abs(' ');          % convert tabs to spaces
validSet = [9 10 abs(' ') lcase];         
data = data(ismember(data,validSet)); % remove non-space, non-tab, non-(a-z) characters
data = char(data);                    % convert from vector to characters

words = strsplit(data');             % split into words

% split into examples
count = 0;
examples = {};

for (i=1:length(words))
   if (strcmp(words{i}, 'spam') || strcmp(words{i}, 'ham'))
       count = count+1;
       examples(count).spam = strcmp(words{i}, 'spam');
       examples(count).words = [];
   else
       examples(count).words{length(examples(count).words)+1} = words{i};
   end
end

%split into training and test
random_order = randperm(length(examples));
train_examples = examples(random_order(1:floor(length(examples)*.8)));
test_examples = examples(random_order(floor(length(examples)*.8)+1:end));

% count occurences for spam and ham

spamcounts = javaObject('java.util.HashMap');
numspamwords = 0;
hamcounts = javaObject('java.util.HashMap');
numhamwords = 0;

alpha = 0.1;

for (i=1:length(train_examples))
    for (j=1:length(train_examples(i).words))
        word = train_examples(i).words{j};
        if (train_examples(i).spam == 1)
            numspamwords = numspamwords+1;
            current_count = spamcounts.get(word);
            if (isempty(current_count))
                spamcounts.put(word, 1+alpha);    % initialize by including pseudo-count prior
            else
                spamcounts.put(word, current_count+1);  % increment
            end
        else
            numhamwords = numhamwords+1;
            current_count = hamcounts.get(word);
            if (isempty(current_count))
                hamcounts.put(word, 1+alpha);    % initialize by including pseudo-count prior
            else
                hamcounts.put(word, current_count+1);  % increment
            end
        end
    end    
end

%spamcounts.get('cancel')/(numspamwords+alpha*20000)   % probability of word 'free' given spam
%hamcounts.get('cancel')/(numhamwords+alpha*20000)   % probability of word 'free' given ham
% will need to check if count is empty!

SpamNum=0;
j=0;
for j=1:length(examples)
    SpamNum= SpamNum + examples(j).spam;
end

PSpam= SpamNum/j;
PHam= 1-PSpam;

% ... 
NS=0;
NH=0;
NSL=0;
NHL=0;
PspamMes=1;
PhamMes=1;
temp1=0;
temp2=0;
trigger=-1;
trigger2=-1;
trueP=0;
trueN=0;
falseP=0;
falseN=0;
for (i=1:length(test_examples))
    for (j=1:length(test_examples(i).words))
        word=test_examples(i).words{j};
        if(j==1)
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
        PspamMes= temp1;
           else
               PspamMes= alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
        PhamMes= temp2;
           else
               PhamMes= alpha/(numhamwords+alpha*20000);
           end
        else
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
            PspamMes= PspamMes * temp1;
            else
               PspamMes= PspamMes * alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
            PhamMes= PhamMes * temp2;
            else
               PhamMes= PhamMes * alpha/(numspamwords+alpha*20000);
           end
        end
    end
    if(test_examples(i).spam==1)
            NS=NS+1;
            trigger2=0;
        else
            NH=NH+1;
            trigger2=1;
    end
    PhamMes= PHam * PhamMes;
    PspamMes= PSpam* PspamMes;
    if (PhamMes<PspamMes)
        NSL=NSL+1;
        trigger=0;
    else
        NHL=NHL+1;
        trigger=1;
    end
    if (trigger==0)
        if(trigger2==0)
            trueP=trueP+1;
        else if(trigger2==1)
                falseP=falseP+1;
            end
        end
    else if(trigger==1)
            if(trigger2==0)
                falseN=falseN+1;
            else if(trigger2==1)
                    trueN= trueN+1;
                end
            end
        end
    end
    trigger=-1;
    trigger2=-1;
end

precision= trueP/(trueP+falseP);
recall= trueP/(trueP+falseN);
Fscore= 2 * precision*recall/(precision + recall);

%NS
%NSL
%NH
%NHL
falseP
trueP
falseN
trueN

TestingAccuracy= (trueP+trueN)/(length(test_examples))
precision
recall
Fscore

%%PART B
l= [];
l2= [];
l3=[];
l4=[];
for k= [-5 -4 -3 -2 -1 0]
    alpha= 2^k;
for (i=1:length(train_examples))
    for (j=1:length(train_examples(i).words))
        word = train_examples(i).words{j};
        if (train_examples(i).spam == 1)
            numspamwords = numspamwords+1;
            current_count = spamcounts.get(word);
            if (isempty(current_count))
                spamcounts.put(word, 1+alpha);    % initialize by including pseudo-count prior
            else
                spamcounts.put(word, current_count+1);  % increment
            end
        else
            numhamwords = numhamwords+1;
            current_count = hamcounts.get(word);
            if (isempty(current_count))
                hamcounts.put(word, 1+alpha);    % initialize by including pseudo-count prior
            else
                hamcounts.put(word, current_count+1);  % increment
            end
        end
    end    
end



%spamcounts.get('cancel')/(numspamwords+alpha*20000)   % probability of word 'free' given spam
%hamcounts.get('cancel')/(numhamwords+alpha*20000)   % probability of word 'free' given ham
% will need to check if count is empty!

SpamNum=0;
j=0;
for j=1:length(examples)
    SpamNum= SpamNum + examples(j).spam;
end

PSpam= SpamNum/j;
PHam= 1-PSpam;

% ... 
NS=0;
NH=0;
NSL=0;
NHL=0;
PspamMes=1;
PhamMes=1;
temp1=0;
temp2=0;
trigger=-1;
trigger2=-1;
trueP=0;
trueN=0;
falseP=0;
falseN=0;
for (i=1:length(test_examples))
    for (j=1:length(test_examples(i).words))
        word=test_examples(i).words{j};
        if(j==1)
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
        PspamMes= temp1;
           else
               PspamMes= alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
        PhamMes= temp2;
           else
               PhamMes= alpha/(numhamwords+alpha*20000);
           end
        else
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
            PspamMes= PspamMes * temp1;
            else
               PspamMes= PspamMes * alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
            PhamMes= PhamMes * temp2;
            else
               PhamMes= PhamMes * alpha/(numspamwords+alpha*20000);
           end
        end
    end
    if(test_examples(i).spam==1)
            NS=NS+1;
            trigger2=0;
        else
            NH=NH+1;
            trigger2=1;
    end
    PhamMes= PHam * PhamMes;
    PspamMes= PSpam* PspamMes;
    if (PhamMes<PspamMes)
        NSL=NSL+1;
        trigger=0;
    else
        NHL=NHL+1;
        trigger=1;
    end
    if (trigger==0)
        if(trigger2==0)
            trueP=trueP+1;
        else if(trigger2==1)
                falseP=falseP+1;
            end
        end
    else if(trigger==1)
            if(trigger2==0)
                falseN=falseN+1;
            else if(trigger2==1)
                    trueN= trueN+1;
                end
            end
        end
    end
    trigger=-1;
    trigger2=-1;
end

precision= trueP/(trueP+falseP);
recall= trueP/(trueP+falseN);
Fscore= 2 * precision*recall/(precision + recall);
TestingAccuracy= (trueP+trueN)/(length(test_examples));
%Performance= TestingAccuracy/Fscore;
%NS
%NSL
%NH
%NHL
%falseP
%trueP
%falseN
%trueN
%TestingAccuracy= (trueP+trueN)/(length(test_examples));
%precision
%recall
%Fscore
l= [l,Fscore];
l2= [l2, TestingAccuracy];
% ... 
NS=0;
NH=0;
NSL=0;
NHL=0;
PspamMes=1;
PhamMes=1;
temp1=0;
temp2=0;
trigger=-1;
trigger2=-1;
trueP=0;
trueN=0;
falseP=0;
falseN=0;
for (i=1:length(train_examples))
    for (j=1:length(train_examples(i).words))
        word=train_examples(i).words{j};
        if(j==1)
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
        PspamMes= temp1;
           else
               PspamMes= alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
        PhamMes= temp2;
           else
               PhamMes= alpha/(numhamwords+alpha*20000);
           end
        else
           temp1= spamcounts.get(word)/(numspamwords+alpha*20000);
           temp2= hamcounts.get(word)/(numhamwords+alpha*20000);
           if(~isempty(temp1))
            PspamMes= PspamMes * temp1;
            else
               PspamMes= PspamMes * alpha/(numspamwords+alpha*20000);
           end
           if(~isempty(temp2))
            PhamMes= PhamMes * temp2;
            else
               PhamMes= PhamMes * alpha/(numspamwords+alpha*20000);
           end
        end
    end
    if(train_examples(i).spam==1)
            NS=NS+1;
            trigger2=0;
        else
            NH=NH+1;
            trigger2=1;
    end
    PhamMes= PHam * PhamMes;
    PspamMes= PSpam* PspamMes;
    if (PhamMes<PspamMes)
        NSL=NSL+1;
        trigger=0;
    else
        NHL=NHL+1;
        trigger=1;
    end
    if (trigger==0)
        if(trigger2==0)
            trueP=trueP+1;
        else if(trigger2==1)
                falseP=falseP+1;
            end
        end
    else if(trigger==1)
            if(trigger2==0)
                falseN=falseN+1;
            else if(trigger2==1)
                    trueN= trueN+1;
                end
            end
        end
    end
    trigger=-1;
    trigger2=-1;
end

precision= trueP/(trueP+falseP);
recall= trueP/(trueP+falseN);
Fscore= 2 * precision*recall/(precision + recall);
TestingAccuracy= (trueP+trueN)/(length(train_examples));
l3= [l3,Fscore];
l4= [l4, TestingAccuracy];
end

ax1 = subplot(2,1,1); % top subplot
x = [-5 -4 -3 -2 -1 0];
y1 = l2;
plot(ax1,x,y1,x,l4)
title(ax1,'Accuracy PLOT')
ylabel(ax1,'Accuracy')

ax2 = subplot(2,1,2); % bottom subplot
y2 = l;
plot(ax2,x,y2,x,l3)
title(ax2,'F-Score PLOT')
ylabel(ax2,'F-Score')
%end