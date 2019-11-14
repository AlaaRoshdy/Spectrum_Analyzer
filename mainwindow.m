classdef mainwindow < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        DigitalSignalProcessingLabel  matlab.ui.control.Label
        DiscreteconvolutionButton     matlab.ui.control.Button
        SpectrumanalyzerButton        matlab.ui.control.Button
        ExitButton                    matlab.ui.control.Button
        FIRfilterButton               matlab.ui.control.Button
    end

    methods (Access = private)

        % Button pushed function: DiscreteconvolutionButton
        function DiscreteConv(app, event)
            discreteconv;
            closereq;
        end

        % Button pushed function: ExitButton
        function ExitButtonPushed(app, event)
            app.delete;
        end

        % Button pushed function: SpectrumanalyzerButton
        function SpectrumanalyzerButtonPushed(app, event)
            spectrumanalyzer;
            closereq;
        end

        % Button pushed function: FIRfilterButton
        function FIRfilterButtonPushed(app, event)
            FIRfilter;
            closereq;
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 419 195];
            app.UIFigure.Name = 'UI Figure';

            % Create DigitalSignalProcessingLabel
            app.DigitalSignalProcessingLabel = uilabel(app.UIFigure);
            app.DigitalSignalProcessingLabel.HorizontalAlignment = 'center';
            app.DigitalSignalProcessingLabel.FontSize = 22;
            app.DigitalSignalProcessingLabel.Position = [86 139 251 29];
            app.DigitalSignalProcessingLabel.Text = 'Digital Signal Processing';

            % Create DiscreteconvolutionButton
            app.DiscreteconvolutionButton = uibutton(app.UIFigure, 'push');
            app.DiscreteconvolutionButton.ButtonPushedFcn = createCallbackFcn(app, @DiscreteConv, true);
            app.DiscreteconvolutionButton.Position = [48 76 124 22];
            app.DiscreteconvolutionButton.Text = 'Discrete convolution';

            % Create SpectrumanalyzerButton
            app.SpectrumanalyzerButton = uibutton(app.UIFigure, 'push');
            app.SpectrumanalyzerButton.ButtonPushedFcn = createCallbackFcn(app, @SpectrumanalyzerButtonPushed, true);
            app.SpectrumanalyzerButton.Position = [254 76 116 22];
            app.SpectrumanalyzerButton.Text = 'Spectrum analyzer';

            % Create ExitButton
            app.ExitButton = uibutton(app.UIFigure, 'push');
            app.ExitButton.ButtonPushedFcn = createCallbackFcn(app, @ExitButtonPushed, true);
            app.ExitButton.Position = [161 31 100 22];
            app.ExitButton.Text = 'Exit';

            % Create FIRfilterButton
            app.FIRfilterButton = uibutton(app.UIFigure, 'push');
            app.FIRfilterButton.ButtonPushedFcn = createCallbackFcn(app, @FIRfilterButtonPushed, true);
            app.FIRfilterButton.Position = [161 108 100 22];
            app.FIRfilterButton.Text = 'FIR filter';
        end
    end

    methods (Access = public)

        % Construct app
        function app = mainwindow

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