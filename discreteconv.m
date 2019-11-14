classdef discreteconv < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        UIAxes                       matlab.ui.control.UIAxes
        DiscreteConvolutionLabel     matlab.ui.control.Label
        function1DropDownLabel       matlab.ui.control.Label
        function1DropDown            matlab.ui.control.DropDown
        UIAxes_2                     matlab.ui.control.UIAxes
        UIAxes_3                     matlab.ui.control.UIAxes
        Label                        matlab.ui.control.Label
        UIAxes_4                     matlab.ui.control.UIAxes
        BackButton                   matlab.ui.control.Button
        function2DropDownLabel       matlab.ui.control.Label
        function2DropDown            matlab.ui.control.DropDown
        SignalamplitudeAKnobLabel    matlab.ui.control.Label
        SignalamplitudeAKnob         matlab.ui.control.Knob
        FunctionwidthnKnobLabel      matlab.ui.control.Label
        FunctionwidthnKnob           matlab.ui.control.Knob
        SignalamplitudeAKnob_2Label  matlab.ui.control.Label
        SignalamplitudeAKnob_2       matlab.ui.control.Knob
        SignalwidthnKnobLabel        matlab.ui.control.Label
        SignalwidthnKnob             matlab.ui.control.Knob
        SignalwidthnKnob_2Label      matlab.ui.control.Label
        SignalwidthnKnob_2           matlab.ui.control.Knob
        FunctionwidthnKnob_2Label    matlab.ui.control.Label
        FunctionwidthnKnob_2         matlab.ui.control.Knob
        Label_2                      matlab.ui.control.Label
        CONVOLVEButton               matlab.ui.control.Button
        exitButton                   matlab.ui.control.Button
        UIAxes5                      matlab.ui.control.UIAxes
    end


    methods (Access = private)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Function that extracts the values from the knobs in the GUI. 
        %These values will be sent to another function to be used in calculating the plot.
        function [Amplitude FunctionWidth SignalWidth] = variables(app,fn);
            if(fn == 1)
            %Initialize the variables
            Amplitude = app.SignalamplitudeAKnob.Value;
            FunctionWidth = ceil(app.FunctionwidthnKnob.Value); %Ceil is used to ensure that the function width is an integer
            SignalWidth = ceil(app.SignalwidthnKnob.Value); %Ceil is used to ensure that the signla width is an integer
            else
            Amplitude = app.SignalamplitudeAKnob_2.Value;
            FunctionWidth = ceil(app.FunctionwidthnKnob_2.Value); %Ceil is used to ensure that the function width is an integer
            SignalWidth = ceil(app.SignalwidthnKnob_2.Value); %Ceil is used to ensure that the signl width is an integer
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% This function calculates the Plot for the 2 functions plotted on the left side of the GUI.
        function [y n] = CalculatePlot(app, Amplitude, FunctionWidth, SignalWidth, fn)
            %%%%%%%%%%%
            %First, we determine which function is passed as a parameter through "fn". Function 1 or 2. 
            if(fn == 1)
                 DropDownValue = app.function1DropDown.Value;
                 axes = app.UIAxes;
             else
                 DropDownValue = app.function2DropDown.Value;
                 axes = app.UIAxes_2;
            end
            %%%%%%%%%%%%
            %calculate n, the range of samples in the signal.
            %If the signal width is odd numbered,
            if(rem(SignalWidth,2)) 
                n = -(SignalWidth-1)/2:(SignalWidth-1)/2;
            else 
                %if the signal width is even 
                %the extra point that destroyed the symmetry of the signal will be put on the negative side of the signal.
                %This is just to be consistent with what happens when rectpuls plots an even signal.
                n=-(SignalWidth)/2 +1: (SignalWidth)/2;
            end
            %%%%%%%%%%%%%%%%%%%%%%
            switch DropDownValue
                
                case 'Rectangular'
                    %in rectpuls, even signals result in an extra pulse on the negative side of the signal.
                    y = Amplitude*rectpuls(n,FunctionWidth);
                    stem(axes,n,y);
                    
                case 'Triangular'
                    %tripuls is symmetric whether the functionwidth is even or odd, so no modifications need to be done. 
                    y = Amplitude*tripuls(n,FunctionWidth);
                    stem(axes,n,y);
                case 'Ramp'
                    %%%%%%%%%%%%
                    %Handling the error that would arise if the function width is chosen to be greater than the signal width
                    if(FunctionWidth>SignalWidth)
                        SignalWidth=FunctionWidth;
                    end
                    %%%%%%%%%%%%
                        %caculate the values of the ramp function.
                    x = [-Amplitude:Amplitude/((FunctionWidth-1)/2):Amplitude];
                    y = x;
                    %%%%%%%%%%%%
                    %if the signal width is odd
                    if(rem(SignalWidth,2)) 
                        %%%%%%
                        %if the function width is odd, append zeros to the right and
                        %left of the function equally to form the signal.
                        if(rem(FunctionWidth,2)) 
                            y = [zeros(1,(SignalWidth-FunctionWidth)/2) y zeros(1,(SignalWidth-FunctionWidth)/2)];
                        
                        %if the function width is even, append zeros to the right and left of
                        %the function. The right will be appended an extra zero point than the
                        %left.
                        else
                            y = [zeros(1,(SignalWidth-FunctionWidth-1)/2) y 0 zeros(1,(SignalWidth-FunctionWidth-1)/2)];  
                        end
                        %%%%%%
                        %If the function width was greater than the signal width, recalculate n with the new value assigned to Signal width at the beginning of the case.
                        n = -(SignalWidth-1)/2:(SignalWidth-1)/2;
                        stem(axes,n,y);
                        
                     %if the signal is even,  
                     else
                        %%%%%%
                        %if the function width is odd  
                        if(rem(FunctionWidth,2))
                        y = [zeros(1,(SignalWidth-FunctionWidth-1)/2) y 0 zeros(1,(SignalWidth-FunctionWidth-1)/2)];
                        else 
                        y = [zeros(1,(SignalWidth-FunctionWidth)/2) y zeros(1,(SignalWidth-FunctionWidth)/2)] ;
                        end
                        %%%%%%
                        %If the function width was greater than the signal width, recalculate n with the new value assigned to Signal width at the beginning of the case.
                        n=-(SignalWidth)/2 +1: (SignalWidth)/2; 
                        stem(axes,n,y);   
                    end
                    %%%%%%%%%%%%
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function linconv(app,y,y2,n,n2)
            %expected convolved result
            stem(app.UIAxes5,conv(y,y2));
            %y and y2 need to be zero-padded from the left and right
            Y = [zeros(1, abs(min(n2))) y zeros(1,max(n2))];
            Y2 = [zeros(1, abs(min(n))) y2 zeros(1,max(n))];
             
              %%%%%%%%%%%%
              %to perform linear convolution, a matrix called Y_matrix is created from function Y.
              %Each row of this matrix will be multiplied by the function Y2 and summed.
              %To form Y_matrix,
              
              
              %Get the first row of Y_matrix.
              %The first row of Y shifted to the left by min(n)+min(n2) which means that
              %The function Y got shifted until its center became at the beginning of the row.
              firstrow = circshift(Y,min(n)+min(n2));
              %Multiply this first row by an array of ones and zeros to remove the unwanted
              %values that appeared at the end of the array due to circular shift.
              %The length of ones and zeros is chosen to specifically only delete the values at the end
              %of the array of Y.
              modified_firstrow = [ones(1,length(Y)-abs(min(n)+min(n2))) zeros(1,abs(min(n)+min(n2)))]
              %Now multiply modified_firstrow by firstrow to get the desired row.
              firstrow = firstrow.*modified_firstrow;
              %%%%%
              %Now perform toeplitz to get the desired matrix.
              %However, this following condition is specific for the ramp function. 
              %Since the ramp function has negative values, and these negative values were all deleted
              %due to the last few steps, we need to preserve the negative values in an array
              %called firstcolumn. 
              if(min(Y)<0)
                  %both functions are even
                  if(~rem(length(y),2) && ~rem(length(y2),2))
                  firstcolumn = circshift(Y,-(max(n)+max(n2)-1))
                  %both functions are odd
                  else if ((rem(length(y),2)) && rem(length(y2),2))
                        firstcolumn = circshift(Y,-(max(n)+max(n2)+1)) 
                        else
                       %if either functions is even and the other is odd
                        firstcolumn = circshift(Y,-(max(n)+max(n2))) 
                        end
                  end
              
              %Multiply this first column by an array of ones and zeros to remove the unwanted
              %values that appeared at the beginning of the array due to circular shift.
              %The length of ones and zeros is chosen to specifically only delete the values at the beginning
              %of the array of Y.
              modified_firstcolumn = [zeros(1,length(Y)-abs(min(n)+min(n2))) ones(1,abs(min(n)+min(n2)))]
              %Now multiply modified_firstcolumn by firstcolumn to get the desired row.
              firstcolumn = firstcolumn.*modified_firstcolumn
                  %Get Y_matrix
                  Y_matrix = toeplitz(flip(firstcolumn),firstrow);
              else
              Y_matrix = toeplitz(firstrow);
              end
              %%%%%
              cla(app.UIAxes_3);
              %for loop to plot each row in the matrix individually multiplied and summed with Y2.
              for i = 1:size(Y_matrix,1)
                  %plot the convolution
                  stem(app.UIAxes_3,i,sum(Y_matrix(i,:).*Y2));
                  hold(app.UIAxes_3,'on');
                  
                  %plot the animation
                  cla(app.UIAxes_4);
                  %Y2 will be the same throughout the animation. Y will slide over it.
                  stem(app.UIAxes_4,Y2);
                  hold(app.UIAxes_4,'on');
                  stem(app.UIAxes_4,Y_matrix(i,:));
                  hold(app.UIAxes_4,'on');
              
              pause(0.1); 
              end
        
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    methods (Access = private)

        % Button pushed function: BackButton
        function BackButtonPushed(app, event)
            mainwindow;
            closereq;
        end

        % Button pushed function: CONVOLVEButton
        function CONVOLVEButtonPushed(app, event)
            
            %Get the values of the knobs in function 1
            [Amplitude FunctionWidth SignalWidth] = variables(app,1);
            %pass these values to CalculatePlot,
            [y n] = CalculatePlot(app, Amplitude, FunctionWidth, SignalWidth, 1);
            
            %Get the values of the knobs in function 2
            [Amplitude FunctionWidth SignalWidth] = variables(app,2);
            [y2 n2] = CalculatePlot(app, Amplitude, FunctionWidth, SignalWidth, 2);
            
            %Perform linear convolution
            linconv(app,y,y2,n,n2);
        end

        % Button pushed function: exitButton
        function exitButtonPushed(app, event)
            app.delete;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1315 646];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Function 1')
            xlabel(app.UIAxes, 'n')
            ylabel(app.UIAxes, 'Amplitude')
            app.UIAxes.Position = [35 300 300 185];

            % Create DiscreteConvolutionLabel
            app.DiscreteConvolutionLabel = uilabel(app.UIFigure);
            app.DiscreteConvolutionLabel.FontSize = 22;
            app.DiscreteConvolutionLabel.Position = [402 581 209 29];
            app.DiscreteConvolutionLabel.Text = 'Discrete Convolution';

            % Create function1DropDownLabel
            app.function1DropDownLabel = uilabel(app.UIFigure);
            app.function1DropDownLabel.HorizontalAlignment = 'center';
            app.function1DropDownLabel.Position = [401 549 58 15];
            app.function1DropDownLabel.Text = 'function 1';

            % Create function1DropDown
            app.function1DropDown = uidropdown(app.UIFigure);
            app.function1DropDown.Items = {'Rectangular', 'Triangular', 'Ramp'};
            app.function1DropDown.Position = [380 517 100 22];
            app.function1DropDown.Value = 'Rectangular';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Function 2')
            xlabel(app.UIAxes_2, 'n')
            ylabel(app.UIAxes_2, 'Amplitude')
            app.UIAxes_2.Position = [35 87 300 185];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.UIFigure);
            title(app.UIAxes_3, 'Actual convolved result')
            xlabel(app.UIAxes_3, 'n')
            ylabel(app.UIAxes_3, 'Amplitude')
            app.UIAxes_3.Position = [675 300 300 185];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'center';
            app.Label.VerticalAlignment = 'center';
            app.Label.FontSize = 72;
            app.Label.Position = [489 508 34 72];
            app.Label.Text = '*';

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.UIFigure);
            title(app.UIAxes_4, 'Animated result')
            xlabel(app.UIAxes_4, 'n')
            ylabel(app.UIAxes_4, 'Amplitude')
            app.UIAxes_4.Position = [987 192 300 185];

            % Create BackButton
            app.BackButton = uibutton(app.UIFigure, 'push');
            app.BackButton.ButtonPushedFcn = createCallbackFcn(app, @BackButtonPushed, true);
            app.BackButton.Position = [1139 30 100 22];
            app.BackButton.Text = 'Back';

            % Create function2DropDownLabel
            app.function2DropDownLabel = uilabel(app.UIFigure);
            app.function2DropDownLabel.HorizontalAlignment = 'center';
            app.function2DropDownLabel.Position = [553 549 58 15];
            app.function2DropDownLabel.Text = 'function 2';

            % Create function2DropDown
            app.function2DropDown = uidropdown(app.UIFigure);
            app.function2DropDown.Items = {'Rectangular', 'Triangular', 'Ramp'};
            app.function2DropDown.Position = [532 517 100 22];
            app.function2DropDown.Value = 'Rectangular';

            % Create SignalamplitudeAKnobLabel
            app.SignalamplitudeAKnobLabel = uilabel(app.UIFigure);
            app.SignalamplitudeAKnobLabel.HorizontalAlignment = 'center';
            app.SignalamplitudeAKnobLabel.Position = [351 348 106 15];
            app.SignalamplitudeAKnobLabel.Text = 'Signal amplitude A';

            % Create SignalamplitudeAKnob
            app.SignalamplitudeAKnob = uiknob(app.UIFigure, 'continuous');
            app.SignalamplitudeAKnob.Limits = [10 100];
            app.SignalamplitudeAKnob.Position = [385 397 37 37];
            app.SignalamplitudeAKnob.Value = 10;

            % Create FunctionwidthnKnobLabel
            app.FunctionwidthnKnobLabel = uilabel(app.UIFigure);
            app.FunctionwidthnKnobLabel.HorizontalAlignment = 'center';
            app.FunctionwidthnKnobLabel.Position = [471 271 93 15];
            app.FunctionwidthnKnobLabel.Text = 'Function width n';

            % Create FunctionwidthnKnob
            app.FunctionwidthnKnob = uiknob(app.UIFigure, 'continuous');
            app.FunctionwidthnKnob.Limits = [10 100];
            app.FunctionwidthnKnob.Position = [498 320 37 37];
            app.FunctionwidthnKnob.Value = 10;

            % Create SignalamplitudeAKnob_2Label
            app.SignalamplitudeAKnob_2Label = uilabel(app.UIFigure);
            app.SignalamplitudeAKnob_2Label.HorizontalAlignment = 'center';
            app.SignalamplitudeAKnob_2Label.Position = [351 135 106 15];
            app.SignalamplitudeAKnob_2Label.Text = 'Signal amplitude A';

            % Create SignalamplitudeAKnob_2
            app.SignalamplitudeAKnob_2 = uiknob(app.UIFigure, 'continuous');
            app.SignalamplitudeAKnob_2.Limits = [10 100];
            app.SignalamplitudeAKnob_2.Position = [385 184 37 37];
            app.SignalamplitudeAKnob_2.Value = 10;

            % Create SignalwidthnKnobLabel
            app.SignalwidthnKnobLabel = uilabel(app.UIFigure);
            app.SignalwidthnKnobLabel.HorizontalAlignment = 'center';
            app.SignalwidthnKnobLabel.Position = [553 348 133 15];
            app.SignalwidthnKnobLabel.Text = 'Signal width n';

            % Create SignalwidthnKnob
            app.SignalwidthnKnob = uiknob(app.UIFigure, 'continuous');
            app.SignalwidthnKnob.Limits = [10 100];
            app.SignalwidthnKnob.Position = [598 397 37 37];
            app.SignalwidthnKnob.Value = 10;

            % Create SignalwidthnKnob_2Label
            app.SignalwidthnKnob_2Label = uilabel(app.UIFigure);
            app.SignalwidthnKnob_2Label.HorizontalAlignment = 'center';
            app.SignalwidthnKnob_2Label.Position = [543 127 133 23];
            app.SignalwidthnKnob_2Label.Text = 'Signal width n';

            % Create SignalwidthnKnob_2
            app.SignalwidthnKnob_2 = uiknob(app.UIFigure, 'continuous');
            app.SignalwidthnKnob_2.Limits = [10 100];
            app.SignalwidthnKnob_2.Position = [591 184 37 37];
            app.SignalwidthnKnob_2.Value = 10;

            % Create FunctionwidthnKnob_2Label
            app.FunctionwidthnKnob_2Label = uilabel(app.UIFigure);
            app.FunctionwidthnKnob_2Label.HorizontalAlignment = 'center';
            app.FunctionwidthnKnob_2Label.Position = [471 58 93 15];
            app.FunctionwidthnKnob_2Label.Text = 'Function width n';

            % Create FunctionwidthnKnob_2
            app.FunctionwidthnKnob_2 = uiknob(app.UIFigure, 'continuous');
            app.FunctionwidthnKnob_2.Limits = [10 100];
            app.FunctionwidthnKnob_2.Position = [498 107 37 37];
            app.FunctionwidthnKnob_2.Value = 10;

            % Create Label_2
            app.Label_2 = uilabel(app.UIFigure);
            app.Label_2.Position = [355 257 310 15];
            app.Label_2.Text = '_____________________________________________';

            % Create CONVOLVEButton
            app.CONVOLVEButton = uibutton(app.UIFigure, 'push');
            app.CONVOLVEButton.ButtonPushedFcn = createCallbackFcn(app, @CONVOLVEButtonPushed, true);
            app.CONVOLVEButton.Position = [1034 517 205 45];
            app.CONVOLVEButton.Text = 'CONVOLVE';

            % Create exitButton
            app.exitButton = uibutton(app.UIFigure, 'push');
            app.exitButton.ButtonPushedFcn = createCallbackFcn(app, @exitButtonPushed, true);
            app.exitButton.Position = [1021 30 100 22];
            app.exitButton.Text = 'exit';

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.UIFigure);
            title(app.UIAxes5, 'Expected convolved result')
            xlabel(app.UIAxes5, 'n')
            ylabel(app.UIAxes5, 'Amplitude')
            app.UIAxes5.Position = [675 73 300 185];
        end
    end

    methods (Access = public)

        % Construct app
        function app = discreteconv

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end