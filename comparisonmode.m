classdef comparisonmode < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UIAxes                        matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        WindowchoiceDropDownLabel     matlab.ui.control.Label
        WindowchoiceDropDown          matlab.ui.control.DropDown
        kNDFTptchoiceKnobLabel        matlab.ui.control.Label
        kNDFTptchoiceKnob             matlab.ui.control.DiscreteKnob
        WindowlengthLDropDownLabel    matlab.ui.control.Label
        WindowlengthLDropDown         matlab.ui.control.DropDown
        UIAxes_2                      matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
        WindowchoiceDropDown_2Label   matlab.ui.control.Label
        WindowchoiceDropDown_2        matlab.ui.control.DropDown
        kNDFTptchoiceKnob_2Label      matlab.ui.control.Label
        kNDFTptchoiceKnob_2           matlab.ui.control.DiscreteKnob
        WindowlengthLDropDown_2Label  matlab.ui.control.Label
        WindowlengthLDropDown_2       matlab.ui.control.DropDown
        TrydemofunctionCheckBox       matlab.ui.control.CheckBox
        DemoFunctionsDropDownLabel    matlab.ui.control.Label
        DemoFunctionsDropDown         matlab.ui.control.DropDown
        ComparisonmodeLabel           matlab.ui.control.Label
        BackButton                    matlab.ui.control.Button
        ExitButton                    matlab.ui.control.Button
        RunButton                     matlab.ui.control.Button
        SamplefrequencyHzSlider       matlab.ui.control.Slider
        Label                         matlab.ui.control.Label
        SampleFrequencyHzLabel        matlab.ui.control.Label
        RBWEditFieldLabel             matlab.ui.control.Label
        RBWEditField                  matlab.ui.control.NumericEditField
        RBWEditField_2Label           matlab.ui.control.Label
        RBWEditField_2                matlab.ui.control.NumericEditField
        BrowseButton                  matlab.ui.control.Button
        DirectorywillopenagainiffilechosenisnotwavextensionLabel  matlab.ui.control.Label
        InputfilenameEditFieldLabel   matlab.ui.control.Label
        InputfilenameEditField        matlab.ui.control.EditField
        FrequencybandLabel            matlab.ui.control.Label
        HzLabel                       matlab.ui.control.Label
        HzLabel_2                     matlab.ui.control.Label
        FromEditFieldLabel            matlab.ui.control.Label
        FromEditField                 matlab.ui.control.NumericEditField
        ToEditFieldLabel              matlab.ui.control.Label
        ToEditField                   matlab.ui.control.NumericEditField
        AmplitudetypeDropDownLabel    matlab.ui.control.Label
        AmplitudetypeDropDown         matlab.ui.control.DropDown
    end


    methods (Access = private)
    
        function DFT(app)
            % Initializing variables that are common between the examples and input files
            %signal 1
            window = app.WindowchoiceDropDown.Value;
            L = str2num(app.WindowlengthLDropDown.Value);
            N = str2num(app.kNDFTptchoiceKnob.Value);
            %signal 2
            window2 = app.WindowchoiceDropDown_2.Value;
            L2 = str2num(app.WindowlengthLDropDown_2.Value);
            N2 = str2num(app.kNDFTptchoiceKnob_2.Value);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            % Choosing the function that will be used.
            % If the check box is checked, the examples will be used instead of input file
            if(app.TrydemofunctionCheckBox.Value)
                %%%%
                % Initializing the variables of the example function
                fs = app.SamplefrequencyHzSlider.Value;         %sample frequency
                ts = 1/fs;                                      %sample to sample width
                %signal 1
                t = (1:N)*ts;                                   %Time in s
                n = int8(t/ts);                               %Time in n
                % Get RBW
                app.RBWEditField.Value = fs/N;
                %signal 2
                t2 = (1:N2)*ts;
                n2 = int8(t2/ts);
                % Get RBW
                app.RBWEditField_2.Value = fs/N2;
                func = app.DemoFunctionsDropDown.Value;
                %%%%
                x = zeros(1,length(n));
                x2 = zeros(1,length(n2));
                switch func
                    case 'sinc'
                    x(n) = sinc(t);
                    x2(n2) = sinc(t2);
                    case 'sine'
                    x(n) = sin(2*pi*t);
                    x2(n2) = sin(2*pi*t2);
                    case 'rect'
                    x(n) = ones(1,length(t)); 
                    x2(n2) = ones(1,length(t2));
                end
                %%%%
            else
                %%%%
                % Initializing the variables
                N = N*10^3;
                N2 = N2*10^3;
                [x,fs] = audioread(app.InputfilenameEditField.Value ,[1,N]); %inputting audio file
                [x2,fs] = audioread(app.InputfilenameEditField.Value ,[1,N2]); %inputting audio file
                app.RBWEditField.Value = fs/N;
                app.RBWEditField_2.Value = fs/N2;
                ts = 1/fs;
                t = (1:N)*(ts); %Take the first N points
                t2 = (1:N2)*ts;
                n = int32(t/ts);
                n2 = int32(t/ts);
                x = x'; %Since the output x is a column vector, it should be changed to row vector for coming operations.
                x2 = x2';
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Switch cases for window 1 and window 2
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Switch cases for window 1
            w = zeros(1,length(t));
            cla(app.UIAxes);
            switch window
                case 'Rectangular'
                    w(1:L) = 1;
                case 'Triangular'
                    w(1:L/2) = t(1:L/2)/(L/2);
                    w(L/2:L) = 0.2 - t(L/2:L)/(L/2);
                case 'Hanning'
                    w(1:L) = 0.5 - 0.5*cos(2*pi*(1:L)/L);
                case 'Hamming'
                    w(1:L) = 0.54 - 0.46*cos(2*pi*(1:L)/L);
            end 
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plotting the graph
            % for window 1
            result = x.*w;
            fn = stem(app.UIAxes,0:N-1,result); 
            set(fn, 'marker', 'none');
            %specify the yscale
            amptype = app.AmplitudetypeDropDown.Value;
            switch amptype
                case 'Linear'
                stem(app.UIAxes2,((1:N)*fs/N),abs(fft(result,N)));
                case 'Logarithmic'
                stem(app.UIAxes2,((1:N)*fs/N),pow2db(abs(fft(result,N))));
            end
            %frequency span
            xlim(app.UIAxes2,[app.FromEditField.Value app.ToEditField.Value]);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Switch cases for window 2
            w2 = zeros(1,length(t2));
            cla(app.UIAxes_2);
            switch window2
                case 'Rectangular'
                    w2(1:L2) = 1;
                case 'Triangular'
                    w2(1:L2/2) = t(1:L2/2)/(L2/2);
                    w2(L2/2:L2) = 0.2 - t(L2/2:L2)/(L2/2);
                case 'Hanning'
                    w2(1:L2) = 0.5 - 0.5*cos(2*pi*(1:L2)/L2);
                case 'Hamming'
                    w2(1:L2) = 0.54 - 0.46*cos(2*pi*(1:L2)/L2);
            end 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plotting the graph
            % for window 2
            result2 = x2.*w2;
            fn2 = stem(app.UIAxes_2,0:N2-1,result2); 
            set(fn2, 'marker','none');
            %specify the y scale
            amptype = app.AmplitudetypeDropDown.Value;
            switch amptype
                case 'Linear'
                stem(app.UIAxes2_2,(0:N2-1)*(fs/N2),abs(fft(result2,N2)));
                case 'Logarithmic'
                stem(app.UIAxes2_2,(0:N2-1)*(fs/N2),pow2db(abs(fft(result2,N2))));
            end
            %frequency span
            xlim(app.UIAxes2_2,[app.FromEditField.Value app.ToEditField.Value]);
                            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
    end


    methods (Access = private)

        % Button pushed function: BackButton
        function BackButtonPushed(app, event)
            spectrumanalyzer;
            closereq;
        end

        % Value changed function: TrydemofunctionCheckBox
        function TrydemofunctionCheckBoxValueChanged(app, event)
            value = app.TrydemofunctionCheckBox.Value;
            %If the check box is checked, disable the input file option and enable the demo options list
            %Change the N-DFT choice from 2^n to (2^n)*10^3 where n is an integer
            if(value == true)
                set(app.DemoFunctionsDropDown, 'Enable', 'on');
                set(app.BrowseButton, 'Enable', 'off');
                set(app.RunButton, 'Enable', 'on');
                app.kNDFTptchoiceKnobLabel.Text = 'N-DFT pt choice';
                app.kNDFTptchoiceKnob_2Label.Text = 'N-DFT pt choice';
                app.WindowlengthLDropDown.Items = {'5'};
                app.WindowlengthLDropDown_2.Items = {'5'};
                set(app.InputfilenameEditField, 'Enable', 'off');
                set(app.SamplefrequencyHzSlider, 'Enable', 'on');
            else
                set(app.DemoFunctionsDropDown, 'Enable', 'off');
                set(app.BrowseButton, 'Enable', 'on');
                app.kNDFTptchoiceKnobLabel.Text = 'k N-DFT pt choice';
                app.kNDFTptchoiceKnob_2Label.Text = 'k N-DFT pt choice';
                app.WindowlengthLDropDown.Items = {'5000'};
                app.WindowlengthLDropDown_2.Items = {'5000'};
                set(app.InputfilenameEditField, 'Enable', 'on');
                set(app.SamplefrequencyHzSlider, 'Enable', 'off');
                if(app.InputfilenameEditField.Value) %IF there is an input file
                    set(app.RunButton, 'Enable', 'on');
                else
                    set(app.RunButton, 'Enable', 'off');
                end
            end
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            DFT(app);
        end

        % Value changed function: kNDFTptchoiceKnob
        function kNDFTptchoiceKnobValueChanged(app, event)
            value = app.kNDFTptchoiceKnob.Value;
            %To ensure that the window length is less than the DFT points,
            %The items in the window length option are adjusted based on
            %The DFT points of the signal.
            %The DFT points of the signal is = signal frequency*Signal length
            
            %if the function used is an example
           if(app.TrydemofunctionCheckBox.Value == true)
            switch value
               case '8'
                   app.WindowlengthLDropDown.Items = {'5'};
               case '16'
                   app.WindowlengthLDropDown.Items = {'5', '10', '15'};
               case '32'
                   app.WindowlengthLDropDown.Items = {'5', '10', '15', '20', '25', '30'};
               case '64'
                   app.WindowlengthLDropDown.Items = {'5', '10', '15', '20', '25', '30','35', '40', '45', '50', '55', '60'};
            end
            %else if the function used is an input file
           else
               switch value
               case '8'
                   app.WindowlengthLDropDown.Items = {'5000'};
               case '16'
                   app.WindowlengthLDropDown.Items = {'5000', '10000', '15000'};
               case '32'
                   app.WindowlengthLDropDown.Items = {'5000', '10000', '15000', '20000', '25000', '30000'};
               case '64'
                   app.WindowlengthLDropDown.Items = {'5000', '10000', '15000', '20000', '25000', '30000','35000', '40000', '45000', '50000', '55000', '60000'};
               end
           end
        end

        % Value changed function: kNDFTptchoiceKnob_2
        function kNDFTptchoiceKnob_2ValueChanged(app, event)
            value = app.kNDFTptchoiceKnob_2.Value;
            %To ensure that the window length is less than the DFT points,
            %The items in the window length option are adjusted based on
            %The DFT points of the signal.
            %The DFT points of the signal is = signal frequency*Signal length
            
            %if the function used is an example
           if(app.TrydemofunctionCheckBox.Value == true)
            switch value
               case '8'
                   app.WindowlengthLDropDown_2.Items = {'5'};
               case '16'
                   app.WindowlengthLDropDown_2.Items = {'5', '10', '15'};
               case '32'
                   app.WindowlengthLDropDown_2.Items = {'5', '10', '15', '20', '25', '30'};
               case '64'
                   app.WindowlengthLDropDown_2.Items = {'5', '10', '15', '20', '25', '30','35', '40', '45', '50', '55', '60'};
            end
            %else if the function used is an input file
           else
               switch value
               case '8'
                   app.WindowlengthLDropDown_2.Items = {'5000'};
               case '16'
                   app.WindowlengthLDropDown_2.Items = {'5000', '10000', '15000'};
               case '32'
                   app.WindowlengthLDropDown_2.Items = {'5000', '10000', '15000', '20000', '25000', '30000'};
               case '64'
                   app.WindowlengthLDropDown_2.Items = {'5000', '10000', '15000', '20000', '25000', '30000','35000', '40000', '45000', '50000', '55000', '60000'};
               end
           end
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            app.delete;
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            [file path] = uigetfile('*.wav');
            if(file) %If a file is chosen
                while (file(end-2:end) ~= 'wav') %while the file extension is not wav
                    [file path]= uigetfile('*.wav');  %get the user to choose a file again
                end
                app.InputfilenameEditField.Value = [path file];
                set(app.RunButton, 'Enable', 'on');
            end
               
        end

        % Value changed function: ToEditField
        function ToEditFieldValueChanged(app, event)
            min = app.FromEditField.Value;
            app.ToEditField.Limits = [min+1 inf];
            %Update the from field limits
            max = app.ToEditField.Value;
            app.FromEditField.Limits = [0 max-1];
        end

        % Value changed function: FromEditField
        function FromEditFieldValueChanged(app, event)
            max = app.ToEditField.Value;
            app.FromEditField.Limits = [0 max-1];
            %Update the to field limits
            min = app.FromEditField.Value;
            app.ToEditField.Limits = [min inf];
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1147 645];
            app.UIFigure.Name = 'UI Figure';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Time domain')
            xlabel(app.UIAxes, 'Time n')
            ylabel(app.UIAxes, 'Amplitude')
            app.UIAxes.Position = [42 274 300 185];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.UIFigure);
            title(app.UIAxes2, 'Frequency domain')
            xlabel(app.UIAxes2, 'Frequency Hz')
            ylabel(app.UIAxes2, 'Amplitude')
            app.UIAxes2.Position = [42 75 300 185];

            % Create WindowchoiceDropDownLabel
            app.WindowchoiceDropDownLabel = uilabel(app.UIFigure);
            app.WindowchoiceDropDownLabel.HorizontalAlignment = 'right';
            app.WindowchoiceDropDownLabel.Position = [366 414 86 15];
            app.WindowchoiceDropDownLabel.Text = 'Window choice';

            % Create WindowchoiceDropDown
            app.WindowchoiceDropDown = uidropdown(app.UIFigure);
            app.WindowchoiceDropDown.Items = {'Rectangular', 'Hanning', 'Hamming'};
            app.WindowchoiceDropDown.Position = [467 410 100 22];
            app.WindowchoiceDropDown.Value = 'Rectangular';

            % Create kNDFTptchoiceKnobLabel
            app.kNDFTptchoiceKnobLabel = uilabel(app.UIFigure);
            app.kNDFTptchoiceKnobLabel.HorizontalAlignment = 'center';
            app.kNDFTptchoiceKnobLabel.Position = [400 197 102 15];
            app.kNDFTptchoiceKnobLabel.Text = 'k N-DFT pt choice';

            % Create kNDFTptchoiceKnob
            app.kNDFTptchoiceKnob = uiknob(app.UIFigure, 'discrete');
            app.kNDFTptchoiceKnob.Items = {'8', '16', '32', '64'};
            app.kNDFTptchoiceKnob.ValueChangedFcn = createCallbackFcn(app, @kNDFTptchoiceKnobValueChanged, true);
            app.kNDFTptchoiceKnob.Position = [452 227 60 60];
            app.kNDFTptchoiceKnob.Value = '8';

            % Create WindowlengthLDropDownLabel
            app.WindowlengthLDropDownLabel = uilabel(app.UIFigure);
            app.WindowlengthLDropDownLabel.HorizontalAlignment = 'right';
            app.WindowlengthLDropDownLabel.Position = [355 374 108 15];
            app.WindowlengthLDropDownLabel.Text = 'Window length L = ';

            % Create WindowlengthLDropDown
            app.WindowlengthLDropDown = uidropdown(app.UIFigure);
            app.WindowlengthLDropDown.Items = {'5000'};
            app.WindowlengthLDropDown.Position = [467 370 100 22];
            app.WindowlengthLDropDown.Value = '5000';

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.UIFigure);
            title(app.UIAxes_2, 'Time domain')
            xlabel(app.UIAxes_2, 'Time n')
            ylabel(app.UIAxes_2, 'Amplitude')
            app.UIAxes_2.Position = [587 274 300 185];

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.UIFigure);
            title(app.UIAxes2_2, 'Frequency domain')
            xlabel(app.UIAxes2_2, 'Frequency Hz')
            ylabel(app.UIAxes2_2, 'Amplitude')
            app.UIAxes2_2.Position = [587 75 300 185];

            % Create WindowchoiceDropDown_2Label
            app.WindowchoiceDropDown_2Label = uilabel(app.UIFigure);
            app.WindowchoiceDropDown_2Label.HorizontalAlignment = 'right';
            app.WindowchoiceDropDown_2Label.Position = [911 414 86 15];
            app.WindowchoiceDropDown_2Label.Text = 'Window choice';

            % Create WindowchoiceDropDown_2
            app.WindowchoiceDropDown_2 = uidropdown(app.UIFigure);
            app.WindowchoiceDropDown_2.Items = {'Rectangular', 'Hanning', 'Hamming'};
            app.WindowchoiceDropDown_2.Position = [1012 410 100 22];
            app.WindowchoiceDropDown_2.Value = 'Rectangular';

            % Create kNDFTptchoiceKnob_2Label
            app.kNDFTptchoiceKnob_2Label = uilabel(app.UIFigure);
            app.kNDFTptchoiceKnob_2Label.HorizontalAlignment = 'center';
            app.kNDFTptchoiceKnob_2Label.Position = [945 197 102 15];
            app.kNDFTptchoiceKnob_2Label.Text = 'k N-DFT pt choice';

            % Create kNDFTptchoiceKnob_2
            app.kNDFTptchoiceKnob_2 = uiknob(app.UIFigure, 'discrete');
            app.kNDFTptchoiceKnob_2.Items = {'8', '16', '32', '64'};
            app.kNDFTptchoiceKnob_2.ValueChangedFcn = createCallbackFcn(app, @kNDFTptchoiceKnob_2ValueChanged, true);
            app.kNDFTptchoiceKnob_2.Position = [997 227 60 60];
            app.kNDFTptchoiceKnob_2.Value = '8';

            % Create WindowlengthLDropDown_2Label
            app.WindowlengthLDropDown_2Label = uilabel(app.UIFigure);
            app.WindowlengthLDropDown_2Label.HorizontalAlignment = 'right';
            app.WindowlengthLDropDown_2Label.Position = [900 374 108 15];
            app.WindowlengthLDropDown_2Label.Text = 'Window length L = ';

            % Create WindowlengthLDropDown_2
            app.WindowlengthLDropDown_2 = uidropdown(app.UIFigure);
            app.WindowlengthLDropDown_2.Items = {'5000'};
            app.WindowlengthLDropDown_2.Position = [1012 370 100 22];
            app.WindowlengthLDropDown_2.Value = '5000';

            % Create TrydemofunctionCheckBox
            app.TrydemofunctionCheckBox = uicheckbox(app.UIFigure);
            app.TrydemofunctionCheckBox.ValueChangedFcn = createCallbackFcn(app, @TrydemofunctionCheckBoxValueChanged, true);
            app.TrydemofunctionCheckBox.Text = 'Try demo function';
            app.TrydemofunctionCheckBox.Position = [341 496 118 15];

            % Create DemoFunctionsDropDownLabel
            app.DemoFunctionsDropDownLabel = uilabel(app.UIFigure);
            app.DemoFunctionsDropDownLabel.HorizontalAlignment = 'right';
            app.DemoFunctionsDropDownLabel.Position = [89 496 93 15];
            app.DemoFunctionsDropDownLabel.Text = 'Demo Functions';

            % Create DemoFunctionsDropDown
            app.DemoFunctionsDropDown = uidropdown(app.UIFigure);
            app.DemoFunctionsDropDown.Items = {'sinc', 'sine', 'rect'};
            app.DemoFunctionsDropDown.Enable = 'off';
            app.DemoFunctionsDropDown.Position = [197 492 100 22];
            app.DemoFunctionsDropDown.Value = 'sinc';

            % Create ComparisonmodeLabel
            app.ComparisonmodeLabel = uilabel(app.UIFigure);
            app.ComparisonmodeLabel.HorizontalAlignment = 'center';
            app.ComparisonmodeLabel.FontSize = 22;
            app.ComparisonmodeLabel.Position = [496 583 185 29];
            app.ComparisonmodeLabel.Text = 'Comparison mode';

            % Create BackButton
            app.BackButton = uibutton(app.UIFigure, 'push');
            app.BackButton.ButtonPushedFcn = createCallbackFcn(app, @BackButtonPushed, true);
            app.BackButton.Position = [977 105 100 22];
            app.BackButton.Text = 'Back';

            % Create ExitButton
            app.ExitButton = uibutton(app.UIFigure, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Position = [977 69 100 22];
            app.ExitButton.Text = 'Exit';

            % Create RunButton
            app.RunButton = uibutton(app.UIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Enable = 'off';
            app.RunButton.Position = [977 142 100 22];
            app.RunButton.Text = 'Run';

            % Create SamplefrequencyHzSlider
            app.SamplefrequencyHzSlider = uislider(app.UIFigure);
            app.SamplefrequencyHzSlider.Limits = [10 20];
            app.SamplefrequencyHzSlider.Enable = 'off';
            app.SamplefrequencyHzSlider.Position = [927 533 150 3];
            app.SamplefrequencyHzSlider.Value = 10;

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.Position = [188 469 846 15];
            app.Label.Text = '___________________________________________________________________________________________________________________________';

            % Create SampleFrequencyHzLabel
            app.SampleFrequencyHzLabel = uilabel(app.UIFigure);
            app.SampleFrequencyHzLabel.Position = [785 521 124 15];
            app.SampleFrequencyHzLabel.Text = 'Sample Frequency Hz';

            % Create RBWEditFieldLabel
            app.RBWEditFieldLabel = uilabel(app.UIFigure);
            app.RBWEditFieldLabel.HorizontalAlignment = 'right';
            app.RBWEditFieldLabel.Position = [361 128 33 15];
            app.RBWEditFieldLabel.Text = 'RBW';

            % Create RBWEditField
            app.RBWEditField = uieditfield(app.UIFigure, 'numeric');
            app.RBWEditField.Editable = 'off';
            app.RBWEditField.Enable = 'off';
            app.RBWEditField.Position = [355 107 44 22];

            % Create RBWEditField_2Label
            app.RBWEditField_2Label = uilabel(app.UIFigure);
            app.RBWEditField_2Label.HorizontalAlignment = 'right';
            app.RBWEditField_2Label.Position = [906 128 33 15];
            app.RBWEditField_2Label.Text = 'RBW';

            % Create RBWEditField_2
            app.RBWEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.RBWEditField_2.Editable = 'off';
            app.RBWEditField_2.Enable = 'off';
            app.RBWEditField_2.Position = [900 107 44 22];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.UIFigure, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [197 533 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create DirectorywillopenagainiffilechosenisnotwavextensionLabel
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel = uilabel(app.UIFigure);
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel.Position = [156 517 329 15];
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel.Text = 'Directory will open again if file chosen is not .wav extension.';

            % Create InputfilenameEditFieldLabel
            app.InputfilenameEditFieldLabel = uilabel(app.UIFigure);
            app.InputfilenameEditFieldLabel.HorizontalAlignment = 'right';
            app.InputfilenameEditFieldLabel.Position = [90 540 84 15];
            app.InputfilenameEditFieldLabel.Text = 'Input file name';

            % Create InputfilenameEditField
            app.InputfilenameEditField = uieditfield(app.UIFigure, 'text');
            app.InputfilenameEditField.Editable = 'off';
            app.InputfilenameEditField.Position = [305 533 132 22];

            % Create FrequencybandLabel
            app.FrequencybandLabel = uilabel(app.UIFigure);
            app.FrequencybandLabel.Position = [596 544 92 15];
            app.FrequencybandLabel.Text = 'Frequency band';

            % Create HzLabel
            app.HzLabel = uilabel(app.UIFigure);
            app.HzLabel.Position = [610 514 25 15];
            app.HzLabel.Text = 'Hz';

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.UIFigure);
            app.HzLabel_2.Position = [738 514 25 15];
            app.HzLabel_2.Text = 'Hz';

            % Create FromEditFieldLabel
            app.FromEditFieldLabel = uilabel(app.UIFigure);
            app.FromEditFieldLabel.HorizontalAlignment = 'right';
            app.FromEditFieldLabel.Position = [517 514 33 15];
            app.FromEditFieldLabel.Text = 'From';

            % Create FromEditField
            app.FromEditField = uieditfield(app.UIFigure, 'numeric');
            app.FromEditField.Limits = [0 Inf];
            app.FromEditField.ValueChangedFcn = createCallbackFcn(app, @FromEditFieldValueChanged, true);
            app.FromEditField.Position = [562 510 35 22];

            % Create ToEditFieldLabel
            app.ToEditFieldLabel = uilabel(app.UIFigure);
            app.ToEditFieldLabel.HorizontalAlignment = 'right';
            app.ToEditFieldLabel.Position = [650 514 25 15];
            app.ToEditFieldLabel.Text = 'To';

            % Create ToEditField
            app.ToEditField = uieditfield(app.UIFigure, 'numeric');
            app.ToEditField.Limits = [2 Inf];
            app.ToEditField.ValueChangedFcn = createCallbackFcn(app, @ToEditFieldValueChanged, true);
            app.ToEditField.Position = [690 510 37 22];
            app.ToEditField.Value = 2;

            % Create AmplitudetypeDropDownLabel
            app.AmplitudetypeDropDownLabel = uilabel(app.UIFigure);
            app.AmplitudetypeDropDownLabel.HorizontalAlignment = 'right';
            app.AmplitudetypeDropDownLabel.Position = [867 558 85 15];
            app.AmplitudetypeDropDownLabel.Text = 'Amplitude type';

            % Create AmplitudetypeDropDown
            app.AmplitudetypeDropDown = uidropdown(app.UIFigure);
            app.AmplitudetypeDropDown.Items = {'Linear', 'Logarithmic'};
            app.AmplitudetypeDropDown.Position = [967 554 100 22];
            app.AmplitudetypeDropDown.Value = 'Linear';
        end
    end

    methods (Access = public)

        % Construct app
        function app = comparisonmode

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