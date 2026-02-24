classdef MBTIApp < matlab.apps.AppBase
    % MBTIApp - Engineering MBTI quiz programmatic App Designer app

    properties (Access = public)
        UIFigure matlab.ui.Figure
        MainLayout matlab.ui.container.GridLayout
        StartPanel matlab.ui.container.Panel
        QuestionPanel matlab.ui.container.Panel
        ResultPanel matlab.ui.container.Panel
    end

    % Data
    properties (Access = private)
        lang % 'ko' or 'en'
        questionIndex = 0;
        answers = ''; % store choices as char array
    end

    properties (Constant, Access = private)
        bgColor = '#1A1A26';
        btnColorKo = '#3399FF';
        btnColorEn = '#8033CC';
        txtColorA = '#66E666';
        txtColorB = '#FF9933';
        btnColorExit = '#666666';
        questions = { ...
            struct('ko','문제 해결 시작','en','Problem start','A',{{'코드/수식','Code/Equation'}},'B',{{'구조/흐름도','Structure/Flowchart'}}), ...
            struct('ko','희열 순간','en','Moment of joy','A',{{'데이터 패턴','Data pattern'}},'B',{{'물리 동작','Physical motion'}}), ...
            struct('ko','학습 출발점','en','Learning start','A',{{'예제 데이터','Example data'}},'B',{{'기본 원리','Basic principle'}}), ...
            struct('ko','시스템 역할','en','System role','A',{{'두뇌/정보처리','Brain/Info processing'}},'B',{{'심장/동력제어','Heart/Power control'}}), ...
            struct('ko','오류 해결','en','Error solving','A',{{'미시적 디버깅','Microscopic debugging'}},'B',{{'거시적 조율','Macroscopic tuning'}}) ...
        };
    end

    methods (Access = public)
        function buildUI(app)
            app.UIFigure = uifigure('Visible','off','Color',app.bgColor);
            app.UIFigure.Name = 'Engineering MBTI';
            app.UIFigure.Position = [100 100 900 600];

            app.MainLayout = uigridlayout(app.UIFigure,[1 3]);
            app.MainLayout.ColumnWidth = {'1x','4x','1x'};
            app.MainLayout.Scrollable = 'on';

            % Start Panel
            app.StartPanel = uipanel(app.MainLayout,'Title','', 'BackgroundColor',app.bgColor);
            app.StartPanel.Layout.Column = 2;
            app.StartPanel.Scrollable = 'on';
            grid = uigridlayout(app.StartPanel,[4 1]);
            grid.RowHeight = {'fit','fit','1x','fit'};
            grid.Padding = [24 24 24 24];
            grid.RowSpacing = 16;
            lbl = uilabel(grid,'Text','Engineering MBTI','HorizontalAlignment','center',... 
                'FontSize',32,'FontWeight','bold','FontColor','white');
            lbl.Layout.Row = 1;
            % language buttons
            hbox = uigridlayout(grid,[1 2]);
            hbox.RowHeight = {48};
            hbox.ColumnWidth = {'1x','1x'};
            hbox.ColumnSpacing = 16;
            hbox.Layout.Row = 2;
            btnKo = uibutton(hbox,'push','Text','한국어','BackgroundColor',app.btnColorKo,...
                'FontColor','white','FontSize',16,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start('ko')));
            btnEn = uibutton(hbox,'push','Text','English','BackgroundColor',app.btnColorEn,...
                'FontColor','white','FontSize',16,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start('en')));
            % filler
            spacer = uilabel(grid,'Text','');
            spacer.Layout.Row = 3;
            footer = uilabel(grid,'Text','Design by MATLAB App Designer','HorizontalAlignment','center',... 
                'FontColor','white','FontSize',12);
            footer.Layout.Row = 4;

            % Question Panel
            app.QuestionPanel = uipanel(app.MainLayout,'Visible','off','BackgroundColor',app.bgColor);
            app.QuestionPanel.Layout.Column = 2;
            app.QuestionPanel.Scrollable = 'on';
            % will populate later dynamically

            % Result Panel
            app.ResultPanel = uipanel(app.MainLayout,'Visible','off','BackgroundColor',app.bgColor);
            app.ResultPanel.Layout.Column = 2;
            app.ResultPanel.Scrollable = 'on';
            % dynamic later

            app.UIFigure.Visible = 'on';
        end

        function start(app,lang)
            try
                app.lang = lang;
                app.questionIndex = 0;
                app.answers = '';
                app.StartPanel.Visible = 'off';
                % ensure question panel is shown
                app.QuestionPanel.Visible = 'on';
                app.showQuestion();
            catch ex
                warning('Error in start: %s', ex.message);
                rethrow(ex);
            end
        end

        function showQuestion(app)
            try
                app.QuestionPanel.Visible = 'on';
                app.ResultPanel.Visible = 'off';
                app.questionIndex = app.questionIndex + 1;
                if app.questionIndex > numel(app.questions)
                    app.showResult();
                    return;
                end
                q = app.questions{app.questionIndex};
                % clear previous
                delete(app.QuestionPanel.Children);
            catch ex
                warning('Error in showQuestion: %s', ex.message);
                rethrow(ex);
            end
            grid = uigridlayout(app.QuestionPanel,[6 1]);
            grid.RowHeight = {'fit','fit','fit','1x','fit','fit'};
            % progress label with percentage
            pct = app.questionIndex / numel(app.questions) * 100;
            lblProg = uilabel(grid,'Text',sprintf('Q %d/%d  (%d%%)',app.questionIndex,numel(app.questions),round(pct)),...
                'HorizontalAlignment','center','FontSize',24,'FontColor','white');
            lblProg.Layout.Row = 1;
            % progress bar (0.0–1.0 maps to 0–100%)
            prog = uiprogressbar(grid);
            prog.Layout.Row = 2;
            prog.Value = app.questionIndex / numel(app.questions);
            % question text
            qtext = q.(app.lang);
            lblQ = uilabel(grid,'Text',qtext,'HorizontalAlignment','center','FontColor','white');
            lblQ.Layout.Row = 3;
            % image placeholder
            ax = uiaxes(grid);
            ax.Layout.Row = 4;
            % set background using RGB since UIAxes may not accept hex
            try
                ax.BackgroundColor = app.hex2rgb(app.bgColor);
            catch
                ax.BackgroundColor = 'gray';
            end
            title(ax,qtext,'Color','white');
            % choices
            hbox = uigridlayout(grid,[1 2]);
            hbox.Layout.Row = 5;
            btnA = uibutton(hbox,'push','Text',q.A{app.langIdx()},'FontColor',app.txtColorA,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.recordAnswer('A')));
            btnB = uibutton(hbox,'push','Text',q.B{app.langIdx()},'FontColor',app.txtColorB,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.recordAnswer('B')));
            % exit button
            if strcmp(app.lang,'ko')
                txtExit = '종료';
            else
                txtExit = 'Exit';
            end
            btnExit = uibutton(grid,'push','Text',txtExit,...
                'BackgroundColor',app.btnColorExit,'FontColor','white',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()delete(app.UIFigure)));
            btnExit.Layout.Row = 6;
        end

        function recordAnswer(app,choice)
            try
                app.answers(end+1) = choice;
            catch ex
                warning('Failed to record answer: %s', ex.message);
            end
            app.showQuestion();
        end

        function showResult(app)
            delete(app.QuestionPanel.Children);
            app.QuestionPanel.Visible = 'off';
            app.ResultPanel.Visible = 'on';
            % calculate
            countA = sum(app.answers=='A');
            countB = sum(app.answers=='B');
            if countA>=countB
                if app.answers(3)=='A'
                    type=1; name='INTJ'; desc='데이터 연금술사'; base='MATLAB'; tool='Deep Learning Toolbox';
                else
                    type=3; name='INTP'; desc='주파수 마에스트로'; base='MATLAB'; tool='Signal Processing Toolbox';
                end
            else
                if app.answers(2)=='B'
                    type=2; name='ISTP'; desc='메카 워리어'; base='Simulink'; tool='Simscape Multibody';
                else
                    type=4; name='ESTJ'; desc='로직 사령관'; base='Simulink'; tool='Stateflow';
                end
            end
            % build result UI
            grid = uigridlayout(app.ResultPanel,[6 1]);
            grid.RowHeight = {'fit','fit','fit','fit','fit','fit'};
            grid.Padding = [24 24 24 40];
            lblTitle = uilabel(grid,'Text',['Type ',num2str(type),' (',name,')'],'FontSize',24,...
                'HorizontalAlignment','center','FontColor','white');
            lblTitle.Layout.Row=1;
            lblDesc = uilabel(grid,'Text',desc,'HorizontalAlignment','center','FontColor','white');
            lblDesc.Layout.Row=2;
            lblBase = uilabel(grid,'Text',['Base: ',base],'HorizontalAlignment','center','FontColor','white');
            lblBase.Layout.Row=3;
            lblTool = uilabel(grid,'Text',['Toolbox: ',tool],'HorizontalAlignment','center','FontColor','white');
            lblTool.Layout.Row=4;
            lblTeam = uilabel(grid,'Text','Teamwork: ???','HorizontalAlignment','center','FontColor','white');
            lblTeam.Layout.Row=5;
            hbox = uigridlayout(grid,[1 3]);
            hbox.Layout.Row=6;
            if strcmp(app.lang,'ko')
                linkTxt = '관련 제품 보러가기';
                retryTxt = '다시 하기';
                closeTxt = '종료';
            else
                linkTxt = 'Related Products';
                retryTxt = 'Retry';
                closeTxt = 'Exit';
            end
            btnLink = uibutton(hbox,'push','Text',linkTxt,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.openLink()));
            btnRetry = uibutton(hbox,'push','Text',retryTxt,...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start(app.lang)));
            btnClose = uibutton(hbox,'push','Text',closeTxt,...
                'BackgroundColor',app.btnColorExit,'FontColor','white',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()delete(app.UIFigure)));
        end
    end

    methods (Access = private)
        function openLink(app)
            try
                web('http://www.mathworks.com');
            catch ex
                warning('Unable to open web link: %s', ex.message);
            end
        end

        function safeInvoke(app,fun)
            % execute callback and catch exceptions for debug
            try
                fun();
            catch ex
                msg = ex.message;
                % include first stack entry if available
                if ~isempty(ex.stack)
                    st = ex.stack(1);
                    msg = sprintf('%s (in %s at line %d)', msg, st.name, st.line);
                end
                warning('Callback error: %s', msg);
            end
        end

        function rgb = hex2rgb(~,hex)
            % convert '#rrggbb' or 'rrggbb' to normalized RGB
            if hex(1)=='#'
                hex = hex(2:end);
            end
            if numel(hex)==3
                hex = repelem(hex,1,2);
            end
            rgb = sscanf(hex,'%2x%2x%2x')'/255;
        end

        function idx = langIdx(app)
            % return 1 for Korean, 2 for English — used to index bilingual cell arrays
            idx = 1 + ~strcmp(app.lang,'ko');
        end
    end
    methods (Access = public)
        function app = MBTIApp
            app.buildUI();
        end

        % debug helper
    end
end