obj.user_likelihood_table = zeros(16,1);






%user likelihood, update bins
            likelihood_grade = 0;
            user_likelihood_current = [false,false,false,false]; %previsouly won(lost), again(not), now won(lost), again(not)
            
            if obj.i>3
                if obj.user_strokes(obj.i-3) == obj.bot_strokes(obj.i-3)
                    user_likelihood_current(1) = true;
                end
                if obj.user_strokes(obj.i-3) == obj.user_strokes(obj.i-2)
                    user_likelihood_current(2) = true;
                end
                if obj.user_strokes(obj.i-2) == obj.bot_strokes(obj.i-2)
                    user_likelihood_current(3) = true;
                end
                if obj.user_strokes(obj.i-2) == obj.user_strokes(obj.i-1)
                    user_likelihood_current(4) = true;
                end
            
                user_likelihood_current_i = 2^3*user_likelihood_current(1) + ...
                                            2^2*user_likelihood_current(2) + ...
                                            2^1*user_likelihood_current(3) + ...
                                            2^0*user_likelihood_current(4) +1;
                
                fprintf('\n');
                fprintf('%d ',user_likelihood_current);
                fprintf('   %d \n', user_likelihood_current_i);
                
                obj.user_likelihood_table(user_likelihood_current_i) = obj.user_likelihood_table(user_likelihood_current_i) + 1;

                %next
                user_likelihood_current(1:2) = user_likelihood_current(3:4);
                user_likelihood_current(3:4) = [false, true];
                if obj.user_strokes(obj.i-1) == obj.bot_strokes(obj.i-1)
                    user_likelihood_current(3) = true;
                end
                user_likelihood_current_i1 = 2^3*user_likelihood_current(1) + ...
                                            2^2*user_likelihood_current(2) + ...
                                            2^1*user_likelihood_current(3) + ...
                                            2^0*false +1;
                user_likelihood_current_i2 = 2^3*user_likelihood_current(1) + ...
                                            2^2*user_likelihood_current(2) + ...
                                            2^1*user_likelihood_current(3) + ...
                                            2^0*true +1;

                likelihood = obj.user_strokes(obj.i-1);
                likelihood_grade = obj.user_likelihood_table(user_likelihood_current_i2) / obj.i;
                if obj.user_likelihood_table(user_likelihood_current_i1) > obj.user_likelihood_table(user_likelihood_current_i2)
                    likelihood = ~likelihood;
                    likelihood_grade = obj.user_likelihood_table(user_likelihood_current_i1) / obj.i;   
                    user_likelihood_current(4) = false;
                end

            end
            
            user_likelihood_current_i = 2^3*user_likelihood_current(1) + ...
                                            2^2*user_likelihood_current(2) + ...
                                            2^1*user_likelihood_current(3) + ...
                                            2^0*user_likelihood_current(4) +1;
                                        
            fprintf('%d ',obj.user_likelihood_table);
            fprintf('   %d  ',user_likelihood_current_i);