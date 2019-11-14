classdef spectrumanalyzer < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        TabGroup                      matlab.ui.container.TabGroup
        SpectrumanalyzerTab           matlab.ui.container.Tab
        SpectrumanalyzerLabel         matlab.ui.control.Label
        OptionsLabel                  matlab.ui.control.Label
        TrydemofunctionCheckBox       matlab.ui.control.CheckBox
        BrowseButton                  matlab.ui.control.Button
        DirectorywillopenagainiffilechosenisnotwavextensionLabel  matlab.ui.control.Label
        Label_4                       matlab.ui.control.Label
        InputoptionsLabel             matlab.ui.control.Label
        Label_6                       matlab.ui.control.Label
        Label_10                      matlab.ui.control.Label
        WindowchoiceDropDownLabel     matlab.ui.control.Label
        WindowchoiceDropDown          matlab.ui.control.DropDown
        InputfilenameLabel            matlab.ui.control.Label
        InputfilenameEditField        matlab.ui.control.EditField
        DemoFunctionsDropDownLabel    matlab.ui.control.Label
        DemoFunctionsDropDown         matlab.ui.control.DropDown
        WindowlengthLDropDownLabel    matlab.ui.control.Label
        WindowlengthLDropDown         matlab.ui.control.DropDown
        ComparisonmodeButton          matlab.ui.control.Button
        BackButton                    matlab.ui.control.Button
        RunButton_2                   matlab.ui.control.Button
        UIAxes                        matlab.ui.control.UIAxes
        UIAxes2                       matlab.ui.control.UIAxes
        UIAxes2_2                     matlab.ui.control.UIAxes
        Label_5                       matlab.ui.control.Label
        PlotsLabel                    matlab.ui.control.Label
        Label_7                       matlab.ui.control.Label
        FrequencybandLabel            matlab.ui.control.Label
        Label_8                       matlab.ui.control.Label
        Label_9                       matlab.ui.control.Label
        HzLabel                       matlab.ui.control.Label
        HzLabel_2                     matlab.ui.control.Label
        ExitButton_2                  matlab.ui.control.Button
        PlotDropDown_2Label           matlab.ui.control.Label
        PlotDropDown_2                matlab.ui.control.DropDown
        kNDFTptchoiceKnobLabel        matlab.ui.control.Label
        kNDFTptchoiceKnob             matlab.ui.control.DiscreteKnob
        SamplefrequencyHzLabel        matlab.ui.control.Label
        SamplefrequencyHzSlider       matlab.ui.control.Slider
        RBWEditFieldLabel             matlab.ui.control.Label
        RBWEditField                  matlab.ui.control.NumericEditField
        AmplitudeDropDownLabel        matlab.ui.control.Label
        AmplitudeDropDown             matlab.ui.control.DropDown
        FromEditFieldLabel            matlab.ui.control.Label
        FromEditField                 matlab.ui.control.NumericEditField
        ToEditFieldLabel              matlab.ui.control.Label
        ToEditField                   matlab.ui.control.NumericEditField
        CalculationsTab               matlab.ui.container.Tab
        UIAxes4                       matlab.ui.control.UIAxes
        CalculationsmodeLabel         matlab.ui.control.Label
        Switch                        matlab.ui.control.Switch
        PowerwithinspanLabel          matlab.ui.control.Label
        PowerwithinspanEditField      matlab.ui.control.NumericEditField
        PeakpointonspectrumEditFieldLabel  matlab.ui.control.Label
        PeakpointonspectrumEditField  matlab.ui.control.NumericEditField
        AvailableforinputfileoptiononlyLabel  matlab.ui.control.Label
    end


    methods (Access = private)
    
        function DFT(app)
            % Initializing variables that are common between the examples and input files
            window = app.WindowchoiceDropDown.Value;        %window type
            L = str2num(app.WindowlengthLDropDown.Value);   %window length
            N = str2num(app.kNDFTptchoiceKnob.Value);        %number of samples
            maxN = 64;                             %This will be used for calculating the peak value of the spectrum

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Choosing the function that will be used.
            % If the check box is checked, the examples will be used instead of input file
            if(app.TrydemofunctionCheckBox.Value)
                %%%%
                % Initializing the variables
                fs = app.SamplefrequencyHzSlider.Value;         %sample frequency
                ts = 1/fs;                                      %sample to sample width
                t = (1:N)*ts;                                   %Time in s
                n = int8(t/ts);                                 %Time in n
                % Get RBW
                app.RBWEditField.Value = fs/N;
                func = app.DemoFunctionsDropDown.Value;
                %%%%
                x = zeros(1,length(n));
                switch func
                    case 'sinc'
                    x(n) = sinc(t);
                    case 'sine'
                    x(n) = sin(2*pi*t); 
                    case 'rect'
                    x(n) = ones(1,length(t)); 
                end
                %%%%
            else
                %%%%
                % Initializing the variables
                N = N*10^3;                               %N-DFT choice
                maxN = maxN*10^3;                             %This will be used for calculating the peak value of the spectrum
                [x,fs] = audioread(app.InputfilenameEditField.Value,[1,N]); %inputting audio file
                app.RBWEditField.Value = fs/N;
                ts = 1/fs;                                %Width between samples in seconds
                t = (1:N)*(ts);                           
                n = int32(t/ts);                          %Range in discrete time n
                x = x';     %audioread returns a column vector and all the coming operations are row vectors so I took the transpose of the signal.  
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Switch cases for window type
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
            result = x.*w;
            fn = stem(app.UIAxes,0:N-1,result);
            set(fn, 'marker','none');
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plotting the graphs for DFT
            cla(app.UIAxes2);
            %%%%%%%%%%%%%%%%%%
                PlotType = app.PlotDropDown_2.Value;
                fftResult = (fft(result,N));
                AmplitudeType = app.AmplitudeDropDown.Value;
                
                %Set the plot type
                switch PlotType
                    case 'Mag and phase'
                            
                            %Plot the magnitude and phase
                            AmplitudeType = app.AmplitudeDropDown.Value;
                            %Set the y axis scale
                                switch AmplitudeType
                                    case 'Linear'
                                    stem(app.UIAxes2,(0:N-1)*fs/N,abs(fftResult));
                                    case 'Logarithmic'
                                     stem(app.UIAxes2,(0:N-1)*fs/N,pow2db(abs(fftResult)));
                                end 
                             stem(app.UIAxes2_2,(0:N-1)*fs/N,angle(fftResult)*180/pi);
                           
                            %Set the freqency span
                            xlim(app.UIAxes2,[app.FromEditField.Value app.ToEditField.Value]);
                            xlim(app.UIAxes2_2,[app.FromEditField.Value app.ToEditField.Value]);
                    
                            
                            %Markers task implemented on the magnitude plot
                            fig = figure('Name','For markers task')
                            stem((0:N-1)*fs/N,abs(fftResult));
                            xlim([app.FromEditField.Value app.ToEditField.Value]);
                            datacursormode on;
                            
                    case 'Real and Im'
                            
                            %Plot the real and imaginary axes
                            switch AmplitudeType
                                    case 'Linear'
                                    stem(app.UIAxes2,(0:N-1)*fs/N,real(fftResult));
                                case 'Logarithmic'
                                    stem(app.UIAxes2,(0:N-1)*fs/N,pow2db(abs(real(fftResult))));
                            end
                            stem(app.UIAxes2_2,(0:N-1)*fs/N, imag(fftResult));
                            
                            %Set the frequency span
                            xlim(app.UIAxes2,[app.FromEditField.Value app.ToEditField.Value]);
                            xlim(app.UIAxes2_2,[app.FromEditField.Value app.ToEditField.Value]);
                            
                            %Markers task implemented on the real plot
                            fig = figure('Name','For markers task')
                            stem((0:N-1)*fs/N,real(fftResult));
                            xlim([app.FromEditField.Value app.ToEditField.Value]);
                            datacursormode on;
                            
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
            %Calculations tab starts
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            %Indicate whethe there is a DC bias
                if(fftResult(1) == 0)
                    app.Switch.Value = 'No DC Bias';
                else
                    app.Switch.Value = 'DC Bias';
                end
            
            %Calculate peak point
            app.PeakpointonspectrumEditField.Value = max(abs(fft(result,maxN)));    
            %%%%%%%%%%%%%% 
            %Calculate the PSD
            if (~app.TrydemofunctionCheckBox.Value)
                power = bandpower(fftResult,fs,[app.FromEditField.Value app.ToEditField.Value]);
            app.PowerwithinspanEditField.Value = power;
            end
            %%%%%%%%%%%%%%
            %Calculate RMS averaging
            
            %Initialize the number of FFTs to be made for the signal
            NoOfFFTs = 4;
            %Calculate the number of points taken for each FFT operation
            NoOfPoints = N/NoOfFFTs; 
            %N/4 because it is the largest value that will divide up
            %the signal into seveal FFTs. i.e. if I chose NoOfPoints
            %to be N/8, for the 8 point DFT the number of FFTs made will be
            %1 which makes RMS averaging unnecessary.
            
            %Initialize the range of values that we will perform FFT on
            first=1;
            last=NoOfPoints;
            
            %Perform FFT 4 times, each time taking a different range
            for k = 1:NoOfFFTs
            FFTs(k,:)  = abs(fft(result(first:last),NoOfPoints))
            %increment the range
            %Let there be 50% overlap between the ranges
            %NoOfPoints/2 makess this overlap happen
            first = first + NoOfPoints/2;
            last = last + NoOfPoints/2;
            end
            %Take the average of the solution
            RMS = sum(FFTs,1)./NoOfPoints;
            %Plot RMS 
            stem(app.UIAxes4,RMS);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
            
        end
    end



    methods (Access = private)

        % Button pushed function: ComparisonmodeButton
        function ComparisonmodeButtonPushed(app, event)
            comparisonmode;
            closereq;
        end

        % Button pushed function: BackButton
        function BackButtonPushed(app, event)
            mainwindow;
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
                set(app.RunButton_2, 'Enable', 'on');
                app.kNDFTptchoiceKnobLabel.Text = 'N-DFT pt choice';
                app.WindowlengthLDropDown.Items = {'5'};
                set(app.InputfilenameEditField, 'Enable', 'off');
                set(app.SamplefrequencyHzSlider, 'Enable', 'on');
            else
                set(app.DemoFunctionsDropDown, 'Enable', 'off');
                set(app.BrowseButton, 'Enable', 'on');
                app.kNDFTptchoiceKnobLabel.Text = 'k N-DFT pt choice';
                app.WindowlengthLDropDown.Items = {'5000'};
                set(app.InputfilenameEditField, 'Enable', 'on');
                set(app.SamplefrequencyHzSlider, 'Enable', 'off');
                if(app.InputfilenameEditField.Value) %IF there is an input file
                    set(app.RunButton_2, 'Enable', 'on');
                else
                    set(app.RunButton_2, 'Enable', 'off');
                end
            end
        end

        % Button pushed function: RunButton_2
        function RunButton_2Pushed(app, event)
            DFT(app);
        end

        % Callback function
        function ShowallwindowtypesCheckBoxValueChanged(app, event)
            value = app.ShowallwindowtypesCheckBox.Value;
            if(value == true)
                set(app.WindowchoiceDropDown, 'Enable', 'off');
            else
                set(app.WindowchoiceDropDown, 'Enable', 'on');
            end
            
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

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            [file path]= uigetfile('*.wav');
            if(file) %if a file is chosen
                while (file(end-2:end) ~= 'wav') %while the file extension is not wav
                    [file path] = uigetfile('*.wav');  %get the user to choose a file again
                end
                app.InputfilenameEditField.Value = [path file];
                set(app.RunButton_2, 'Enable', 'on');
            end
        end

        % Value changed function: PlotDropDown_2
        function PlotDropDown_2ValueChanged(app, event)
            value = app.PlotDropDown_2.Value;
            switch value
                case 'Mag and phase'
                    title(app.UIAxes2_2, 'Phase');
                    ylabel(app.UIAxes2_2, 'Phase (deg)');
                    title(app.UIAxes2, 'Magnitude');
                    
                case 'Real and Im'
                    title(app.UIAxes2_2, 'Imaginary');
                    ylabel(app.UIAxes2_2, 'Imaginary');
                    title(app.UIAxes2, 'Real');
            end
        end

        % Value changed function: AmplitudeDropDown
        function AmplitudeDropDownValueChanged(app, event)
            value = app.AmplitudeDropDown.Value;
            switch value
                case 'Linear'
                     ylabel(app.UIAxes2, 'Amplitude (Linear)')
                case 'Logarithmic'
                     ylabel(app.UIAxes2, 'Amplitude (Logarithmic (dB))')
            end
        end

        % Value changed function: FromEditField
        function FromEditFieldValueChanged(app, event)
            max = app.ToEditField.Value;
            app.FromEditField.Limits = [0 max-1];
            %Update the to field limits
            min = app.FromEditField.Value;
            app.ToEditField.Limits = [min inf];
        end

        % Value changed function: ToEditField
        function ToEditFieldValueChanged(app, event)
            min = app.FromEditField.Value;
            app.ToEditField.Limits = [min+1 inf];
            %Update the from field limits
            max = app.ToEditField.Value;
            app.FromEditField.Limits = [0 max-1];
        end

        % Button pushed function: ExitButton_2
        function ExitButton_2Pushed(app, event)
            app.delete;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 1085 757];
            app.UIFigure.Name = 'UI Figure';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 1 1085 701];

            % Create SpectrumanalyzerTab
            app.SpectrumanalyzerTab = uitab(app.TabGroup);
            app.SpectrumanalyzerTab.Title = 'Spectrum analyzer';

            % Create SpectrumanalyzerLabel
            app.SpectrumanalyzerLabel = uilabel(app.SpectrumanalyzerTab);
            app.SpectrumanalyzerLabel.HorizontalAlignment = 'center';
            app.SpectrumanalyzerLabel.FontSize = 22;
            app.SpectrumanalyzerLabel.Position = [499 615 190 29];
            app.SpectrumanalyzerLabel.Text = 'Spectrum analyzer';

            % Create OptionsLabel
            app.OptionsLabel = uilabel(app.SpectrumanalyzerTab);
            app.OptionsLabel.Position = [846 585 47 15];
            app.OptionsLabel.Text = 'Options';

            % Create TrydemofunctionCheckBox
            app.TrydemofunctionCheckBox = uicheckbox(app.SpectrumanalyzerTab);
            app.TrydemofunctionCheckBox.ValueChangedFcn = createCallbackFcn(app, @TrydemofunctionCheckBoxValueChanged, true);
            app.TrydemofunctionCheckBox.Text = 'Try demo function';
            app.TrydemofunctionCheckBox.Position = [331 470 118 15];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.SpectrumanalyzerTab, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [211 522 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create DirectorywillopenagainiffilechosenisnotwavextensionLabel
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel = uilabel(app.SpectrumanalyzerTab);
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel.Position = [192 503 329 15];
            app.DirectorywillopenagainiffilechosenisnotwavextensionLabel.Text = 'Directory will open again if file chosen is not .wav extension.';

            % Create Label_4
            app.Label_4 = uilabel(app.SpectrumanalyzerTab);
            app.Label_4.Position = [780 580 179 15];
            app.Label_4.Text = '__________________________';

            % Create InputoptionsLabel
            app.InputoptionsLabel = uilabel(app.SpectrumanalyzerTab);
            app.InputoptionsLabel.Position = [290 585 74 15];
            app.InputoptionsLabel.Text = 'Input options';

            % Create Label_6
            app.Label_6 = uilabel(app.SpectrumanalyzerTab);
            app.Label_6.Position = [237 580 179 15];
            app.Label_6.Text = '__________________________';

            % Create Label_10
            app.Label_10 = uilabel(app.SpectrumanalyzerTab);
            app.Label_10.Position = [802 442 119 15];
            app.Label_10.Text = '_________________';

            % Create WindowchoiceDropDownLabel
            app.WindowchoiceDropDownLabel = uilabel(app.SpectrumanalyzerTab);
            app.WindowchoiceDropDownLabel.HorizontalAlignment = 'right';
            app.WindowchoiceDropDownLabel.Position = [774 509 86 15];
            app.WindowchoiceDropDownLabel.Text = 'Window choice';

            % Create WindowchoiceDropDown
            app.WindowchoiceDropDown = uidropdown(app.SpectrumanalyzerTab);
            app.WindowchoiceDropDown.Items = {'Rectangular', 'Triangular', 'Hanning', 'Hamming'};
            app.WindowchoiceDropDown.Position = [875 505 100 22];
            app.WindowchoiceDropDown.Value = 'Rectangular';

            % Create InputfilenameLabel
            app.InputfilenameLabel = uilabel(app.SpectrumanalyzerTab);
            app.InputfilenameLabel.HorizontalAlignment = 'right';
            app.InputfilenameLabel.Position = [103 529 84 15];
            app.InputfilenameLabel.Text = 'Input file name';

            % Create InputfilenameEditField
            app.InputfilenameEditField = uieditfield(app.SpectrumanalyzerTab, 'text');
            app.InputfilenameEditField.Editable = 'off';
            app.InputfilenameEditField.Position = [318 522 197 22];

            % Create DemoFunctionsDropDownLabel
            app.DemoFunctionsDropDownLabel = uilabel(app.SpectrumanalyzerTab);
            app.DemoFunctionsDropDownLabel.HorizontalAlignment = 'right';
            app.DemoFunctionsDropDownLabel.Position = [103 470 93 15];
            app.DemoFunctionsDropDownLabel.Text = 'Demo Functions';

            % Create DemoFunctionsDropDown
            app.DemoFunctionsDropDown = uidropdown(app.SpectrumanalyzerTab);
            app.DemoFunctionsDropDown.Items = {'sinc', 'sine', 'rect'};
            app.DemoFunctionsDropDown.Enable = 'off';
            app.DemoFunctionsDropDown.Position = [211 466 100 22];
            app.DemoFunctionsDropDown.Value = 'sinc';

            % Create WindowlengthLDropDownLabel
            app.WindowlengthLDropDownLabel = uilabel(app.SpectrumanalyzerTab);
            app.WindowlengthLDropDownLabel.HorizontalAlignment = 'right';
            app.WindowlengthLDropDownLabel.Position = [763 467 108 15];
            app.WindowlengthLDropDownLabel.Text = 'Window length L = ';

            % Create WindowlengthLDropDown
            app.WindowlengthLDropDown = uidropdown(app.SpectrumanalyzerTab);
            app.WindowlengthLDropDown.Items = {'5000'};
            app.WindowlengthLDropDown.Position = [875 463 100 22];
            app.WindowlengthLDropDown.Value = '5000';

            % Create ComparisonmodeButton
            app.ComparisonmodeButton = uibutton(app.SpectrumanalyzerTab, 'push');
            app.ComparisonmodeButton.ButtonPushedFcn = createCallbackFcn(app, @ComparisonmodeButtonPushed, true);
            app.ComparisonmodeButton.Position = [929 56 110 24];
            app.ComparisonmodeButton.Text = 'Comparison mode';

            % Create BackButton
            app.BackButton = uibutton(app.SpectrumanalyzerTab, 'push');
            app.BackButton.ButtonPushedFcn = createCallbackFcn(app, @BackButtonPushed, true);
            app.BackButton.Position = [815 20 96 24];
            app.BackButton.Text = 'Back';

            % Create RunButton_2
            app.RunButton_2 = uibutton(app.SpectrumanalyzerTab, 'push');
            app.RunButton_2.ButtonPushedFcn = createCallbackFcn(app, @RunButton_2Pushed, true);
            app.RunButton_2.Enable = 'off';
            app.RunButton_2.Position = [816 56 96 24];
            app.RunButton_2.Text = 'Run';

            % Create UIAxes
            app.UIAxes = uiaxes(app.SpectrumanalyzerTab);
            title(app.UIAxes, 'Time domain')
            xlabel(app.UIAxes, 'time n')
            ylabel(app.UIAxes, 'Amplitude')
            app.UIAxes.Position = [177 219 300 185];

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.SpectrumanalyzerTab);
            title(app.UIAxes2, 'Magnitude')
            xlabel(app.UIAxes2, 'frequency Hz')
            ylabel(app.UIAxes2, 'Amplitude')
            app.UIAxes2.Position = [30 31 300 185];

            % Create UIAxes2_2
            app.UIAxes2_2 = uiaxes(app.SpectrumanalyzerTab);
            title(app.UIAxes2_2, 'Phase')
            xlabel(app.UIAxes2_2, 'frequency Hz')
            ylabel(app.UIAxes2_2, 'Phase (deg)')
            app.UIAxes2_2.Position = [331 31 300 185];

            % Create Label_5
            app.Label_5 = uilabel(app.SpectrumanalyzerTab);
            app.Label_5.Position = [661 133 25 448];
            app.Label_5.Text = {'.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; '.'; ''};

            % Create PlotsLabel
            app.PlotsLabel = uilabel(app.SpectrumanalyzerTab);
            app.PlotsLabel.Position = [311 426 32 15];
            app.PlotsLabel.Text = 'Plots';

            % Create Label_7
            app.Label_7 = uilabel(app.SpectrumanalyzerTab);
            app.Label_7.Position = [237 420 179 15];
            app.Label_7.Text = '__________________________';

            % Create FrequencybandLabel
            app.FrequencybandLabel = uilabel(app.SpectrumanalyzerTab);
            app.FrequencybandLabel.Position = [816 355 92 15];
            app.FrequencybandLabel.Text = 'Frequency band';

            % Create Label_8
            app.Label_8 = uilabel(app.SpectrumanalyzerTab);
            app.Label_8.Position = [802 311 119 15];
            app.Label_8.Text = '_________________';

            % Create Label_9
            app.Label_9 = uilabel(app.SpectrumanalyzerTab);
            app.Label_9.Position = [802 382 119 15];
            app.Label_9.Text = '_________________';

            % Create HzLabel
            app.HzLabel = uilabel(app.SpectrumanalyzerTab);
            app.HzLabel.Position = [830 325 25 15];
            app.HzLabel.Text = 'Hz';

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.SpectrumanalyzerTab);
            app.HzLabel_2.Position = [958 325 25 15];
            app.HzLabel_2.Text = 'Hz';

            % Create ExitButton_2
            app.ExitButton_2 = uibutton(app.SpectrumanalyzerTab, 'push');
            app.ExitButton_2.ButtonPushedFcn = createCallbackFcn(app, @ExitButton_2Pushed, true);
            app.ExitButton_2.Position = [936 20 96 24];
            app.ExitButton_2.Text = 'Exit';

            % Create PlotDropDown_2Label
            app.PlotDropDown_2Label = uilabel(app.SpectrumanalyzerTab);
            app.PlotDropDown_2Label.HorizontalAlignment = 'right';
            app.PlotDropDown_2Label.Position = [834 249 26 15];
            app.PlotDropDown_2Label.Text = 'Plot';

            % Create PlotDropDown_2
            app.PlotDropDown_2 = uidropdown(app.SpectrumanalyzerTab);
            app.PlotDropDown_2.Items = {'Mag and phase', 'Real and Im'};
            app.PlotDropDown_2.ValueChangedFcn = createCallbackFcn(app, @PlotDropDown_2ValueChanged, true);
            app.PlotDropDown_2.Position = [875 245 100 22];
            app.PlotDropDown_2.Value = 'Mag and phase';

            % Create kNDFTptchoiceKnobLabel
            app.kNDFTptchoiceKnobLabel = uilabel(app.SpectrumanalyzerTab);
            app.kNDFTptchoiceKnobLabel.HorizontalAlignment = 'center';
            app.kNDFTptchoiceKnobLabel.Position = [792 109 102 15];
            app.kNDFTptchoiceKnobLabel.Text = 'k N-DFT pt choice';

            % Create kNDFTptchoiceKnob
            app.kNDFTptchoiceKnob = uiknob(app.SpectrumanalyzerTab, 'discrete');
            app.kNDFTptchoiceKnob.Items = {'8', '16', '32', '64'};
            app.kNDFTptchoiceKnob.ValueChangedFcn = createCallbackFcn(app, @kNDFTptchoiceKnobValueChanged, true);
            app.kNDFTptchoiceKnob.Position = [844 139 60 60];
            app.kNDFTptchoiceKnob.Value = '8';

            % Create SamplefrequencyHzLabel
            app.SamplefrequencyHzLabel = uilabel(app.SpectrumanalyzerTab);
            app.SamplefrequencyHzLabel.HorizontalAlignment = 'right';
            app.SamplefrequencyHzLabel.Position = [733 403 76 28];
            app.SamplefrequencyHzLabel.Text = {'Sample '; 'frequency Hz'};

            % Create SamplefrequencyHzSlider
            app.SamplefrequencyHzSlider = uislider(app.SpectrumanalyzerTab);
            app.SamplefrequencyHzSlider.Limits = [1 10];
            app.SamplefrequencyHzSlider.Enable = 'off';
            app.SamplefrequencyHzSlider.Position = [830 426 137 3];
            app.SamplefrequencyHzSlider.Value = 10;

            % Create RBWEditFieldLabel
            app.RBWEditFieldLabel = uilabel(app.SpectrumanalyzerTab);
            app.RBWEditFieldLabel.HorizontalAlignment = 'right';
            app.RBWEditFieldLabel.Position = [583 254 33 15];
            app.RBWEditFieldLabel.Text = 'RBW';

            % Create RBWEditField
            app.RBWEditField = uieditfield(app.SpectrumanalyzerTab, 'numeric');
            app.RBWEditField.Editable = 'off';
            app.RBWEditField.Position = [559 229 58 22];

            % Create AmplitudeDropDownLabel
            app.AmplitudeDropDownLabel = uilabel(app.SpectrumanalyzerTab);
            app.AmplitudeDropDownLabel.HorizontalAlignment = 'right';
            app.AmplitudeDropDownLabel.Position = [801 285 59 15];
            app.AmplitudeDropDownLabel.Text = 'Amplitude';

            % Create AmplitudeDropDown
            app.AmplitudeDropDown = uidropdown(app.SpectrumanalyzerTab);
            app.AmplitudeDropDown.Items = {'Linear', 'Logarithmic'};
            app.AmplitudeDropDown.ValueChangedFcn = createCallbackFcn(app, @AmplitudeDropDownValueChanged, true);
            app.AmplitudeDropDown.Position = [875 281 100 22];
            app.AmplitudeDropDown.Value = 'Linear';

            % Create FromEditFieldLabel
            app.FromEditFieldLabel = uilabel(app.SpectrumanalyzerTab);
            app.FromEditFieldLabel.HorizontalAlignment = 'right';
            app.FromEditFieldLabel.Position = [737 325 33 15];
            app.FromEditFieldLabel.Text = 'From';

            % Create FromEditField
            app.FromEditField = uieditfield(app.SpectrumanalyzerTab, 'numeric');
            app.FromEditField.Limits = [0 Inf];
            app.FromEditField.ValueChangedFcn = createCallbackFcn(app, @FromEditFieldValueChanged, true);
            app.FromEditField.Position = [782 321 35 22];

            % Create ToEditFieldLabel
            app.ToEditFieldLabel = uilabel(app.SpectrumanalyzerTab);
            app.ToEditFieldLabel.HorizontalAlignment = 'right';
            app.ToEditFieldLabel.Position = [870 325 25 15];
            app.ToEditFieldLabel.Text = 'To';

            % Create ToEditField
            app.ToEditField = uieditfield(app.SpectrumanalyzerTab, 'numeric');
            app.ToEditField.Limits = [2 Inf];
            app.ToEditField.ValueChangedFcn = createCallbackFcn(app, @ToEditFieldValueChanged, true);
            app.ToEditField.Position = [910 321 37 22];
            app.ToEditField.Value = 2;

            % Create CalculationsTab
            app.CalculationsTab = uitab(app.TabGroup);
            app.CalculationsTab.Title = 'Calculations';

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.CalculationsTab);
            title(app.UIAxes4, 'RMS averaging')
            xlabel(app.UIAxes4, 'Frequency Hz')
            ylabel(app.UIAxes4, 'Amplitude ')
            app.UIAxes4.Position = [101 208 424 262];

            % Create CalculationsmodeLabel
            app.CalculationsmodeLabel = uilabel(app.CalculationsTab);
            app.CalculationsmodeLabel.FontSize = 22;
            app.CalculationsmodeLabel.Position = [486 563 186 29];
            app.CalculationsmodeLabel.Text = 'Calculations mode';

            % Create Switch
            app.Switch = uiswitch(app.CalculationsTab, 'slider');
            app.Switch.Items = {'No DC Bias', 'DC Bias'};
            app.Switch.Enable = 'off';
            app.Switch.Position = [781 408 45 20];
            app.Switch.Value = 'No DC Bias';

            % Create PowerwithinspanLabel
            app.PowerwithinspanLabel = uilabel(app.CalculationsTab);
            app.PowerwithinspanLabel.HorizontalAlignment = 'right';
            app.PowerwithinspanLabel.Position = [664 308 108 15];
            app.PowerwithinspanLabel.Text = 'Power within span*';

            % Create PowerwithinspanEditField
            app.PowerwithinspanEditField = uieditfield(app.CalculationsTab, 'numeric');
            app.PowerwithinspanEditField.Editable = 'off';
            app.PowerwithinspanEditField.Position = [787 304 100 22];

            % Create PeakpointonspectrumEditFieldLabel
            app.PeakpointonspectrumEditFieldLabel = uilabel(app.CalculationsTab);
            app.PeakpointonspectrumEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakpointonspectrumEditFieldLabel.Position = [640 343 132 15];
            app.PeakpointonspectrumEditFieldLabel.Text = 'Peak point on spectrum';

            % Create PeakpointonspectrumEditField
            app.PeakpointonspectrumEditField = uieditfield(app.CalculationsTab, 'numeric');
            app.PeakpointonspectrumEditField.Editable = 'off';
            app.PeakpointonspectrumEditField.Position = [787 339 100 22];

            % Create AvailableforinputfileoptiononlyLabel
            app.AvailableforinputfileoptiononlyLabel = uilabel(app.CalculationsTab);
            app.AvailableforinputfileoptiononlyLabel.Position = [702 274 185 15];
            app.AvailableforinputfileoptiononlyLabel.Text = '*Available for input file option only';
        end
    end

    methods (Access = public)

        % Construct app
        function app = spectrumanalyzer

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