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
        bgColor = '#F8F9FA';       % Light Gray (Light Mode)
        btnColorKo = '#007BFF';    % Standard Blue
        btnColorEn = '#E83E8C';    % Standard Pink
        txtColor   = '#212529';    % Dark Gray (Text)
        txtColorA  = '#218838';    % Darker Green
        txtColorB  = '#FFC107';    % Standard Amber
        btnColorExit = '#6C757D';  % Standard Gray
        questions = { ...
            struct('ko','모델링 시작 접근법은?','en','Starting modeling?','A',{{'수식/알고리즘 작성','Write equations/algo'}},'B',{{'물리적 컴포넌트 배치','Place physical components'}}), ...
            struct('ko','프로젝트 진행 방식은?','en','Project workflow?','A',{{'유연한 애자일/프로토타이핑','Agile/Prototyping'}},'B',{{'철저한 요구사항/V-모델','Requirements/V-Model'}}), ...
            struct('ko','선호하는 개발 범위는?','en','Dev scope preference?','A',{{'전체 시스템 아키텍처','System Architecture'}},'B',{{'핵심 알고리즘 상세 구현','Core Algorithm Detail'}}), ...
            struct('ko','데이터 활용 방식은?','en','Data usage?','A',{{'AI 학습 및 패턴 인식','AI Training/Patterns'}},'B',{{'신호 처리 및 필터링','Signal Processing'}}), ...
            struct('ko','시뮬레이션의 주 목적은?','en','Simulation goal?','A',{{'논리 검증 및 최적화','Logic Verification'}},'B',{{'실제 거동/현상 재현','Physical Behavior'}}), ...
            struct('ko','코드 생성(C/C++)의 용도는?','en','Code generation use?','A',{{'빠른 기능 확인','Quick Check'}},'B',{{'양산/인증용 탑재','Production/Safety'}}), ...
            struct('ko','외부 시스템과의 연동은?','en','External interface?','A',{{'ROS/DDS 등 통신 통합','ROS/DDS Integration'}},'B',{{'단독 모듈 동작','Standalone Module'}}), ...
            struct('ko','제어기 설계 스타일은?','en','Controller design?','A',{{'강화학습/예측 제어','RL/MPC'}},'B',{{'PID/고전 제어','PID/Classical'}}), ...
            struct('ko','디버깅 할 때 주로 보는 것은?','en','Debugging focus?','A',{{'변수 값/데이터 타입','Variables/Data Types'}},'B',{{'신호 흐름/블록 연결','Signal Flow/Connections'}}), ...
            struct('ko','소프트웨어 검증 수준은?','en','Verification level?','A',{{'기능 동작 여부 확인','Functional Check'}},'B',{{'커버리지/정적 분석','Coverage/Static Analysis'}}), ...
            struct('ko','협업 시 선호하는 형태는?','en','Collaboration style?','A',{{'모델 기반 시스템 통합','Model-Based Integration'}},'B',{{'함수/라이브러리 배포','Function/Lib Delivery'}}), ...
            struct('ko','가장 흥미로운 분야는?','en','Most interesting field?','A',{{'자율주행/인지/판단','Autonomous/Perception'}},'B',{{'모터/구동/전력','Motor/Actuation/Power'}}) ...
        };
    end

    methods (Access = public)
        function buildUI(app)
            app.UIFigure = uifigure('Visible','off','Color',app.bgColor);
            app.UIFigure.Name = 'Engineering MBTI';
            app.UIFigure.Position = [100 100 900 500];

            app.MainLayout = uigridlayout(app.UIFigure,[1 1]);
            app.MainLayout.Scrollable = 'on';

            % Start Panel
            app.StartPanel = uipanel(app.MainLayout,'Title','', 'BackgroundColor',app.bgColor, 'TitlePosition', 'centertop');
            app.StartPanel.Layout.Row = 1;     % <--- 이 줄 추가
            app.StartPanel.Layout.Column = 1;  % <--- 이 줄 추가
            app.StartPanel.Scrollable = 'on';
            grid = uigridlayout(app.StartPanel,[5 1]);
            grid.RowHeight = {'1x','fit','fit','1x','fit'};
            grid.Padding = [40 40 40 40];
            grid.RowSpacing = 24;
            
            lbl = uilabel(grid,'Text','Engineering MBTI','HorizontalAlignment','center',...
                'FontSize',48,'FontWeight','bold','FontColor',app.txtColor);
            lbl.Layout.Row = 2;
            
            % language buttons
            hbox = uigridlayout(grid,[1 2]);
            hbox.RowHeight = {80};  % 버튼 높이 확보
            hbox.ColumnWidth = {'1x','1x'};
            hbox.ColumnSpacing = 24;
            hbox.Layout.Row = 3;
            
            btnKo = uibutton(hbox,'push','Text','한국어','BackgroundColor',app.btnColorKo,...
                'FontColor','white','FontSize',20,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start('ko')));
            btnEn = uibutton(hbox,'push','Text','English','BackgroundColor',app.btnColorEn,...
                'FontColor','white','FontSize',20,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start('en')));
            % filler
            spacer = uilabel(grid,'Text','');
            spacer.Layout.Row = 4;
            footer = uilabel(grid,'Text','Design by MATLAB App Designer','HorizontalAlignment','center',...
                'FontColor',app.txtColor,'FontSize',14);
            footer.Layout.Row = 5;

            % Question Panel
            app.QuestionPanel = uipanel(app.MainLayout,'Visible','off','BackgroundColor',app.bgColor, 'TitlePosition', 'centertop');
            app.QuestionPanel.Layout.Row = 1;     % <--- 이 줄 추가
            app.QuestionPanel.Layout.Column = 1;  % <--- 이 줄 추가
            app.QuestionPanel.Scrollable = 'on';
            % will populate later dynamically

            % Result Panel
            app.ResultPanel = uipanel(app.MainLayout,'Visible','off','BackgroundColor',app.bgColor, 'TitlePosition', 'centertop');
            app.ResultPanel.Layout.Row = 1;     % <--- 이 줄 추가
            app.ResultPanel.Layout.Column = 1;  % <--- 이 줄 추가
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
            grid = uigridlayout(app.QuestionPanel,[5 1]);
            grid.RowHeight = {'fit','fit','1x',100,'fit'}; % 선택지 버튼 영역 확대
            grid.Padding = [40 40 40 40];
            grid.RowSpacing = 20;
            % progress label
            lblProg = uilabel(grid,'Text',sprintf('Question %d / %d',app.questionIndex,numel(app.questions)),...
                'HorizontalAlignment','center','FontSize',20,'FontColor',app.txtColor);
            lblProg.Layout.Row = 1;
            % question text
            qtext = q.(app.lang);
            lblQ = uilabel(grid,'Text',qtext,'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',24,'FontWeight','bold');
            lblQ.Layout.Row = 2;
            % image placeholder
            ax = uiaxes(grid);
            ax.Layout.Row = 3;
            % set background using RGB since UIAxes may not accept hex
            try
                ax.BackgroundColor = app.hex2rgb(app.bgColor);
            catch
                ax.BackgroundColor = 'gray';
            end
            title(ax,qtext,'Color',app.txtColor);
            % choices
            hbox = uigridlayout(grid,[1 2]);
            hbox.Layout.Row = 4;
            hbox.ColumnSpacing = 20;
            btnA = uibutton(hbox,'push','Text',q.A{app.langIdx()},'BackgroundColor',app.txtColorA,'FontColor','white',...
                'FontSize',18,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.recordAnswer('A')));
            btnB = uibutton(hbox,'push','Text',q.B{app.langIdx()},'BackgroundColor',app.txtColorB,'FontColor',app.txtColor,...
                'FontSize',18,'FontWeight','bold',...
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
            btnExit.Layout.Row = 5;
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
            delete(app.ResultPanel.Children);
            app.ResultPanel.Visible = 'on';
            
            if numel(app.answers) < numel(app.questions)
                return;
            end

            % Calculate 4 Axes
            nAns = numel(app.answers);
            idx = [1,5,9]; idx = idx(idx<=nAns); cntM = sum(app.answers(idx) == 'A');  letterT_F = 'F'; if ~isempty(idx) && cntM >= numel(idx)/2, letterT_F = 'T'; end
            idx = [2,6,10]; idx = idx(idx<=nAns); cntD = sum(app.answers(idx) == 'A'); letterJ_P = 'J'; if ~isempty(idx) && cntD >= numel(idx)/2, letterJ_P = 'P'; end
            idx = [3,7,11]; idx = idx(idx<=nAns); cntA = sum(app.answers(idx) == 'A'); letterE_I = 'I'; if ~isempty(idx) && cntA >= numel(idx)/2, letterE_I = 'E'; end
            idx = [4,8,12]; idx = idx(idx<=nAns); cntN = sum(app.answers(idx) == 'A'); letterN_S = 'S'; if ~isempty(idx) && cntN >= numel(idx)/2, letterN_S = 'N'; end
            
            % MBTI 조합 생성 (E/I, N/S, T/F, J/P 순서)
            mbtiStr = [letterE_I, letterN_S, letterT_F, letterJ_P];
            
            % Map to 16 Types
            switch mbtiStr
                case 'ENTP', name='머신러닝/딥러닝 어플리케이션 개발'; base='MATLAB'; tool='Deep Learning Toolbox';
                case 'ESTP', name='시스템 엔지니어링 (아키텍처 설계)'; base='MATLAB'; tool='System Composer';
                case 'INTP', name='데이터 분석'; base='MATLAB'; tool='Statistics & Machine Learning Toolbox';
                case 'ISTP', name='순수한 매트랩 프로그래머'; base='MATLAB'; tool='MATLAB Coder';
                case 'ENTJ', name='자율 주행/ADAS 어플리케이션 개발'; base='MATLAB'; tool='Automated Driving Toolbox';
                case 'ESTJ', name='소프트웨어 엔지니어링 (검증 작업)'; base='MATLAB/Simulink'; tool='Simulink Test & Check';
                case 'INTJ', name='주파수 등 신호처리 및 분석'; base='MATLAB'; tool='Signal Processing Toolbox';
                case 'ISTJ', name='제어 알고리즘 개발자 (매트랩 프로그래밍)'; base='MATLAB'; tool='Control System Toolbox';
                case 'ENFP', name='ROS, DDS, Adaptive AUTOSAR 플랫폼 적용'; base='Simulink'; tool='ROS Toolbox / AUTOSAR Blockset';
                case 'ESFP', name='ASPICE, 기능 안전 고려한 소프트웨어 개발'; base='Simulink'; tool='Requirements Toolbox';
                case 'INFP', name='자동 코드 생성'; base='Simulink'; tool='Embedded Coder';
                case 'ISFP', name='매트랩/시뮬링크 초보자'; base='Simulink'; tool='Simulink Onramp';
                case 'ENFJ', name='로봇 등 메카닉 구현'; base='Simulink'; tool='Robotics System Toolbox';
                case 'ESFJ', name='플랜트 모델링 및 시뮬레이션'; base='Simulink'; tool='Simscape';
                case 'INFJ', name='제어 알고리즘 개발자 (시뮬링크 모델 이용)'; base='Simulink'; tool='Simulink Control Design';
                case 'ISFJ', name='모터 제어 등 전동화'; base='Simulink'; tool='Motor Control Blockset';
                otherwise,   name='Unknown'; base='N/A'; tool='N/A';
            end

            % Build result UI
            grid = uigridlayout(app.ResultPanel,[7 1]);
            grid.RowHeight = {'fit','fit','fit','fit','fit','fit','1x'};
            grid.Padding = [40 100 40 40];
            grid.RowSpacing = 24;
            
            % MBTI 텍스트 출력
            lblTitle = uilabel(grid,'Text',['당신의 엔지니어링 MBTI는: ', mbtiStr],'FontSize',28,...
                'HorizontalAlignment','center','FontColor',app.txtColor,'FontWeight','bold');
            lblTitle.Layout.Row=1;
            
            lblDesc = uilabel(grid,'Text',name,'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',20);
            lblDesc.Layout.Row=2;
            
            lblBase = uilabel(grid,'Text',['주 사용 환경: ',base],'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',16);
            lblBase.Layout.Row=3;
            
            lblTool = uilabel(grid,'Text',['추천 툴박스: ',tool],'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',16);
            lblTool.Layout.Row=4;
            
            lblSpace = uilabel(grid,'Text','','HorizontalAlignment','center');
            lblSpace.Layout.Row=5;
            
            hbox = uigridlayout(grid,[1 3]);
            hbox.Layout.Row=6;
            hbox.ColumnSpacing = 16;
            hbox.RowHeight = {100}; % 결과 화면 버튼 높이 확보            
            linkTxt = '제품 보기'; retryTxt = '다시 하기'; closeTxt = '종료';
            if strcmp(app.lang,'en')
                lblTitle.Text = ['Your Engineering MBTI: ', mbtiStr];
                lblBase.Text = ['Environment: ', base];
                lblTool.Text = ['Recommended Tool: ', tool];
                linkTxt = 'Products'; retryTxt = 'Retry'; closeTxt = 'Exit'; 
            end
            
            btnLink = uibutton(hbox,'push','Text',linkTxt,'BackgroundColor',app.btnColorKo,'FontColor','white','FontSize',16,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.openLink()));
            btnRetry = uibutton(hbox,'push','Text',retryTxt,'BackgroundColor',app.btnColorEn,'FontColor','white','FontSize',16,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start(app.lang)));
            btnClose = uibutton(hbox,'push','Text',closeTxt,'BackgroundColor',app.btnColorExit,'FontColor','white',...
                'FontSize',16,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()delete(app.UIFigure)));
        end

    end
    methods (Access = private)
        function openLink(app)
            try
                web('http://www.mathworks.com/products.html');
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
                hex = reshape(repelem(hex, 2), 1, []);
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