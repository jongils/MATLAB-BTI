# MBTI 엔지니어 성격 유형 퀴즈

<p align="center">
  <img src="images/qrcode.png" alt="QR Code" width="160"/>
  <br/>
  <em>QR 코드를 스캔하여 바로 접속하세요 / Scan to open the app</em>
</p>

---

## 🇰🇷 한국어 버전

### 목차
- [프로젝트 개요](#프로젝트-개요)
- [주요 기능](#주요-기능)
- [MBTI 유형 및 엔지니어링 역할](#mbti-유형-및-엔지니어링-역할)
- [동작 원리](#동작-원리)
- [시스템 요구사항](#시스템-요구사항)
- [시작하기](#시작하기)
- [프로젝트 구조](#프로젝트-구조)

---

### 프로젝트 개요

이 프로젝트는 **MATLAB App Designer**로 제작된 엔지니어 특화 **MBTI 성격 유형 퀴즈 애플리케이션**입니다. 총 12개의 공학적 관점의 질문을 통해 사용자의 MBTI 유형을 분류하고, 16가지 성격 유형 각각에 해당하는 **엔지니어링 역할**과 **MathWorks 툴박스**를 추천합니다.

---

### 주요 기능

- 🧠 **12개의 엔지니어링 특화 질문** — 모델링, 시뮬레이션, 검증, 로보틱스, 자율주행 등 다양한 분야 포함
- 🌐 **이중 언어 지원**: 한국어 / 영어
- 🌙 **라이트 / 다크 테마** 전환 기능
- 📊 **16가지 MBTI 유형**을 고유한 엔지니어링 역할 및 추천 툴박스에 매핑
- 🔁 **탐색 컨트롤**: 이전, 건너뛰기, 종료 버튼
- 🖼️ **결과 화면 시각화** — 역할 설명, 툴박스 추천, 궁합 최고/최악 유형 표시
- 💾 **결과 이미지 저장** (PNG 형식)
- 🔗 **MathWorks 제품 페이지** 바로가기 링크

---

### MBTI 유형 및 엔지니어링 역할

| MBTI | 엔지니어링 역할 | 기반 환경 | 추천 툴박스 | 궁합 좋은 유형 | 궁합 나쁜 유형 |
|------|--------------|---------|-----------|-------------|-------------|
| ENTP | ML/DL 앱 개발자 | MATLAB | Deep Learning Toolbox | INFJ | ISFJ |
| ESTP | 시스템 엔지니어링 (아키텍처) | MATLAB | System Composer | ISFJ | INFP |
| INTP | 데이터 분석가 | MATLAB | Statistics & ML Toolbox | ENTJ | ESFJ |
| ISTP | 순수 MATLAB 프로그래머 | MATLAB | MATLAB Coder | ESFJ | ENFP |
| ENTJ | 자율주행 / ADAS | MATLAB | Automated Driving Toolbox | INTP | ISFP |
| ESTJ | 소프트웨어 엔지니어링 (검증) | MATLAB / Simulink | Simulink Test & Check | ISTP | INFP |
| INTJ | 신호 처리 및 분석 | MATLAB | Signal Processing Toolbox | ENFP | ESFP |
| ISTJ | 제어 알고리즘 개발자 (MATLAB) | MATLAB | Control System Toolbox | ESFP | ENFJ |
| ENFP | ROS / DDS / AUTOSAR 플랫폼 | Simulink | ROS Toolbox / AUTOSAR Blockset | INTJ | ISTJ |
| ESFP | ASPICE & 기능 안전 | Simulink | Requirements Toolbox | ISTJ | INTJ |
| INFP | 자동 코드 생성 | Simulink | Embedded Coder | ENFJ | ESTJ |
| ISFP | MATLAB / Simulink 입문자 | Simulink | Simulink Onramp | ESFJ | ENTJ |
| ENFJ | 로보틱스 & 기구 구현 | Simulink | Robotics System Toolbox | INFP | ISTJ |
| ESFJ | 플랜트 모델링 & 시뮬레이션 | Simulink | Simscape | ISFP | INTP |
| INFJ | 제어 알고리즘 개발자 (Simulink) | Simulink | Simulink Control Design | ENTP | ESTP |
| ISFJ | 모터 제어 & 전동화 | Simulink | Motor Control Blockset | ESTP | ENTP |

---

### 동작 원리

1. MATLAB에서 앱을 **실행**하면 언어 선택 화면이 나타납니다.
2. **언어를 선택**합니다: 한국어 또는 영어.
3. **12개의 질문에 A 또는 B로 응답**합니다 (건너뛰기 가능).
4. **이전 버튼**으로 이전 질문으로 돌아갈 수 있습니다.
5. 마지막 질문 완료 후, 아래 4가지 차원을 기준으로 **MBTI 유형이 자동 계산**됩니다:
   - **T/F** (사고 / 감정): 1, 5, 9번 질문
   - **J/P** (판단 / 인식): 2, 6, 10번 질문
   - **E/I** (외향 / 내향): 3, 7, 11번 질문
   - **N/S** (직관 / 감각): 4, 8, 12번 질문
6. **결과 화면**에서 MBTI 유형, 매핑된 엔지니어링 역할, 추천 툴박스, 궁합 정보를 확인합니다.
7. 결과를 **PNG로 저장**하거나, **제품 페이지로 이동**하거나, **다시 시작**할 수 있습니다.

---

### 시스템 요구사항

- **MATLAB R2023a** 이상
- MATLAB **App Designer** (MATLAB에 기본 포함)
- *(선택사항)* 결과표에 나열된 MathWorks 툴박스 (제품 탐색용)

---

### 시작하기

```matlab
% 1. MATLAB 실행
% 2. 프로젝트 디렉토리로 이동
cd /path/to/MBTI

% 3. 앱 실행
MBTIApp
```

또는 **MATLAB App Designer**에서 `MBTIApp.m` 파일을 열고 **실행(Run)** 버튼을 클릭합니다.

---

### 프로젝트 구조

```
MBTI/
├── MBTIApp.m              # MATLAB App Designer 메인 애플리케이션
├── images/
│   ├── mbti/              # MBTI 유형별 아이콘 (ENTP.png ~ ISFJ.png) — 여기에 추가
│   ├── questions/         # 질문 삽화 이미지 (Q1.png ~ Q12.png)
│   ├── qrcode.png         # 앱 접속 QR 코드
│   └── matlab_logo.png    # (선택) MBTI 아이콘 없을 때 대체할 커스텀 로고
├── .devcontainer/
│   └── devcontainer.json  # 클라우드 개발용 Dev Container 설정
├── .vscode/
│   ├── launch.json        # VS Code 디버거 설정
│   └── settings.json      # VS Code 워크스페이스 설정
└── README.md              # 이 파일
```

> **참고:** MBTI 아이콘(`images/mbti/ENTP.png` 등) 및 질문 이미지(`images/questions/Q1.png`–`Q12.png`)는 저장소에 포함되어 있지 않습니다. MBTI 아이콘이 없으면 순서대로 대체됩니다: `images/matlab_logo.png` → MATLAB 설치 기본 아이콘.

---
# MBTI Engineering Personality Quiz
---

## 🇺🇸 English Version

### Table of Contents
- [Overview](#overview)
- [Features](#features)
- [MBTI Types & Engineering Roles](#mbti-types--engineering-roles)
- [How It Works](#how-it-works)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)

---

### Overview

This is an interactive **MBTI personality quiz application** built with **MATLAB App Designer**, tailored specifically for engineers. It presents 12 engineering-focused questions to determine the user's MBTI type and maps each of the 16 personality types to a specific **engineering role** along with recommended **MathWorks toolboxes**.

---

### Features

- 🧠 **12 engineering-specific quiz questions** covering modeling, simulation, verification, robotics, autonomous driving, and more
- 🌐 **Bilingual support**: Korean (한국어) and English
- 🌙 **Light / Dark theme** toggle
- 📊 **16 MBTI personality types** each mapped to a unique engineering role and recommended toolbox
- 🔁 **Navigation controls**: Back, Skip, and Exit buttons
- 🖼️ **Visual result display** with role description, toolbox recommendation, and best/worst compatibility
- 💾 **Export result** as a PNG image
- 🔗 **Direct link** to MathWorks product pages

---

### MBTI Types & Engineering Roles

| MBTI | Engineering Role | Base Environment | Recommended Toolbox | Best Match | Worst Match |
|------|-----------------|-----------------|---------------------|-----------|------------|
| ENTP | ML/DL App Developer | MATLAB | Deep Learning Toolbox | INFJ | ISFJ |
| ESTP | Systems Engineering (Architecture) | MATLAB | System Composer | ISFJ | INFP |
| INTP | Data Analyst | MATLAB | Statistics & ML Toolbox | ENTJ | ESFJ |
| ISTP | Pure MATLAB Programmer | MATLAB | MATLAB Coder | ESFJ | ENFP |
| ENTJ | Autonomous Driving / ADAS | MATLAB | Automated Driving Toolbox | INTP | ISFP |
| ESTJ | Software Engineering (Verification) | MATLAB / Simulink | Simulink Test & Check | ISTP | INFP |
| INTJ | Signal Processing & Analysis | MATLAB | Signal Processing Toolbox | ENFP | ESFP |
| ISTJ | Control Algorithm Developer (MATLAB) | MATLAB | Control System Toolbox | ESFP | ENFJ |
| ENFP | ROS / DDS / AUTOSAR Platform | Simulink | ROS Toolbox / AUTOSAR Blockset | INTJ | ISTJ |
| ESFP | ASPICE & Functional Safety | Simulink | Requirements Toolbox | ISTJ | INTJ |
| INFP | Auto Code Generation | Simulink | Embedded Coder | ENFJ | ESTJ |
| ISFP | MATLAB / Simulink Beginner | Simulink | Simulink Onramp | ESFJ | ENTJ |
| ENFJ | Robotics & Mechanical Implementation | Simulink | Robotics System Toolbox | INFP | ISTJ |
| ESFJ | Plant Modeling & Simulation | Simulink | Simscape | ISFP | INTP |
| INFJ | Control Algorithm Developer (Simulink) | Simulink | Simulink Control Design | ENTP | ESTP |
| ISFJ | Motor Control & Electrification | Simulink | Motor Control Blockset | ESTP | ENTP |

---

### How It Works

1. **Launch** the app in MATLAB — the Start screen appears with language selection.
2. **Select a language**: Korean or English.
3. **Answer 12 questions** by clicking **A** or **B** (or **Skip** to leave a question blank).
4. Use the **Back** button to revisit previous answers.
5. After the last question, the app calculates your **MBTI type** based on 4 dimensions:
   - **T/F** (Thinking / Feeling): Questions 1, 5, 9
   - **J/P** (Judging / Perceiving): Questions 2, 6, 10
   - **E/I** (Extroversion / Introversion): Questions 3, 7, 11
   - **N/S** (iNtuition / Sensing): Questions 4, 8, 12
6. The **Result screen** shows your MBTI type, matched engineering role, recommended toolbox, and compatibility.
7. You can **save your result** as a PNG, **explore the product page**, or **retry** the quiz.

---

### Requirements

- **MATLAB R2023a** or later
- MATLAB **App Designer** (included with MATLAB)
- *(Optional)* MathWorks toolboxes listed in the results table for full product exploration

---

### Getting Started

```matlab
% 1. Open MATLAB
% 2. Navigate to the project directory
cd /path/to/MBTI

% 3. Run the app
MBTIApp
```

Alternatively, open `MBTIApp.m` in **MATLAB App Designer** and click **Run**.

---

### Project Structure

```
MBTI/
├── MBTIApp.m              # Main MATLAB App Designer application
├── images/
│   ├── mbti/              # MBTI type icons (ENTP.png ~ ISFJ.png) — add icons here
│   ├── questions/         # Question illustration images (Q1.png ~ Q12.png)
│   ├── qrcode.png         # QR code for direct app access
│   └── matlab_logo.png    # (Optional) Custom fallback logo when MBTI icon is missing
├── .devcontainer/
│   └── devcontainer.json  # Dev container configuration for cloud development
├── .vscode/
│   ├── launch.json        # VS Code debugger configuration
│   └── settings.json      # VS Code workspace settings
└── README.md              # This file
```

> **Note:** MBTI icon images (`images/mbti/ENTP.png`, etc.) and question images (`images/questions/Q1.png`–`Q12.png`) are not included in this repository. When an MBTI icon is missing, the app falls back in order: `images/matlab_logo.png` → MATLAB built-in icon.
