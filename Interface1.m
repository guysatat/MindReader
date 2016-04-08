n = 50;
m = 2*n-1;

user_strokes = [];
bot_strokes = [];

user_grade = 0;
bot_grade = 0;
fprintf('\n\n\n\nStart!\n');
for i = 1:m
    bot_strokes(i) = randn(1)>0;
    stroke=getkey();
    switch stroke
        case 29
            user_strokes(i) = 1;
        case 28
            user_strokes(i) = 0;
        case 113
            break;
    end  
    
    if i==1
        user_grade = 1;
    else
        if bot_strokes(i) == user_strokes(i)
            bot_grade = bot_grade + 1;
        else
            user_grade = user_grade+1;
        end
    end
    fprintf('Stroke: User: %d, Bot: %d,   Grade: User: %d, Bot: %d\n',  user_strokes(i), bot_strokes(i), user_grade, bot_grade);
    if user_grade == n || bot_grade == n
        break;
    end
end
if user_grade > bot_grade
    winner = 'You win';
else
    winner = 'Bot wins';
end
fprintf('Done, %s\n\n\n', winner);
     