classdef MBTIApp < matlab.apps.AppBase
    % MBTIApp - Engineering MBTI quiz programmatic App Designer app
    % New Commit - 20260303

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
        theme = 'light'; % 'light' or 'dark'
        % 현재 결과 데이터 (이미지 내보내기용)
        currentMbti   = '';
        currentName   = '';
        currentNameEn = '';
        currentBase   = '';
        currentTool   = '';
        currentBest   = '';
        currentWorst  = '';
    end

    properties (Dependent, Access = private)
        bgColor
        txtColor
    end

    properties (Constant, Access = private)
        lightColors = struct('bg', '#F8F9FA', 'txt', '#212529'); % Light Mode
        darkColors = struct('bg', '#212529', 'txt', '#F8F9FA');  % Dark Mode

        btnColorKo = '#007BFF';    % Standard Blue
        btnColorEn = '#E83E8C';    % Standard Pink
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
        function delete(app)
            delete(app.UIFigure);
        end

        function buildUI(app)
            app.UIFigure = uifigure('Visible','off','Color',app.bgColor);
            app.UIFigure.Name = 'Engineering MBTI';
            app.UIFigure.CloseRequestFcn = @(src, event)delete(app);
            app.UIFigure.Position = [100 100 450*1.2 800*1.2];

            app.MainLayout = uigridlayout(app.UIFigure,[1 1]);
            app.MainLayout.Scrollable = 'on';

            % Start Panel
            app.StartPanel = uipanel(app.MainLayout,'Title','', 'BackgroundColor',app.bgColor, 'TitlePosition', 'centertop');
            app.StartPanel.Layout.Row = 1;     % <--- 이 줄 추가
            app.StartPanel.Layout.Column = 1;  % <--- 이 줄 추가
            app.StartPanel.Scrollable = 'on';
            grid = uigridlayout(app.StartPanel,[5 1]);
            grid.RowHeight = {'1x','fit','fit','1x','fit'};
            grid.Padding = [20 20 20 20];
            grid.RowSpacing = 24;
            
            lbl = uilabel(grid,'Text','Engineering MBTI','HorizontalAlignment','center',...
                'FontSize',32,'FontWeight','bold','FontColor',app.txtColor, 'Tag', 'ThemeableLabel');
            lbl.Layout.Row = 2;
            
            % language buttons
            hbox = uigridlayout(grid,[1 2]);
            hbox.RowHeight = {96};  % 버튼 높이 확보
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
            
            % Footer with theme toggle
            footerGrid = uigridlayout(grid, [1,2]);
            footerGrid.Layout.Row = 5;
            footerGrid.ColumnWidth = {'1x', 'fit'};
            footer = uilabel(footerGrid,'Text','Design by MATLAB App Designer','HorizontalAlignment','center',...
                'FontColor',app.txtColor,'FontSize',14, 'Tag', 'ThemeableLabel');
            footer.Layout.Column = 1;
            themeBtn = uibutton(footerGrid, 'Text', '🌙', 'FontSize', 20, ...
                'ButtonPushedFcn', @app.toggleTheme);
            themeBtn.Layout.Column = 2;
            
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
                % UIFigure가 유효한지 확인 (Null Pointer/삭제된 객체 접근 방지)
                if isempty(app.UIFigure) || ~isvalid(app.UIFigure)
                    app.buildUI();
                end

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
            grid.RowHeight = {'fit','fit','1x',100,'fit',140};
            grid.Padding = [20 20 20 20];
            grid.RowSpacing = 16;
            % progress label
            lblProg = uilabel(grid,'Text',sprintf('Question %d / %d',app.questionIndex,numel(app.questions)),...
                'HorizontalAlignment','center','FontSize',20,'FontColor',app.txtColor, 'Tag', 'ThemeableLabel');
            lblProg.Layout.Row = 1;
            % question text
            qtext = q.(app.lang);
            lblQ = uilabel(grid,'Text',qtext,'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',24,'FontWeight','bold', 'Tag', 'ThemeableLabel');
            lblQ.Layout.Row = 2;
            
            % Image Area (Questions related image)
            img = uiimage(grid);
            img.Layout.Row = 3;
            img.HorizontalAlignment = 'center';
            imgFile = fullfile('images', 'questions', sprintf('Q%d.png', app.questionIndex));
            imgPath = app.getImageWithFallback(imgFile);
            if ~isempty(imgPath)
                img.ImageSource = imgPath;
            else
                img.AltText = ''; % 이미지가 없으면 빈 공간으로 둠
            end
            
            % choices
            hbox = uigridlayout(grid,[1 2]);
            hbox.Layout.Row = 4;
            hbox.ColumnSpacing = 20;
            btnA = uibutton(hbox,'push','Text',q.A{app.langIdx()},'BackgroundColor',app.txtColorA,'FontColor','white',...
                'FontSize',14,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.recordAnswer('A')));
            btnB = uibutton(hbox,'push','Text',q.B{app.langIdx()},'BackgroundColor',app.txtColorB,'FontColor',app.txtColor,...
                'FontSize',14,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.recordAnswer('B')), 'Tag', 'ThemeableButtonFont');
            
            % Bottom buttons: Back | Skip | Exit
            hboxBottom = uigridlayout(grid,[1 3]);
            hboxBottom.Layout.Row = 5;
            hboxBottom.ColumnSpacing = 10;
            
            if strcmp(app.lang,'ko')
                txtBack = '이전'; txtSkip = '건너뛰기'; txtExit = '종료';
            else
                txtBack = 'Back'; txtSkip = 'Skip'; txtExit = 'Exit';
            end
            
            btnBack = uibutton(hboxBottom,'push','Text',txtBack,'BackgroundColor','#495057','FontColor','white',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.previousQuestion()));
            if app.questionIndex == 1, btnBack.Enable = 'off'; end
            
            btnSkip = uibutton(hboxBottom,'push','Text',txtSkip,'BackgroundColor','#17A2B8','FontColor','white',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.skipQuestion()));

            btnExit = uibutton(hboxBottom,'push','Text',txtExit,...
                'BackgroundColor',app.btnColorExit,'FontColor','white',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()delete(app)));

            % Row 6: 현재까지의 답변 분포 차트 (질문마다 실시간 업데이트)
            app.buildDimChart(grid, 6);
        end

        function recordAnswer(app,choice)
            try
                app.answers(end+1) = choice;
            catch ex
                warning('Failed to record answer: %s', ex.message);
            end
            app.showQuestion();
        end

        function previousQuestion(app)
            if app.questionIndex > 1
                % Remove last answer
                app.answers(end) = [];
                % Decrement index by 2 because showQuestion increments by 1
                app.questionIndex = app.questionIndex - 2;
                app.showQuestion();
            end
        end

        function skipQuestion(app)
            app.recordAnswer('X');
        end

        function showResult(app)
            if numel(app.answers) < numel(app.questions)
                return;
            end

            % Check if there are enough valid answers (at least one per dimension)
            % Dimensions: T/F [1,5,9], J/P [2,6,10], E/I [3,7,11], N/S [4,8,12]
            dimIndices = {[1,5,9], [2,6,10], [3,7,11], [4,8,12]};
            insufficient = false;
            for i = 1:numel(dimIndices)
                if all(app.answers(dimIndices{i}) == 'X')
                    insufficient = true;
                    break;
                end
            end
            
            if insufficient
                msg = '결과 계산에 필요한 답변이 부족합니다. 처음부터 다시 시작합니다.';
                title = '결과 보류';
                if strcmp(app.lang,'en')
                    msg = 'Insufficient answers to calculate result. Restarting...';
                    title = 'Result Withheld';
                end
                uialert(app.UIFigure, msg, title, 'Icon','warning', ...
                    'CloseFcn',@(s,e)app.safeInvoke(@()app.start(app.lang)));
                return;
            end

            delete(app.QuestionPanel.Children);
            app.QuestionPanel.Visible = 'off';
            delete(app.ResultPanel.Children);
            app.ResultPanel.Visible = 'on';

            % Calculate 4 Axes
            nAns = numel(app.answers);
            
            % Helper to calculate type ignoring 'X' (Skip)
            function res = calcType(indices)
                validIdx = indices(indices <= nAns);
                validAns = app.answers(validIdx);
                validAns = validAns(validAns ~= 'X'); % Filter skips
                cntA = sum(validAns == 'A');
                res = false; % Default to 'B' side
                if ~isempty(validAns) && cntA >= numel(validAns)/2
                    res = true; % 'A' side
                end
            end

            letterT_F = 'F'; if calcType([1,5,9]), letterT_F = 'T'; end
            letterJ_P = 'J'; if calcType([2,6,10]), letterJ_P = 'P'; end
            letterE_I = 'I'; if calcType([3,7,11]), letterE_I = 'E'; end
            letterN_S = 'S'; if calcType([4,8,12]), letterN_S = 'N'; end
            
            % MBTI 조합 생성 (E/I, N/S, T/F, J/P 순서)
            mbtiStr = [letterE_I, letterN_S, letterT_F, letterJ_P];
            
            % Map to 16 Types
            switch mbtiStr
                case 'ENTP', name='머신러닝/딥러닝 어플리케이션 개발'; nameEn='ML/DL App Developer';                  base='MATLAB';          tool='Deep Learning Toolbox';            best='INFJ'; worst='ISFJ';
                case 'ESTP', name='시스템 엔지니어링 (아키텍처 설계)';  nameEn='Systems Engineering (Architecture)'; base='MATLAB';          tool='System Composer';                  best='ISFJ'; worst='INFP';
                case 'INTP', name='데이터 분석';                         nameEn='Data Analyst';                       base='MATLAB';          tool='Statistics & Machine Learning Toolbox'; best='ENTJ'; worst='ESFJ';
                case 'ISTP', name='순수한 매트랩 프로그래머';            nameEn='Pure MATLAB Programmer';             base='MATLAB';          tool='MATLAB Coder';                     best='ESFJ'; worst='ENFP';
                case 'ENTJ', name='자율 주행/ADAS 어플리케이션 개발';   nameEn='Autonomous Driving / ADAS Developer'; base='MATLAB';         tool='Automated Driving Toolbox';        best='INTP'; worst='ISFP';
                case 'ESTJ', name='소프트웨어 엔지니어링 (검증 작업)';  nameEn='Software Engineering (Verification)'; base='MATLAB/Simulink'; tool='Simulink Test & Check';            best='ISTP'; worst='INFP';
                case 'INTJ', name='주파수 등 신호처리 및 분석';          nameEn='Signal Processing & Analysis';        base='MATLAB';          tool='Signal Processing Toolbox';        best='ENFP'; worst='ESFP';
                case 'ISTJ', name='제어 알고리즘 개발자 (매트랩 프로그래밍)'; nameEn='Control Algorithm Developer (MATLAB)'; base='MATLAB';   tool='Control System Toolbox';           best='ESFP'; worst='ENFJ';
                case 'ENFP', name='ROS, DDS, Adaptive AUTOSAR 플랫폼 적용'; nameEn='ROS / DDS / AUTOSAR Platform';   base='Simulink';        tool='ROS Toolbox / AUTOSAR Blockset';   best='INTJ'; worst='ISTJ';
                case 'ESFP', name='ASPICE, 기능 안전 고려한 소프트웨어 개발'; nameEn='ASPICE & Functional Safety';    base='Simulink';        tool='Requirements Toolbox';             best='ISTJ'; worst='INTJ';
                case 'INFP', name='자동 코드 생성';                      nameEn='Auto Code Generation';               base='Simulink';        tool='Embedded Coder';                   best='ENFJ'; worst='ESTJ';
                case 'ISFP', name='매트랩/시뮬링크 초보자';              nameEn='MATLAB / Simulink Beginner';          base='Simulink';        tool='Simulink Onramp';                  best='ESFJ'; worst='ENTJ';
                case 'ENFJ', name='로봇 등 메카닉 구현';                 nameEn='Robotics & Mechanical Implementation'; base='Simulink';      tool='Robotics System Toolbox';          best='INFP'; worst='ISTJ';
                case 'ESFJ', name='플랜트 모델링 및 시뮬레이션';        nameEn='Plant Modeling & Simulation';         base='Simulink';        tool='Simscape';                         best='ISFP'; worst='INTP';
                case 'INFJ', name='제어 알고리즘 개발자 (시뮬링크 모델 이용)'; nameEn='Control Algorithm Developer (Simulink)'; base='Simulink'; tool='Simulink Control Design';     best='ENTP'; worst='ESTP';
                case 'ISFJ', name='모터 제어 등 전동화';                 nameEn='Motor Control & Electrification';     base='Simulink';        tool='Motor Control Blockset';           best='ESTP'; worst='ENTP';
                otherwise,   name='Unknown'; nameEn='Unknown'; base='N/A'; tool='N/A'; best='-'; worst='-';
            end

            % 현재 결과 데이터 저장 (이미지 내보내기용)
            app.currentMbti    = mbtiStr;
            app.currentName    = name;
            app.currentNameEn  = nameEn;
            app.currentBase    = base;
            app.currentTool    = tool;
            app.currentBest    = best;
            app.currentWorst   = worst;

            % Build result UI
            grid = uigridlayout(app.ResultPanel,[9 1]);
            grid.RowHeight = {'fit', 180, 'fit', 'fit', 'fit', 160, 'fit', 'fit', '1x'};
            grid.Padding = [20 20 20 20];
            grid.RowSpacing = 16;

            % Row 1: MBTI 텍스트 출력
            lblTitle = uilabel(grid,'Text',['당신의 엔지니어링 MBTI는: ', mbtiStr],'FontSize',28,...
                'HorizontalAlignment','center','FontColor',app.txtColor,'FontWeight','bold', 'Tag', 'ThemeableLabel');
            lblTitle.Layout.Row = 1;

            % Row 2: 메인 MBTI 이미지 (라운드 코너 16px)
            mainImg = app.createRoundedImage(grid, app.getMbtiImagePath(mbtiStr), 16);
            mainImg.Layout.Row = 2;

            % Row 3: 역할 설명
            lblDesc = uilabel(grid,'Text',name,'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',20, 'Tag', 'ThemeableLabel');
            lblDesc.Layout.Row = 3;

            % Row 4: 주 사용 환경
            lblBase = uilabel(grid,'Text',['주 사용 환경: ',base],'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',16, 'Tag', 'ThemeableLabel');
            lblBase.Layout.Row = 4;

            % Row 5: 추천 툴박스
            lblTool = uilabel(grid,'Text',['추천 툴박스: ',tool],'HorizontalAlignment','center','FontColor',app.txtColor,'FontSize',16, 'Tag', 'ThemeableLabel');
            lblTool.Layout.Row = 5;

            % Row 6: 차원 분포 차트 (I/E, N/S, T/F, J/P)
            app.buildDimChart(grid, 6);

            % Row 7: 짝꿍 이미지 섹션 (3행×2열 서브 그리드)
            pairGrid = uigridlayout(grid, [3 2]);
            pairGrid.Layout.Row = 7;
            pairGrid.RowHeight = {'fit', 130, 'fit'};
            pairGrid.ColumnWidth = {'1x', '1x'};
            pairGrid.ColumnSpacing = 20;
            pairGrid.RowSpacing = 6;
            pairGrid.Padding = [10 0 10 0];

            lblBestHdr = uilabel(pairGrid, 'Text', '환상의 짝꿍', 'HorizontalAlignment', 'center', ...
                'FontColor', '#218838', 'FontSize', 14, 'FontWeight', 'bold');
            lblBestHdr.Layout.Row = 1; lblBestHdr.Layout.Column = 1;

            lblWorstHdr = uilabel(pairGrid, 'Text', '환장의 짝꿍', 'HorizontalAlignment', 'center', ...
                'FontColor', '#DC3545', 'FontSize', 14, 'FontWeight', 'bold');
            lblWorstHdr.Layout.Row = 1; lblWorstHdr.Layout.Column = 2;

            % 짝꿍 이미지 (라운드 코너 12px)
            bestImg = app.createRoundedImage(pairGrid, app.getMbtiImagePath(best), 12);
            bestImg.Layout.Row = 2; bestImg.Layout.Column = 1;

            worstImg = app.createRoundedImage(pairGrid, app.getMbtiImagePath(worst), 12);
            worstImg.Layout.Row = 2; worstImg.Layout.Column = 2;

            lblBestType = uilabel(pairGrid, 'Text', best, 'HorizontalAlignment', 'center', ...
                'FontColor', app.txtColor, 'FontSize', 16, 'FontWeight', 'bold', 'Tag', 'ThemeableLabel');
            lblBestType.Layout.Row = 3; lblBestType.Layout.Column = 1;

            lblWorstType = uilabel(pairGrid, 'Text', worst, 'HorizontalAlignment', 'center', ...
                'FontColor', app.txtColor, 'FontSize', 16, 'FontWeight', 'bold', 'Tag', 'ThemeableLabel');
            lblWorstType.Layout.Row = 3; lblWorstType.Layout.Column = 2;

            % Row 8: 버튼
            hbox = uigridlayout(grid,[1 4]);
            hbox.Layout.Row = 8;
            hbox.ColumnSpacing = 12;
            hbox.RowHeight = {72};
            linkTxt = '제품 보기'; retryTxt = '다시 하기'; closeTxt = '종료'; saveTxt = '결과 저장';
            if strcmp(app.lang,'en')
                lblTitle.Text    = ['Your Engineering MBTI: ', mbtiStr];
                lblDesc.Text     = nameEn;
                lblBase.Text     = ['Environment: ', base];
                lblTool.Text     = ['Recommended Tool: ', tool];
                lblBestHdr.Text  = 'Best Match';
                lblWorstHdr.Text = 'Worst Match';
                linkTxt = 'Products'; retryTxt = 'Retry'; closeTxt = 'Exit'; saveTxt = 'Save Result Image';
            end

            btnLink = uibutton(hbox,'push','Text',linkTxt,'BackgroundColor',app.btnColorKo,'FontColor','white','FontSize',13,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.openLink()));
            btnRetry = uibutton(hbox,'push','Text',retryTxt,'BackgroundColor',app.btnColorEn,'FontColor','white','FontSize',13,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.start(app.lang)));
            btnClose = uibutton(hbox,'push','Text',closeTxt,'BackgroundColor',app.btnColorExit,'FontColor','white',...
                'FontSize',13,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()delete(app)));
            btnSave = uibutton(hbox,'push','Text',saveTxt,'BackgroundColor',app.btnColorKo,'FontColor','white',...
                'FontSize',13,'FontWeight','bold',...
                'ButtonPushedFcn',@(s,e)app.safeInvoke(@()app.saveResultImage()));
        end

    end
    methods (Access = private)
        function saveResultImage(app)
            % 파일명: MBTI_<유형>.png (예: MBTI_ESTJ.png)
            defaultName = ['MBTI_', app.currentMbti, '.png'];
            if strcmp(app.lang, 'ko')
                dialogTitle = '결과 이미지 저장';
                successMsg  = '결과 이미지가 성공적으로 저장되었습니다.';
                errorMsg    = '이미지 저장에 실패했습니다.';
            else
                dialogTitle = 'Save Result Image';
                successMsg  = 'Result image saved successfully.';
                errorMsg    = 'Failed to save image.';
            end

            [filename, pathname] = uiputfile('*.png', dialogTitle, defaultName);
            if isequal(filename, 0) || isequal(pathname, 0)
                return;
            end

            fullFileName = fullfile(pathname, filename);
            try
                app.buildAndExportResultImage(fullFileName);
                if isvalid(app.UIFigure)
                    uialert(app.UIFigure, successMsg, 'Success', 'Icon', 'success');
                end
            catch ex
                if isvalid(app.UIFigure)
                    uialert(app.UIFigure, [errorMsg, newline, ex.message], 'Error', 'Icon', 'error');
                else
                    warning('%s\n%s', errorMsg, ex.message);
                end
            end
        end

        function buildAndExportResultImage(app, fullFileName)
            % 버튼을 제외한 결과 내용 + MATLAB 로고를 포함한
            % 임시 figure를 생성하여 이미지로 내보냄
            figPos = app.UIFigure.Position;
            tmpFig = uifigure('Visible', 'on', 'Color', app.bgColor, ...
                'Position', [figPos(1)+figPos(3)+10, figPos(2), figPos(3), figPos(4)], ...
                'Name', 'Exporting...');
            try
                % 언어에 따른 표시 텍스트 결정
                if strcmp(app.lang, 'ko')
                    titleTxt    = ['당신의 엔지니어링 MBTI는: ', app.currentMbti];
                    descTxt     = app.currentName;
                    baseTxt     = ['주 사용 환경: ', app.currentBase];
                    toolTxt     = ['추천 툴박스: ', app.currentTool];
                    bestHdrTxt  = '환상의 짝꿍';
                    worstHdrTxt = '환장의 짝꿍';
                    logoLblTxt  = 'Engineering MBTI powered by MATLAB';
                else
                    titleTxt    = ['Your Engineering MBTI: ', app.currentMbti];
                    descTxt     = app.currentNameEn;
                    baseTxt     = ['Environment: ', app.currentBase];
                    toolTxt     = ['Recommended Tool: ', app.currentTool];
                    bestHdrTxt  = 'Best Match';
                    worstHdrTxt = 'Worst Match';
                    logoLblTxt  = 'Engineering MBTI powered by MATLAB';
                end

                % 메인 그리드 (버튼 행 없음, 마지막 행에 MATLAB 로고)
                expGrid = uigridlayout(tmpFig, [9 1]);
                expGrid.RowHeight = {'fit', 200, 'fit', 'fit', 'fit', 180, 'fit', 100, 'fit'};
                expGrid.Padding   = [20 30 20 20];
                expGrid.RowSpacing = 20;

                % Row 1: 제목
                r1 = uilabel(expGrid, 'Text', titleTxt, 'FontSize', 28, ...
                    'HorizontalAlignment', 'center', 'FontColor', app.txtColor, 'FontWeight', 'bold');
                r1.Layout.Row = 1;

                % Row 2: 메인 MBTI 이미지 (라운드 코너)
                r2 = app.createRoundedImage(expGrid, app.getMbtiImagePath(app.currentMbti), 16);
                r2.Layout.Row = 2;

                % Row 3: 역할 설명
                r3 = uilabel(expGrid, 'Text', descTxt, 'HorizontalAlignment', 'center', ...
                    'FontColor', app.txtColor, 'FontSize', 20);
                r3.Layout.Row = 3;

                % Row 4: 주 사용 환경
                r4 = uilabel(expGrid, 'Text', baseTxt, 'HorizontalAlignment', 'center', ...
                    'FontColor', app.txtColor, 'FontSize', 16);
                r4.Layout.Row = 4;

                % Row 5: 추천 툴박스
                r5 = uilabel(expGrid, 'Text', toolTxt, 'HorizontalAlignment', 'center', ...
                    'FontColor', app.txtColor, 'FontSize', 16);
                r5.Layout.Row = 5;

                % Row 6: 차원 분포 차트
                app.buildDimChart(expGrid, 6);

                % Row 7: 짝꿍 이미지 섹션
                pairGrid = uigridlayout(expGrid, [3 2]);
                pairGrid.Layout.Row = 7;
                pairGrid.RowHeight  = {'fit', 130, 'fit'};
                pairGrid.ColumnWidth = {'1x', '1x'};
                pairGrid.ColumnSpacing = 20;
                pairGrid.RowSpacing = 6;
                pairGrid.Padding = [10 0 10 0];

                lbh = uilabel(pairGrid, 'Text', bestHdrTxt, 'HorizontalAlignment', 'center', ...
                    'FontColor', '#218838', 'FontSize', 14, 'FontWeight', 'bold');
                lbh.Layout.Row = 1; lbh.Layout.Column = 1;
                lwh = uilabel(pairGrid, 'Text', worstHdrTxt, 'HorizontalAlignment', 'center', ...
                    'FontColor', '#DC3545', 'FontSize', 14, 'FontWeight', 'bold');
                lwh.Layout.Row = 1; lwh.Layout.Column = 2;

                bi = app.createRoundedImage(pairGrid, app.getMbtiImagePath(app.currentBest), 12);
                bi.Layout.Row = 2; bi.Layout.Column = 1;
                wi = app.createRoundedImage(pairGrid, app.getMbtiImagePath(app.currentWorst), 12);
                wi.Layout.Row = 2; wi.Layout.Column = 2;

                lbt = uilabel(pairGrid, 'Text', app.currentBest, 'HorizontalAlignment', 'center', ...
                    'FontColor', app.txtColor, 'FontSize', 16, 'FontWeight', 'bold');
                lbt.Layout.Row = 3; lbt.Layout.Column = 1;
                lwt = uilabel(pairGrid, 'Text', app.currentWorst, 'HorizontalAlignment', 'center', ...
                    'FontColor', app.txtColor, 'FontSize', 16, 'FontWeight', 'bold');
                lwt.Layout.Row = 3; lwt.Layout.Column = 2;

                % Row 8: MATLAB 로고 (우측 하단 정렬, 2배 크기)
                % 3열 구조: [spacer 1x] | [텍스트 fit] | [로고 80px]
                logoGrid = uigridlayout(expGrid, [1 3]);
                logoGrid.Layout.Row    = 8;
                logoGrid.ColumnWidth   = {'1x', 'fit', 80};
                logoGrid.ColumnSpacing = 8;
                logoGrid.Padding       = [10 4 10 4];

                logoLbl = uilabel(logoGrid, 'Text', logoLblTxt, ...
                    'FontSize', 22, 'FontColor', [0.5 0.5 0.5], 'HorizontalAlignment', 'right');
                logoLbl.Layout.Column = 2;

                matlabLogoPath = fullfile('images', 'matlab_logo.png');
                if ~exist(matlabLogoPath, 'file')
                    matlabLogoPath = fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'matlabicon.gif');
                end
                if exist(matlabLogoPath, 'file')
                    logoImg = uiimage(logoGrid);
                    logoImg.ImageSource = matlabLogoPath;
                    logoImg.Layout.Column = 3;
                end

                % uihtml 렌더링 대기 후 내보내기
                drawnow;
                pause(0.5);
                exportapp(tmpFig, fullFileName);
            catch ex
                delete(tmpFig);
                rethrow(ex);
            end
            delete(tmpFig);
        end
    end

    methods
        function val = get.bgColor(app)
            if strcmp(app.theme, 'light')
                val = app.lightColors.bg;
            else
                val = app.darkColors.bg;
            end
        end

        function val = get.txtColor(app)
            if strcmp(app.theme, 'light')
                val = app.lightColors.txt;
            else
                val = app.darkColors.txt;
            end
        end
    end

    methods (Access = private)
        function toggleTheme(app, src, ~)
            if strcmp(app.theme, 'light')
                app.theme = 'dark';
                src.Text = '☀️'; % Sun icon for switching to light
            else
                app.theme = 'light';
                src.Text = '🌙'; % Moon icon for switching to dark
            end
            app.updateUITheme();
        end

        function updateUITheme(app)
            % Update backgrounds
            app.UIFigure.Color = app.bgColor;
            app.StartPanel.BackgroundColor = app.bgColor;
            app.QuestionPanel.BackgroundColor = app.bgColor;
            app.ResultPanel.BackgroundColor = app.bgColor;

            % Update labels
            labels = findall(app.UIFigure, 'Type', 'uilabel', 'Tag', 'ThemeableLabel');
            for i = 1:numel(labels)
                labels(i).FontColor = app.txtColor;
            end

            % Update axes (차원 분포 차트 포함)
            axList = findall(app.UIFigure, 'Type', 'uiaxes', 'Tag', 'ThemeableAxes');
            for i = 1:numel(axList)
                axList(i).BackgroundColor = app.hex2rgb(app.bgColor);
                axList(i).Color           = app.hex2rgb(app.bgColor);
                axList(i).XColor          = app.hex2rgb(app.txtColor);
                axList(i).YColor          = app.hex2rgb(app.txtColor);
                axList(i).Title.Color     = app.txtColor;
                % 차트 내 text 객체 색상 갱신
                txts = findall(axList(i), 'Type', 'text');
                for j = 1:numel(txts)
                    txts(j).Color = app.hex2rgb(app.txtColor);
                end
            end

            % Update buttons with themeable font color
            buttons = findall(app.UIFigure, 'Type', 'uibutton', 'Tag', 'ThemeableButtonFont');
            for i = 1:numel(buttons)
                buttons(i).FontColor = app.txtColor;
            end
        end

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

        function h = createRoundedImage(app, parent, imgPath, radius)
            % uihtml을 사용하여 라운드 코너 이미지 생성
            % 이미지 파일을 base64로 인코딩하여 HTML에 직접 삽입 (file:// 보안 제한 우회)
            h = uihtml(parent);
            if ~isempty(imgPath) && exist(imgPath, 'file')
                fid = fopen(imgPath, 'rb');
                data = fread(fid, '*uint8');
                fclose(fid);
                b64 = matlab.net.base64encode(data);
                [~, ~, ext] = fileparts(imgPath);
                switch lower(ext)
                    case {'.jpg', '.jpeg'}, mime = 'image/jpeg';
                    case '.gif',            mime = 'image/gif';
                    otherwise,              mime = 'image/png';
                end
                h.HTMLSource = sprintf([ ...
                    '<style>' ...
                    'html,body{margin:0;padding:0;width:100%%;height:100%%;' ...
                    'display:flex;align-items:center;justify-content:center;' ...
                    'background-color:%s;}' ...
                    'img{max-width:100%%;max-height:100%%;' ...
                    'border-radius:%dpx;object-fit:contain;}' ...
                    '</style>' ...
                    '<img src="data:%s;base64,%s">'], ...
                    app.bgColor, radius, mime, b64);
            else
                h.HTMLSource = sprintf( ...
                    '<html><body style="margin:0;background-color:%s;"></body></html>', ...
                    app.bgColor);
            end
        end

        function ax = buildDimChart(app, parent, layoutRow)
            % 각 MBTI 차원(I/E, N/S, T/F, J/P)별 질문 답변 분포를
            % 0~100% 수평 축 위의 컬러 원형 점으로 시각화하는 차트
            ax = uiaxes(parent);
            ax.Layout.Row = layoutRow;
            ax.Tag        = 'ThemeableAxes';
            hold(ax, 'on');

            % 배경 · 축 색상 (테마 적용)
            bgRgb  = app.hex2rgb(app.bgColor);
            txtRgb = app.hex2rgb(app.txtColor);
            ax.Color           = bgRgb;
            ax.BackgroundColor = bgRgb;

            % ──────────────────────────────────────────────
            % 차원 설정: {질문 인덱스, 왼쪽 레이블, 오른쪽 레이블, A→오른쪽 여부}
            % 위→아래 표시 순서: I/E, N/S, T/F, J/P
            % 판정 로직:
            %   letterE_I: 'I'(기본) → A 많으면 'E'  ∴ A→E(오른쪽)
            %   letterN_S: 'S'(기본) → A 많으면 'N'  ∴ A→N(왼쪽)
            %   letterT_F: 'F'(기본) → A 많으면 'T'  ∴ A→T(왼쪽)
            %   letterJ_P: 'J'(기본) → A 많으면 'P'  ∴ A→P(오른쪽)
            % ──────────────────────────────────────────────
            dims = {
                [3, 7, 11], 'I', 'E', true;   % A → E (오른쪽)
                [4, 8, 12], 'N', 'S', false;  % A → N (왼쪽)
                [1, 5,  9], 'T', 'F', false;  % A → T (왼쪽)
                [2, 6, 10], 'J', 'P', true;   % A → P (오른쪽)
            };

            % 질문 12개 각각의 고유 색상
            qColors = [
                0.86 0.20 0.18;  % Q1  (T/F 1번째)
                0.20 0.53 0.74;  % Q2  (J/P 1번째)
                0.92 0.47 0.13;  % Q3  (E/I 1번째)
                0.55 0.18 0.78;  % Q4  (N/S 1번째)
                0.18 0.72 0.35;  % Q5  (T/F 2번째)
                0.85 0.75 0.08;  % Q6  (J/P 2번째)
                0.50 0.50 0.50;  % Q7  (E/I 2번째)
                0.10 0.62 0.62;  % Q8  (N/S 2번째)
                0.93 0.12 0.55;  % Q9  (T/F 3번째)
                0.27 0.27 0.93;  % Q10 (J/P 3번째)
                0.11 0.82 0.78;  % Q11 (E/I 3번째)
                0.93 0.58 0.18;  % Q12 (N/S 3번째)
            ];

            % 겹침 방지: 같은 방향 답변의 x 위치를 약간씩 다르게 배치
            leftXPos  = [22, 36, 13];  % 왼쪽 레이블 방향 (<50%)
            rightXPos = [78, 64, 87];  % 오른쪽 레이블 방향 (>50%)

            nDims = size(dims, 1);
            for di = 1:nDims
                y       = di;
                qIdxs   = dims{di, 1};
                leftLbl = dims{di, 2};
                rghtLbl = dims{di, 3};
                aRight  = dims{di, 4};

                % 수평 기준선
                plot(ax, [0 100], [y y], '-', ...
                    'Color', [0.65 0.65 0.65], 'LineWidth', 1.5);

                % 좌·우 레이블
                text(ax, -3, y, leftLbl, ...
                    'HorizontalAlignment', 'right', ...
                    'VerticalAlignment',   'middle', ...
                    'FontSize', 14, 'FontWeight', 'bold', 'Color', txtRgb);
                text(ax, 103, y, rghtLbl, ...
                    'HorizontalAlignment', 'left', ...
                    'VerticalAlignment',   'middle', ...
                    'FontSize', 14, 'FontWeight', 'bold', 'Color', txtRgb);

                % 질문별 답변 점 표시
                lCnt = 0; rCnt = 0;
                for qi = 1:numel(qIdxs)
                    qIdx = qIdxs(qi);
                    if qIdx > numel(app.answers), continue; end
                    ans = app.answers(qIdx);
                    if ans == 'X', continue; end

                    isRight = (ans == 'A' && aRight) || (ans == 'B' && ~aRight);
                    if isRight
                        rCnt = rCnt + 1;
                        xPos = rightXPos(min(rCnt, 3));
                    else
                        lCnt = lCnt + 1;
                        xPos = leftXPos(min(lCnt, 3));
                    end

                    scatter(ax, xPos, y, 150, qColors(qIdx, :), 'o', ...
                        'LineWidth', 2.5, 'MarkerFaceColor', 'none');
                end
            end

            % 50% 중앙 점선
            plot(ax, [50 50], [0.35 4.65], '--', ...
                'Color', [0.55 0.55 0.55], 'LineWidth', 1.2);

            % 상단 퍼센트 레이블
            text(ax,   0, 4.80, '0%',   'HorizontalAlignment', 'center', ...
                'FontSize', 10, 'Color', txtRgb);
            text(ax,  50, 4.80, '50%',  'HorizontalAlignment', 'center', ...
                'FontSize', 10, 'Color', txtRgb);
            text(ax, 100, 4.80, '100%', 'HorizontalAlignment', 'center', ...
                'FontSize', 10, 'Color', txtRgb);

            % 축 최종 설정
            ax.XLim    = [-8  108];
            ax.YLim    = [0.35 5.0];
            ax.YDir    = 'reverse';   % 위→아래: I/E, N/S, T/F, J/P
            ax.XTick   = [];
            ax.YTick   = [];
            ax.XColor  = 'none';
            ax.YColor  = 'none';
            ax.Box     = 'off';
            ax.FontSize = 11;
            hold(ax, 'off');
        end

        function imgPath = getMbtiImagePath(app, mbtiStr)
            % 1순위: images/mbti/<MBTI>.png
            imgPath = app.getImageWithFallback(fullfile('images', 'mbti', [mbtiStr, '.png']));
        end

        function imgPath = getImageWithFallback(~, primaryPath)
            % 지정 이미지가 있으면 반환, 없으면 순서대로 대체
            if exist(primaryPath, 'file')
                imgPath = primaryPath;
                return;
            end
            % 2순위: images/matlab_logo.png (사용자가 직접 추가한 로고)
            logoPath = fullfile('images', 'matlab_logo.png');
            if exist(logoPath, 'file')
                imgPath = logoPath;
                return;
            end
            % 3순위: MATLAB 설치 경로의 기본 아이콘
            builtinIcon = fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'matlabicon.gif');
            if exist(builtinIcon, 'file')
                imgPath = builtinIcon;
                return;
            end
            % 이미지 없음
            imgPath = '';
        end
    end
    methods (Access = public)
        function app = MBTIApp
            app.buildUI();
        end

        % debug helper
    end
end