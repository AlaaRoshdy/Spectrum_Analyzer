classdef FIRfilter < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        FIRfilterLabel                  matlab.ui.control.Label
        DesiredresponseEditFieldLabel   matlab.ui.control.Label
        DesiredresponseEditField        matlab.ui.control.NumericEditField
        DesignedresponseEditFieldLabel  matlab.ui.control.Label
        DesignedresponseEditField       matlab.ui.control.NumericEditField
        AmplitudeDropDownLabel          matlab.ui.control.Label
        AmplitudeDropDown               matlab.ui.control.DropDown
        CalculateButton                 matlab.ui.control.Button
        BackButton                      matlab.ui.control.Button
        ExitButton                      matlab.ui.control.Button
        UIAxes5                         matlab.ui.control.UIAxes
        PleaseenteranoddnumberLabel     matlab.ui.control.Label
        LeastsquarederrorEditFieldLabel  matlab.ui.control.Label
        LeastsquarederrorEditField      matlab.ui.control.NumericEditField
    end


    methods (Access = private)
    
        function results = calculate(app)
            cla(app.UIAxes5);
            %Initialize the variables
            
            %desired and designed filter response length
            L = app.DesiredresponseEditField.Value;
            N = app.DesignedresponseEditField.Value;
            %Cut off frequency for low pass filter
            w_c = 0.25*pi;
            %Shift the signals by half the length of the response
            halfN = (N-1)/2;
            % Initialize the w for the matrix
            wL = pi*(0:L-1)/L;
            %%%%%%%%%%%%%%%%%%%%%%%%
            %Calculate Hdesired
            %Get the amplitude of the Hdesired signal
            %It is an array of ones and zeros
            %The ones are specified based on the cutoff frequency
            %Ones at w less than w_c  
            Hdesired = (wL<=w_c);
            %%%%%%%%%%%%%%%%%%%%%%%%
            %Calculat Hdesigned
            %Create matrix F with dimensions (L x ((N-1)/2 +1) )
            F = [ones(L,1) 2*cos((1:halfN).*wL')];
            h = pinv(F)*Hdesired';
            
            wfine = linspace(0,pi,L);
            %Modify the h to make it even symmetric flipping the signal and
            %concatinating the flipped signal with the original signal
            flipH=fliplr(h')
            hsymmetric = [ flipH(1:length(flipH)-1) , h']
            %get the freq response of the h
            H = freqz(hsymmetric,1,wfine);
            
            %%%%%%%%%%%%%%%%%%%%%%
            %Specify the type of the y-axis and plot the graphs
            AmplitudePowType = app.AmplitudeDropDown.Value;
            %plot the graph for the designed h             
                %Set the y axis scale
                    switch AmplitudePowType
                        case 'Linear'
                                plot(app.UIAxes5, wfine/(pi),abs(H));
                                hold(app.UIAxes5, 'on');  
                                plot(app.UIAxes5,wfine/(pi), abs(Hdesired));
                                
                        case 'Logarithmic'
                                HLOG = pow2db(abs(H));
                                HdesiredLOG = pow2db(abs(Hdesired));
                                plot(app.UIAxes5, wfine/(pi),(HLOG));
                                hold(app.UIAxes5, 'on');  
                                plot(app.UIAxes5,wfine/(pi),(HdesiredLOG));
                                
                    end
            %%%%%%%%%%%%%%%%%%%%%
            %Calculate least squares error
            e = (F*h)' - Hdesired;
            app.LeastsquarederrorEditField.Value = abs((e)*(e)');
        end
        
    end


    methods (Access = private)

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            calculate(app);
            
        end

        % Value changed function: DesiredresponseEditField
        function DesiredresponseEditFieldValueChanged(app, event)
            value = app.DesignedresponseEditField.Value;
            app.DesiredresponseEditField.Limits = [value inf];
            %Updated the desired response field
            value = app.DesiredresponseEditField.Value;
            if(rem(value,2)==0)  %If the input is not an odd number, change it to odd
                app.DesiredresponseEditField.Value = app.DesiredresponseEditField.Value -1;
            end
            app.DesignedresponseEditField.Limits = [51 value];
        end

        % Value changed function: DesignedresponseEditField
        function DesignedresponseEditFieldValueChanged(app, event)
            value = app.DesiredresponseEditField.Value;
            app.DesignedresponseEditField.Limits = [51 value];
            %Update the designed response field
            value = app.DesignedresponseEditField.Value;
            if(rem(value,2)==0)  %If the input is not an odd number, change it to odd
                app.DesignedresponseEditField.Value = app.DesignedresponseEditField.Value -1;
            end
            app.DesiredresponseEditField.Limits = [value inf];
        end

        % Button pushed function: BackButton
        function BackButtonPushed(app, event)
            mainwindow;
            closereq;
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
                app.delete;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 763 480];
            app.UIFigure.Name = 'UI Figure';

            % Create FIRfilterLabel
            app.FIRfilterLabel = uilabel(app.UIFigure);
            app.FIRfilterLabel.FontSize = 22;
            app.FIRfilterLabel.Position = [339 400 89 29];
            app.FIRfilterLabel.Text = 'FIR filter';

            % Create DesiredresponseEditFieldLabel
            app.DesiredresponseEditFieldLabel = uilabel(app.UIFigure);
            app.DesiredresponseEditFieldLabel.HorizontalAlignment = 'right';
            app.DesiredresponseEditFieldLabel.Position = [500 258 100 15];
            app.DesiredresponseEditFieldLabel.Text = 'Desired response';

            % Create DesiredresponseEditField
            app.DesiredresponseEditField = uieditfield(app.UIFigure, 'numeric');
            app.DesiredresponseEditField.Limits = [51 Inf];
            app.DesiredresponseEditField.ValueChangedFcn = createCallbackFcn(app, @DesiredresponseEditFieldValueChanged, true);
            app.DesiredresponseEditField.Position = [615 254 100 22];
            app.DesiredresponseEditField.Value = 51;

            % Create DesignedresponseEditFieldLabel
            app.DesignedresponseEditFieldLabel = uilabel(app.UIFigure);
            app.DesignedresponseEditFieldLabel.HorizontalAlignment = 'right';
            app.DesignedresponseEditFieldLabel.Position = [491 216 109 15];
            app.DesignedresponseEditFieldLabel.Text = 'Designed response';

            % Create DesignedresponseEditField
            app.DesignedresponseEditField = uieditfield(app.UIFigure, 'numeric');
            app.DesignedresponseEditField.Limits = [51 Inf];
            app.DesignedresponseEditField.ValueChangedFcn = createCallbackFcn(app, @DesignedresponseEditFieldValueChanged, true);
            app.DesignedresponseEditField.Position = [615 212 100 22];
            app.DesignedresponseEditField.Value = 51;

            % Create AmplitudeDropDownLabel
            app.AmplitudeDropDownLabel = uilabel(app.UIFigure);
            app.AmplitudeDropDownLabel.HorizontalAlignment = 'right';
            app.AmplitudeDropDownLabel.Position = [541 160 59 15];
            app.AmplitudeDropDownLabel.Text = 'Amplitude';

            % Create AmplitudeDropDown
            app.AmplitudeDropDown = uidropdown(app.UIFigure);
            app.AmplitudeDropDown.Items = {'Linear', 'Logarithmic'};
            app.AmplitudeDropDown.Position = [615 156 100 22];
            app.AmplitudeDropDown.Value = 'Linear';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.UIFigure, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.Position = [500 67 100 22];
            app.CalculateButton.Text = 'Calculate';

            % Create BackButton
            app.BackButton = uibutton(app.UIFigure, 'push');
            app.BackButton.ButtonPushedFcn = createCallbackFcn(app, @BackButtonPushed, true);
            app.BackButton.Position = [615 67 100 22];
            app.BackButton.Text = 'Back';

            % Create ExitButton
            app.ExitButton = uibutton(app.UIFigure, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Position = [558 28 100 22];
            app.ExitButton.Text = 'Exit';

            % Create UIAxes5
            app.UIAxes5 = uiaxes(app.UIFigure);
            title(app.UIAxes5, 'FIR filter')
            xlabel(app.UIAxes5, 'Normalized Frequency Hz')
            ylabel(app.UIAxes5, 'Magnitude |H(w)|')
            app.UIAxes5.Position = [24 88 441 272];

            % Create PleaseenteranoddnumberLabel
            app.PleaseenteranoddnumberLabel = uilabel(app.UIFigure);
            app.PleaseenteranoddnumberLabel.Position = [500 286 230 42];
            app.PleaseenteranoddnumberLabel.Text = {'Please enter an odd number.'; 'If an odd number is not entered, the value'; ' will be decremented automatically'};

            % Create LeastsquarederrorEditFieldLabel
            app.LeastsquarederrorEditFieldLabel = uilabel(app.UIFigure);
            app.LeastsquarederrorEditFieldLabel.HorizontalAlignment = 'right';
            app.LeastsquarederrorEditFieldLabel.Position = [237 31 110 15];
            app.LeastsquarederrorEditFieldLabel.Text = 'Least squared error';

            % Create LeastsquarederrorEditField
            app.LeastsquarederrorEditField = uieditfield(app.UIFigure, 'numeric');
            app.LeastsquarederrorEditField.Editable = 'off';
            app.LeastsquarederrorEditField.Position = [362.03125 27 100 22];
        end
    end

    methods (Access = public)

        % Construct app
        function app = FIRfilter

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