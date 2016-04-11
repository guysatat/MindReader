classdef game
    %This class manages the game
    %   It tracks the game and predicts next moves
    
    properties (SetAccess = private)
        user_strokes
        user_strokes_same_diff
        user_win_loss
        
        bot_strokes
        bot_strokes_same_diff
        bot_win_loss     
        
        user_grade
        bot_grade
        
        turn_number
        game_target      
        
        stop_game_flag
        
        cheating_flag
        figure_ind
        
        bot
    end
    
    methods (Access = public)
        function game = game(game_target)   %constractor
            game.user_strokes = [];
            game.user_strokes_same_diff = [];
            game.user_win_loss = [];
            
            game.bot_strokes = [];
            game.bot_strokes_same_diff = [];
            game.bot_win_loss = [];
            
            game.user_grade = 0;
            game.bot_grade = 0;
            
            game.turn_number = 1;
            game.game_target = game_target;   
            
            game.stop_game_flag = 0;
            
            game.cheating_flag = 0;
            game.figure_ind = 1;
            
            game.bot = bot();
            
        end
        
        function game = play_game(game)
            fprintf('\n\n\n\nStart!\n');
            game.draw_status();
            
            while game.user_grade < game.game_target && game.bot_grade < game.game_target   %main game loop
                
                [game.bot, game.bot_strokes(game.turn_number)] = game.bot.bot_play(game);
                                
                if game.cheating_flag
                    fprintf('Bot: %d', game.bot_strokes(game.turn_number));
                end
                
                game = game.user_play();
                
                if game.stop_game_flag
                    break;
                end
                
                if ~game.cheating_flag
                    fprintf('Bot: %d', game.bot_strokes(game.turn_number));
                end                                
                fprintf(' User: %d,  ', game.user_strokes(game.turn_number));
            
                game = game.update_status();

                game.draw_status();
                
                fprintf('\n');
            end
            
            if game.user_grade > game.bot_grade
                fprintf('\nDone, You win\n\n\n');
                figure(game.figure_ind); title('User Won');
            else
                fprintf('\nDone, Bot wins\n\n\n');
                figure(game.figure_ind); title('Bot Won');
            end
        end
        
        function game = update_status(game)
            if game.turn_number == 1
                game.user_strokes_same_diff(game.turn_number) = 1;
                game.bot_strokes_same_diff(game.turn_number) = 1;
            else
                if game.user_strokes(game.turn_number) == game.user_strokes(game.turn_number-1)
                    game.user_strokes_same_diff(game.turn_number) = 1;
                else
                    game.user_strokes_same_diff(game.turn_number) = -1;
                end
                
                if game.bot_strokes(game.turn_number) == game.bot_strokes(game.turn_number-1)
                    game.bot_strokes_same_diff(game.turn_number) = 1;
                else
                    game.bot_strokes_same_diff(game.turn_number) = -1;
                end
            end                
            
            if game.bot_strokes(game.turn_number) == game.user_strokes(game.turn_number)
                game.bot_grade = game.bot_grade + 1;
                game.user_win_loss(game.turn_number) = -1;
                game.bot_win_loss(game.turn_number) = 1;                
                fprintf(' B wins ');
            else
                game.user_grade = game.user_grade+1;
                game.user_win_loss(game.turn_number) = 1;
                game.bot_win_loss(game.turn_number) = -1;                           
                fprintf(' U wins ');
            end
            
            fprintf(',  Grade: %d, %d', game.bot_grade, game.user_grade);
                
            game.turn_number = game.turn_number+1;            
        end
        
        
        function draw_status(game)
            figure(1); 
            bar([0,1], [game.user_grade, 0], 'b'); hold on;
            bar([0,1], [0, game.bot_grade], 'r'); hold off;
            ylim([0,game.game_target]);
            ax = gca;
            ax.XTickLabel = {['User: ', num2str(game.user_grade)], ['Bot: ', num2str(game.bot_grade)]};
        end
        
        function game = user_play(game)
            while 1
                stroke=getkey();
                switch stroke
                    case 29
                        game.user_strokes(game.turn_number) = 1;
                        break;
                    case 28
                        game.user_strokes(game.turn_number) = -1;
                        break;
                    case 99
                        game.cheating_flag = ~game.cheating_flag;
                        if game.cheating_flag
                            fprintf('\nOk, here is a little help for you\n')
                            fprintf('Bot will play %d\n', game.bot_strokes(game.turn_number));
                        else
                            fprintf('\nOk, lets make it harder\n');
                        end
                    case 113
                        game.stop_game_flag = 1;                    
                        break;
                end 
            end
        end 
        
    end
    
end
