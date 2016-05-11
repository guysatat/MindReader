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
        
        grades_vs_turns
        
        turn_number
        game_target      
        
        stop_game_flag
        
        cheating_flag
        random_player
        
        figure_ind
        
        bot
    end
    
    methods (Access = public)
        function game = game(game_target, expert_params, random_player, figure_ind)   %constractor
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
            game.random_player = random_player;
            
            
            game.figure_ind = figure_ind;
            
            game.bot = bot(expert_params);
            
            game.grades_vs_turns = [0;0];
            
        end
        
        %main game function - runs the game loop and ends the game
        function game = play_game(game)
            display('Can you beat the machine?');
            display('Choose your step by clicking the right or left keys.'); 
            display('Current score is shown in figure 1.');
            display('You can quit the game at any time by hitting q.');
            display('You can cheat (and see what the computer is up to) by hitting c.'); 
            display('Good Luck!');
   
            game.draw_status();
            
            while game.user_grade < game.game_target && game.bot_grade < game.game_target   %main game loop
                
                [game.bot, game.bot_strokes(game.turn_number)] = game.bot.bot_play(game);  %ask bot to play
                                
                if game.cheating_flag   %if cheating show the bot status figure
                    draw_bot_status(game);
                end
                
                game = game.user_play();  %ask user to play
                
                if game.stop_game_flag %if the user wants to quit stop the loop
                    break;
                end
            
                game = game.update_status();   %update the game status

                if game.random_player == 0 %update the status figure (only if playing against human)
                    game.draw_status();
                end
                
            end
            
            %figure out who won
            if game.user_grade > game.bot_grade
                winner = 'You';                
            else
                winner = 'Bot';
            end
            draw_status(game);
            draw_bot_status(game);
            figure(game.figure_ind); title([winner,' won after ', num2str(game.turn_number), ' turns']);
            figure(game.figure_ind+1); subplot(411); title([winner,' won after ', num2str(game.turn_number), ' turns']);
        end
        
        %update all game arrays
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
            else
                game.user_grade = game.user_grade+1;
                game.user_win_loss(game.turn_number) = 1;
                game.bot_win_loss(game.turn_number) = -1; 
            end
            
            game.grades_vs_turns(1, game.turn_number) = game.user_grade;
            game.grades_vs_turns(2, game.turn_number) = game.bot_grade;
                
            game.turn_number = game.turn_number+1;            
        end
        
        %draws the game status figure
        function draw_status(game)
            scrsz = get(0, 'ScreenSize');
            pos = [scrsz(3)/2 - 500, scrsz(4)-(500+100), 400, 500];
            
            figure(game.figure_ind); 
            set(gcf, 'Position', pos);
             
            bar([0,1], [game.user_grade, 0], 'b'); hold on;
            bar([0,1], [0, game.bot_grade], 'r'); hold off;
            ylim([0,game.game_target]);
            ax = gca;
            ax.XTickLabel = {['User: ', num2str(game.user_grade)], ['Bot: ', num2str(game.bot_grade)]};
            title(['Turn #', num2str(game.turn_number)]);
            drawnow;
        end
        
        %draws the bot status figure (only end of game or cheating)
        function draw_bot_status(game)
            scrsz = get(0, 'ScreenSize');
            pos = [scrsz(3)/2, 50, scrsz(3)/2, (scrsz(4)-50)*0.9];
            figure(game.figure_ind+1); 
            set(gcf, 'Position', pos);
            
            subplot(411);
            plot(1:size(game.grades_vs_turns,2), game.grades_vs_turns(1, :), ...
                1:size(game.grades_vs_turns,2), game.grades_vs_turns(2, :), 'linewidth', 2);
            legend('User', 'Bot', 'Location','northwest');
            xlabel('Turn #');
            ylabel('Score');
            ylim([0, game.game_target]);
            xlim([1, 2*game.game_target-1]);
                        
            subplot(412);
            error_rate = zeros(size(game.bot_win_loss));
            for i = 1:length(error_rate)
                error_rate(i) = 1-(mean(game.bot_win_loss(1:i))+1)/2;
            end            
            plot(error_rate, 'linewidth', 2); ylim([0,1]); xlim([1, 2*game.game_target-1]);
            xlabel('Turn #'); ylabel('Error rate'); 
            
            subplot(413);
            plot(squeeze(sum(game.bot.current_bot_status.experts,2))', 'linewidth', 2);
            xlim([1, 2*game.game_target-1]);
            xlabel('Turn #');
            ylabel('Weight');
            legend(game.bot.current_bot_status.experts_labels,'Orientation','horizontal','location','northoutside');            
            
            subplot(414);
            bar(game.bot.current_bot_status.experts(:,:,end));
            ax = gca;
            ax.XTickLabel = game.bot.current_bot_status.experts_labels;
            
            if game.bot_strokes(end) == 1
                bot_dec_s = 'right';
            else
                bot_dec_s = 'left';
            end
            title(['Current bot bias: ', num2str(game.bot.current_bot_status.dec),' Bot prediction: ', bot_dec_s]);       
            drawnow;
        end
        
        %handle the user key stroke request
        function game = user_play(game)
            if game.random_player == 1
                game.user_strokes(game.turn_number) = 2*binornd(1, 0.5)-1;
                return;
            end
            
            while 1
                stroke=getkey();
                switch stroke
                    case 29  %right arrow
                        game.user_strokes(game.turn_number) = 1;
                        break;
                    case 28  %left arrow
                        game.user_strokes(game.turn_number) = -1;
                        break;
                    case 99  %'c' key - cheating
                        game.cheating_flag = ~game.cheating_flag;
                        if game.cheating_flag
                            draw_bot_status(game);
                        end
                    case 113 %'q' key - quit
                        game.stop_game_flag = 1;                    
                        break;
                end 
            end
        end         
    end
    
end

