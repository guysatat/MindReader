clear

game_target = 50; %game length

expert_params.bias_memories = [5,10,15,20];
expert_params.bias_memories_same_diff = [5,10,15,20];
expert_params.pattern_length = [2,3,4,5];
expert_params.pattern_length_same_diff = [2,3,4,5];
expert_params.reactive_user_length = [0,1,2,3,4];

game = game(game_target, expert_params);
game.play_game();

