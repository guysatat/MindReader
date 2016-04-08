%% state = [0,0,0];  % 0(1) -> won(lost),  same(diff),  won(lost)
clear

n = 50;

game = game();

fprintf('\n\n\n\nStart!\n');
for i = 1:(2*n-1)
    game.draw_figure(n);
    game = game.play_turn();
    if game.user_grade == n || game.bot_grade == n || game.i<0
        game.draw_figure(n);
        break;
    end    
end
if game.user_grade > game.bot_grade
    winner = 'You win';
    figure(1); title('User Won');
else
    winner = 'Bot wins';
    figure(1); title('Bot Won');
end
fprintf('\nDone, %s\n\n\n', winner);
     