<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    request.setAttribute("pageTitle", "AI模拟面试 - 毕业管理系统");
%>

<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>
<jsp:include page="/WEB-INF/jsp/common/navbar.jsp"/>

<style>
    body {
        background: #f3f6fb;
    }

    .page-title {
        font-size: 22px;
        font-weight: 800;
        color: #1e293b;
        margin-bottom: 18px;
    }

    .top-settings {
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 18px;
        padding: 16px;
        margin-bottom: 16px;
        box-shadow: 0 6px 18px rgba(15, 23, 42, 0.04);
    }

    .interview-layout {
        display: grid;
        grid-template-columns: 0.95fr 1.05fr 1fr;
        gap: 16px;
        align-items: stretch;
    }

    .interview-card {
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 18px;
        box-shadow: 0 8px 22px rgba(15, 23, 42, 0.06);
        overflow: hidden;
        min-height: 560px;
    }

    .card-header-custom {
        padding: 14px 16px;
        border-bottom: 1px solid #e5e7eb;
        background: linear-gradient(135deg, #f8fafc, #eef4ff);
    }

    .card-header-custom h5 {
        margin: 0;
        color: #1e3a8a;
        font-size: 17px;
        font-weight: 800;
    }

    .card-header-custom small {
        color: #64748b;
        font-size: 12px;
    }

    .card-body-custom {
        padding: 16px;
    }

    .student-video-box {
        width: 100%;
        height: 260px;
        background: #0f172a;
        border-radius: 16px;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    video {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    .ai-stage {
        position: relative;
        height: 360px;
        border-radius: 18px;
        overflow: hidden;
        background: linear-gradient(180deg, #eef6ff 0%, #ffffff 100%);
        border: 1px solid #dbeafe;
        display: flex;
        align-items: flex-end;
        justify-content: center;
    }

    .ai-stage::before {
        content: "";
        position: absolute;
        width: 260px;
        height: 260px;
        border-radius: 50%;
        background: rgba(59, 130, 246, 0.12);
        top: 28px;
        right: -60px;
    }

    .ai-image {
        position: relative;
        z-index: 2;
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center top;
        transform-origin: center bottom;
        transition: transform 0.25s ease, filter 0.25s ease;
    }

    .ai-stage.speaking .ai-image {
        animation: aiBodyTalking 0.85s ease-in-out infinite;
        filter: drop-shadow(0 10px 18px rgba(37, 99, 235, 0.22));
    }

    @keyframes aiBodyTalking {
        0% { transform: translateY(0) scale(1); }
        35% { transform: translateY(-3px) scale(1.008); }
        70% { transform: translateY(1px) scale(1.004); }
        100% { transform: translateY(0) scale(1); }
    }

    .mouth-light {
        position: absolute;
        z-index: 4;
        width: 72px;
        height: 26px;
        border-radius: 999px;
        left: 50%;
        top: 36%;
        transform: translateX(-50%);
        background: rgba(37, 99, 235, 0.10);
        opacity: 0;
        pointer-events: none;
    }

    .ai-stage.speaking .mouth-light {
        opacity: 1;
        animation: mouthPulse 0.35s ease-in-out infinite alternate;
    }

    @keyframes mouthPulse {
        from { transform: translateX(-50%) scaleX(0.78) scaleY(0.65); opacity: 0.25; }
        to { transform: translateX(-50%) scaleX(1.08) scaleY(1); opacity: 0.6; }
    }

    .voice-wave {
        position: absolute;
        left: 50%;
        bottom: 16px;
        transform: translateX(-50%);
        z-index: 5;
        display: none;
        gap: 5px;
        align-items: flex-end;
        padding: 8px 12px;
        border-radius: 999px;
        background: rgba(15, 23, 42, 0.48);
        backdrop-filter: blur(8px);
    }

    .ai-stage.speaking .voice-wave {
        display: flex;
    }

    .voice-wave span {
        display: block;
        width: 5px;
        height: 12px;
        border-radius: 999px;
        background: #ffffff;
        animation: wave 0.7s infinite ease-in-out;
    }

    .voice-wave span:nth-child(2) { animation-delay: 0.1s; }
    .voice-wave span:nth-child(3) { animation-delay: 0.2s; }
    .voice-wave span:nth-child(4) { animation-delay: 0.3s; }
    .voice-wave span:nth-child(5) { animation-delay: 0.4s; }

    @keyframes wave {
        0%, 100% { height: 8px; }
        50% { height: 26px; }
    }

    .ai-status {
        margin-top: 12px;
        padding: 12px;
        border-radius: 14px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
        color: #334155;
        line-height: 1.7;
        font-size: 14px;
    }

    .current-question {
        margin-top: 12px;
        padding: 14px;
        border-radius: 14px;
        background: #eff6ff;
        border-left: 5px solid #2563eb;
        color: #1e3a8a;
        line-height: 1.8;
        font-weight: 700;
        min-height: 96px;
    }

    .dialogue-box {
        max-height: 260px;
        overflow-y: auto;
        padding-right: 4px;
    }

    .bubble {
        padding: 10px 12px;
        border-radius: 14px;
        margin-bottom: 10px;
        line-height: 1.7;
        font-size: 14px;
    }

    .bubble-ai {
        background: #eff6ff;
        color: #1e3a8a;
        border: 1px solid #bfdbfe;
    }

    .bubble-user {
        background: #f8fafc;
        color: #334155;
        border: 1px solid #e5e7eb;
    }

    .bubble strong {
        display: block;
        margin-bottom: 4px;
        font-size: 13px;
    }

    .status-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
        margin-top: 12px;
    }

    .status-item {
        padding: 11px;
        border-radius: 14px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
    }

    .status-item span {
        display: block;
        color: #64748b;
        font-size: 12px;
        margin-bottom: 5px;
    }

    .status-item strong {
        font-size: 20px;
        color: #0f172a;
    }

    .coach-main {
        padding: 16px;
        border-radius: 16px;
        background: linear-gradient(135deg, #eff6ff, #f8fafc);
        border: 1px solid #bfdbfe;
        margin-bottom: 12px;
    }

    .coach-main .emotion {
        font-size: 32px;
        font-weight: 900;
        color: #1d4ed8;
        margin: 6px 0;
    }

    .advice-box {
        padding: 14px;
        border-radius: 16px;
        background: #f8fafc;
        border: 1px solid #e5e7eb;
    }

    .advice-box h6 {
        font-weight: 800;
        color: #334155;
        margin-bottom: 8px;
    }

    .advice-box ul {
        margin: 0;
        padding-left: 18px;
        color: #475569;
        line-height: 1.8;
        font-size: 14px;
    }

    .score-card {
        margin-top: 12px;
        border-radius: 16px;
        border: 1px solid #dbeafe;
        background: #ffffff;
        padding: 14px;
    }

    .score-total {
        font-size: 38px;
        font-weight: 900;
        color: #2563eb;
    }

    .score-row {
        margin-top: 8px;
    }

    .score-row label {
        display: flex;
        justify-content: space-between;
        color: #475569;
        font-size: 13px;
        margin-bottom: 4px;
    }

    .score-bar {
        height: 8px;
        background: #e5e7eb;
        border-radius: 999px;
        overflow: hidden;
    }

    .score-bar div {
        height: 100%;
        background: linear-gradient(90deg, #2563eb, #7c3aed);
        width: 0;
        transition: width 0.35s ease;
    }

    .btn-round {
        border-radius: 999px;
        padding-left: 18px;
        padding-right: 18px;
    }

    .recording {
        background: #fee2e2 !important;
        color: #991b1b !important;
        border-color: #fecaca !important;
    }

    .final-report {
        display: none;
        margin-top: 12px;
        border-radius: 16px;
        padding: 14px;
        border: 1px solid #bbf7d0;
        background: #f0fdf4;
        color: #166534;
        line-height: 1.8;
        font-size: 14px;
    }

    @media (max-width: 1200px) {
        .interview-layout {
            grid-template-columns: 1fr;
        }
    }
</style>

<div class="container">
    <div class="row">
        <jsp:include page="/WEB-INF/jsp/student/sidebar.jsp"/>

        <div class="col-md-9">
            <h3 class="page-title">AI 模拟面试训练</h3>

            <div class="top-settings">
                <div class="row align-items-end">
                    <div class="col-md-3 mb-2">
                        <label class="form-label">岗位方向</label>
                        <select id="jobDirection" class="form-select">
                            <option value="后端开发">后端开发</option>
                            <option value="前端开发">前端开发</option>
                            <option value="数据分析">数据分析</option>
                            <option value="软件测试">软件测试</option>
                            <option value="产品经理">产品经理</option>
                        </select>
                    </div>

                    <div class="col-md-3 mb-2">
                        <label class="form-label">面试官性格</label>
                        <select id="interviewerStyle" class="form-select">
                            <option value="亲和引导型">亲和引导型</option>
                            <option value="严肃压力型">严肃压力型</option>
                            <option value="技术深挖型">技术深挖型</option>
                            <option value="HR综合型">HR综合型</option>
                            <option value="校园招聘型">校园招聘型</option>
                        </select>
                    </div>

                    <div class="col-md-3 mb-2">
                        <label class="form-label">面试特点</label>
                        <select id="interviewFocus" class="form-select">
                            <option value="偏项目经历">偏项目经历</option>
                            <option value="偏技术细节">偏技术细节</option>
                            <option value="偏综合素质">偏综合素质</option>
                            <option value="偏抗压追问">偏抗压追问</option>
                            <option value="偏职业规划">偏职业规划</option>
                        </select>
                    </div>

                    <div class="col-md-3 mb-2 text-md-end">
                        <button class="btn btn-primary btn-round" onclick="startInterview()">开始面试</button>
                        <button class="btn btn-outline-danger btn-round ms-2" onclick="endInterview()">结束</button>
                    </div>
                </div>
            </div>

            <div class="interview-layout">
                <!-- 左侧：学生 -->
                <div class="interview-card">
                    <div class="card-header-custom">
                        <h5>学生面试画面</h5>
                        <small>摄像头 + 麦克风回答</small>
                    </div>

                    <div class="card-body-custom">
                        <div class="student-video-box">
                            <video id="video" autoplay muted></video>
                        </div>

                        <div class="status-grid">
                            <div class="status-item">
                                <span>当前状态</span>
                                <strong id="emotionLabel">未开始</strong>
                            </div>
                            <div class="status-item">
                                <span>识别置信度</span>
                                <strong id="emotionConfidence">--</strong>
                            </div>
                        </div>

                        <div class="mt-3 d-grid gap-2">
                            <button id="answerBtn" class="btn btn-outline-primary btn-round" onclick="startAnswering()">
                                开始语音回答
                            </button>
                            <button class="btn btn-outline-secondary btn-round" onclick="stopAnswering()">
                                结束本题回答
                            </button>
                        </div>

                        <label class="form-label mt-3">语音转写结果</label>
                        <textarea id="answerText"
                                  class="form-control"
                                  rows="8"
                                  placeholder="点击“开始语音回答”后，你说的话会自动显示在这里。浏览器不支持时可手动输入。"></textarea>

                        <button class="btn btn-outline-success btn-sm mt-3" onclick="submitCurrentAnswer()">
                            提交本题回答
                        </button>
                    </div>
                </div>

                <!-- 中间：建议和评分 -->
                <div class="interview-card">
                    <div class="card-header-custom">
                        <h5>实时建议与自动评分</h5>
                        <small>融合回答内容、逻辑表达和情绪状态</small>
                    </div>

                    <div class="card-body-custom">
                        <div class="coach-main">
                            <div style="font-size: 13px; color: #64748b;">当前系统观察到你可能处于</div>
                            <div class="emotion" id="coachEmotion">未开始</div>
                            <div style="font-size: 13px; color: #475569;" id="coachShortTip">
                                开始面试后，系统会根据你的回答和状态给出建议。
                            </div>
                        </div>

                        <div class="advice-box">
                            <h6>实时调整建议</h6>
                            <ul id="adviceList">
                                <li>保持坐姿稳定，眼睛尽量看向摄像头。</li>
                                <li>回答问题时建议使用“背景—行动—结果”的结构。</li>
                                <li>先说结论，再展开细节，避免回答发散。</li>
                            </ul>
                        </div>

                        <div class="score-card">
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div style="font-size: 13px; color:#64748b;">当前综合评分</div>
                                    <div class="score-total"><span id="totalScore">0</span><small style="font-size:16px;"> 分</small></div>
                                </div>
                                <div style="text-align:right; color:#64748b; font-size:13px;">
                                    <div>问题数：<strong id="questionCountText">0</strong></div>
                                    <div>主要情绪：<strong id="mainEmotion">--</strong></div>
                                    <div>识别次数：<strong id="detectCount">0</strong></div>
                                </div>
                            </div>

                            <div class="score-row">
                                <label><span>回答内容</span><span id="contentScoreText">0/40</span></label>
                                <div class="score-bar"><div id="contentScoreBar"></div></div>
                            </div>

                            <div class="score-row">
                                <label><span>逻辑表达</span><span id="logicScoreText">0/20</span></label>
                                <div class="score-bar"><div id="logicScoreBar"></div></div>
                            </div>

                            <div class="score-row">
                                <label><span>情绪稳定</span><span id="emotionScoreText">0/20</span></label>
                                <div class="score-bar"><div id="emotionScoreBar"></div></div>
                            </div>

                            <div class="score-row">
                                <label><span>完成度</span><span id="completionScoreText">0/10</span></label>
                                <div class="score-bar"><div id="completionScoreBar"></div></div>
                            </div>

                            <div class="score-row">
                                <label><span>岗位匹配</span><span id="matchScoreText">0/10</span></label>
                                <div class="score-bar"><div id="matchScoreBar"></div></div>
                            </div>
                        </div>

                        <div class="final-report" id="finalReport"></div>
                    </div>
                </div>

                <!-- 右侧：AI 面试官 -->
                <div class="interview-card">
                    <div class="card-header-custom">
                        <h5>AI 面试官</h5>
                        <small>语音提问 + 动态追问</small>
                    </div>

                    <div class="card-body-custom">
                        <div class="ai-stage" id="aiStage">
                            <img class="ai-image"
                                 src="${pageContext.request.contextPath}/static/imag/ai_interviewer.jpg"
                                 alt="AI面试官">
                            <div class="mouth-light"></div>
                            <div class="voice-wave">
                                <span></span><span></span><span></span><span></span><span></span>
                            </div>
                        </div>

                        <div class="ai-status">
                            <strong id="interviewerName">睿试面试官</strong>
                            <div id="interviewerDesc">专业、中立、引导型面试官</div>
                        </div>

                        <div class="current-question" id="currentQuestion">
                            请先选择岗位方向，然后点击“开始面试”。
                        </div>

                        <div class="mt-3 d-grid gap-2">
                            <button class="btn btn-primary btn-round" onclick="nextQuestion()">
                                下一题 / 动态追问
                            </button>
                            <button class="btn btn-outline-primary btn-round" onclick="repeatQuestion()">
                                重播当前问题
                            </button>
                            <button class="btn btn-success btn-round" onclick="saveInterview()">
                                保存面试记录
                            </button>
                        </div>

                        <hr/>

                        <div class="dialogue-box" id="dialogueBox"></div>

                        <div id="saveResult" class="mt-3"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<canvas id="captureCanvas" width="320" height="240" style="display:none;"></canvas>

<script>
    let video = document.getElementById("video");
    let canvas = document.getElementById("captureCanvas");
    let ctx = canvas.getContext("2d");

    let stream = null;
    let timer = null;

    let latestEmotion = "未识别";
    let latestConfidence = 0;
    let latestAdviceList = [];

    let detectCount = 0;
    let confidenceSum = 0;
    let emotionCounter = {};

    let questionRecords = [];
    let currentQuestion = "";

    let recognition = null;
    let recognizing = false;

    let currentScores = {
        content: 0,
        logic: 0,
        emotion: 0,
        completion: 0,
        match: 0,
        total: 0
    };

    const fallbackQuestions = {
        "后端开发": "请介绍一个你做过的后端项目，并说明你负责的模块、数据库设计和接口实现。",
        "前端开发": "请介绍一个你做过的前端页面，并说明你的交互设计和用户体验优化。",
        "数据分析": "请介绍一次数据分析经历，并说明你如何清洗数据、选择指标和解释结论。",
        "软件测试": "请以登录功能为例，说明你会如何设计测试用例。",
        "产品经理": "如果让你设计学生就业管理系统，你会优先设计哪些核心功能？为什么？"
    };

    const jobKeywords = {
        "后端开发": ["后端", "数据库", "接口", "Servlet", "MySQL", "事务", "权限", "性能", "SQL", "登录", "模块", "项目"],
        "前端开发": ["前端", "页面", "交互", "组件", "响应式", "用户体验", "Vue", "JSP", "样式", "布局"],
        "数据分析": ["数据", "清洗", "指标", "可视化", "模型", "趋势", "分析", "图表", "预测"],
        "软件测试": ["测试", "用例", "边界", "缺陷", "Bug", "复现", "自动化", "黑盒", "白盒"],
        "产品经理": ["需求", "用户", "原型", "流程", "迭代", "体验", "功能", "场景", "产品"]
    };

    const emotionAdviceMap = {
        "紧张": ["先深呼吸 2 秒，再开始回答。", "语速放慢，把答案拆成 3 点来讲。", "回答时先说结论，再补充项目细节。"],
        "疑惑": ["可以先复述问题，确认自己理解正确。", "不会的问题不要沉默，可以先说分析思路。", "先讲已知部分，再说明你会如何查资料或验证。"],
        "平静": ["状态比较稳定，可以继续保持。", "建议增加项目细节，让回答更有说服力。", "可以加入结果数据，例如提升效率、减少错误率。"],
        "专注": ["专注度不错，继续保持看向摄像头。", "注意回答不要过长，每题控制在 1 到 2 分钟。", "可以用“首先、其次、最后”增强逻辑。"],
        "微笑": ["亲和力较好，适合自我介绍。", "技术问题回答时要更加严谨。", "可以结合项目成果展示自信。"],
        "低落": ["请抬头看向摄像头，保持自然坐姿。", "回答时语气可以更坚定一些。", "可以强调自己的成长过程和改进方向。"],
        "惊讶": ["遇到意外问题时，先停顿一秒组织思路。", "不要急着否定自己，可以先说目前理解。", "把问题拆开，先回答最有把握的部分。"],
        "未识别": ["请调整摄像头角度，保证面部在画面中央。", "保持光线充足，避免背光。", "坐姿稳定有助于系统识别。"]
    };

    async function startInterview() {
        resetInterviewState();

        let jobDirection = document.getElementById("jobDirection").value;
        let style = document.getElementById("interviewerStyle").value;
        let focus = document.getElementById("interviewFocus").value;

        document.getElementById("interviewerDesc").innerText = style + " · " + focus + " · " + jobDirection;

        try {
            stream = await navigator.mediaDevices.getUserMedia({video: true, audio: true});
            video.srcObject = stream;

            initSpeechRecognition();

            document.getElementById("emotionLabel").innerText = "识别中...";
            document.getElementById("coachEmotion").innerText = "识别中...";
            document.getElementById("coachShortTip").innerText = "系统正在观察你的面试状态，请保持面部在画面中央。";

            timer = setInterval(captureAndDetect, 2000);

            await nextQuestion();

        } catch (e) {
            alert("无法打开摄像头或麦克风，请检查浏览器权限。");
        }
    }

    function resetInterviewState() {
        questionRecords = [];
        currentQuestion = "";
        latestEmotion = "未识别";
        latestConfidence = 0;
        latestAdviceList = [];
        detectCount = 0;
        confidenceSum = 0;
        emotionCounter = {};

        currentScores = {content: 0, logic: 0, emotion: 0, completion: 0, match: 0, total: 0};

        document.getElementById("dialogueBox").innerHTML = "";
        document.getElementById("saveResult").innerHTML = "";
        document.getElementById("finalReport").style.display = "none";
        document.getElementById("answerText").value = "";
        updateScoreUI();
    }

    function endInterview() {
        stopAnswering();

        if (timer) {
            clearInterval(timer);
            timer = null;
        }

        if (stream) {
            stream.getTracks().forEach(track => track.stop());
            stream = null;
        }

        submitCurrentAnswer();
        calculateScores();
        buildFinalReport();

        document.getElementById("emotionLabel").innerText = latestEmotion || "已结束";
    }

    async function nextQuestion() {
        submitCurrentAnswer();

        let jobDirection = document.getElementById("jobDirection").value;
        let interviewerStyle = document.getElementById("interviewerStyle").value;
        let interviewFocus = document.getElementById("interviewFocus").value;

        let lastQuestion = "";
        let lastAnswer = "";

        if (questionRecords.length > 0) {
            lastQuestion = questionRecords[questionRecords.length - 1].question || "";
            lastAnswer = questionRecords[questionRecords.length - 1].answer || "";
        }

        let formData = new URLSearchParams();
        formData.append("jobDirection", jobDirection);
        formData.append("interviewerStyle", interviewerStyle);
        formData.append("interviewFocus", interviewFocus);
        formData.append("currentQuestion", lastQuestion);
        formData.append("answerText", lastAnswer);
        formData.append("mainEmotion", latestEmotion);
        formData.append("questionCount", questionRecords.length);

        let question = "";

        try {
            let resp = await fetch("${pageContext.request.contextPath}/student/mock-interview/question", {
                method: "POST",
                headers: {"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"},
                body: formData.toString()
            });

            let data = await resp.json();
            question = data.question || "";
        } catch (e) {
            question = "";
        }

        if (!question || question.trim().length === 0) {
            question = fallbackQuestions[jobDirection] || fallbackQuestions["后端开发"];
        }

        currentQuestion = question;
        document.getElementById("currentQuestion").innerText = question;
        document.getElementById("answerText").value = "";

        questionRecords.push({question: question, answer: ""});

        addDialogue("ai", question);
        calculateScores();
        speakText(question);
    }

    function repeatQuestion() {
        if (currentQuestion && currentQuestion.length > 0) {
            speakText(currentQuestion);
        }
    }

    function speakText(text) {
        if (!("speechSynthesis" in window)) {
            return;
        }

        window.speechSynthesis.cancel();

        let utter = new SpeechSynthesisUtterance(text);
        utter.lang = "zh-CN";
        utter.rate = 0.95;
        utter.pitch = 1.05;
        utter.volume = 1;

        utter.onstart = function () {
            document.getElementById("aiStage").classList.add("speaking");
        };

        utter.onend = function () {
            document.getElementById("aiStage").classList.remove("speaking");
        };

        utter.onerror = function () {
            document.getElementById("aiStage").classList.remove("speaking");
        };

        window.speechSynthesis.speak(utter);
    }

    function initSpeechRecognition() {
        let SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

        if (!SpeechRecognition) {
            return;
        }

        recognition = new SpeechRecognition();
        recognition.lang = "zh-CN";
        recognition.continuous = true;
        recognition.interimResults = true;

        recognition.onstart = function () {
            recognizing = true;
            document.getElementById("answerBtn").classList.add("recording");
            document.getElementById("answerBtn").innerText = "正在聆听回答...";
        };

        recognition.onend = function () {
            recognizing = false;
            document.getElementById("answerBtn").classList.remove("recording");
            document.getElementById("answerBtn").innerText = "开始语音回答";
        };

        recognition.onresult = function (event) {
            let finalText = "";
            let interimText = "";

            for (let i = event.resultIndex; i < event.results.length; i++) {
                let transcript = event.results[i][0].transcript;
                if (event.results[i].isFinal) {
                    finalText += transcript;
                } else {
                    interimText += transcript;
                }
            }

            let box = document.getElementById("answerText");

            if (finalText.length > 0) {
                box.value = (box.value + finalText).trim();
            }

            if (interimText.length > 0) {
                document.getElementById("coachShortTip").innerText = "正在识别你的回答：" + interimText;
            }
        };
    }

    function startAnswering() {
        if (!recognition) {
            initSpeechRecognition();
        }

        if (!recognition) {
            alert("当前浏览器不支持语音识别，请使用 Chrome 浏览器，或先手动输入回答。");
            return;
        }

        if (!recognizing) {
            try {
                recognition.start();
            } catch (e) {
            }
        }
    }

    function stopAnswering() {
        if (recognition && recognizing) {
            recognition.stop();
        }

        submitCurrentAnswer();
    }

    function submitCurrentAnswer() {
        let answer = document.getElementById("answerText").value.trim();

        if (questionRecords.length > 0 && answer.length > 0) {
            questionRecords[questionRecords.length - 1].answer = answer;
            refreshDialogue();
            calculateScores();
        }
    }

    function addDialogue(type, text) {
        let box = document.getElementById("dialogueBox");
        let div = document.createElement("div");
        div.className = type === "ai" ? "bubble bubble-ai" : "bubble bubble-user";
        div.innerHTML = type === "ai"
            ? "<strong>AI 面试官</strong>" + escapeHtml(text)
            : "<strong>我的回答</strong>" + escapeHtml(text);
        box.appendChild(div);
        box.scrollTop = box.scrollHeight;
    }

    function refreshDialogue() {
        let box = document.getElementById("dialogueBox");
        box.innerHTML = "";

        for (let i = 0; i < questionRecords.length; i++) {
            addDialogue("ai", questionRecords[i].question);
            if (questionRecords[i].answer && questionRecords[i].answer.length > 0) {
                addDialogue("user", questionRecords[i].answer);
            }
        }
    }

    async function captureAndDetect() {
        if (!video || video.readyState < 2) {
            return;
        }

        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        let imageBase64 = canvas.toDataURL("image/jpeg");

        try {
            let resp = await fetch("http://127.0.0.1:8001/detect-emotion", {
                method: "POST",
                headers: {"Content-Type": "application/json"},
                body: JSON.stringify({image: imageBase64})
            });

            let data = await resp.json();

            latestEmotion = data.emotion || "未识别";
            latestConfidence = data.confidence || 0;

            if (Array.isArray(data.adviceList)) {
                latestAdviceList = data.adviceList;
            } else {
                latestAdviceList = [];
            }

            detectCount++;
            confidenceSum += latestConfidence;
            emotionCounter[latestEmotion] = (emotionCounter[latestEmotion] || 0) + 1;

            updateEmotionUI();
            calculateScores();

        } catch (e) {
            console.error("情绪识别接口调用失败：", e);

            latestEmotion = "服务未连接";
            latestConfidence = 0;
            latestAdviceList = [
                "Python 情绪识别服务没有成功返回结果。",
                "请检查 http://127.0.0.1:8001/docs 是否能打开。",
                "请查看 Python 控制台是否有 DeepFace 或模型加载报错。"
            ];

            document.getElementById("emotionLabel").innerText = "服务未连接";
            document.getElementById("emotionConfidence").innerText = "--";
            document.getElementById("coachEmotion").innerText = "服务未连接";
            document.getElementById("coachShortTip").innerText = "情绪识别接口调用失败，请检查 Python 服务。";

            let adviceList = document.getElementById("adviceList");
            adviceList.innerHTML = "";
            for (let i = 0; i < latestAdviceList.length; i++) {
                let li = document.createElement("li");
                li.innerText = latestAdviceList[i];
                adviceList.appendChild(li);
            }
        }
    }

    function updateEmotionUI() {
        document.getElementById("emotionLabel").innerText = latestEmotion;
        document.getElementById("emotionConfidence").innerText = (latestConfidence * 100).toFixed(1) + "%";

        document.getElementById("coachEmotion").innerText = latestEmotion;
        document.getElementById("coachShortTip").innerText = buildShortTip(latestEmotion);

        let adviceList = document.getElementById("adviceList");
        adviceList.innerHTML = "";

        let advice = latestAdviceList && latestAdviceList.length > 0
            ? latestAdviceList
            : (emotionAdviceMap[latestEmotion] || emotionAdviceMap["未识别"]);

        for (let i = 0; i < advice.length; i++) {
            let li = document.createElement("li");
            li.innerText = advice[i];
            adviceList.appendChild(li);
        }

        document.getElementById("detectCount").innerText = detectCount;
        document.getElementById("mainEmotion").innerText = getMainEmotion();
    }

    function buildShortTip(emotion) {
        if (emotion === "紧张") return "建议先放慢语速，用三点式结构回答，避免急促表达。";
        if (emotion === "疑惑") return "建议先复述问题，再讲分析思路，不要直接沉默。";
        if (emotion === "微笑") return "亲和力不错，适合自我介绍，但技术问题要保持严谨。";
        if (emotion === "专注") return "专注状态较好，继续保持眼神稳定和回答结构清晰。";
        if (emotion === "平静") return "状态比较稳定，可以增加项目细节和结果数据。";
        if (emotion === "低落") return "建议抬头看向摄像头，语气更坚定一些。";
        if (emotion === "惊讶") return "遇到意外问题时可以先停顿一秒，组织思路后再回答。";
        return "请保证面部在画面中央，并保持环境光线稳定。";
    }

    function calculateScores() {
        let jobDirection = document.getElementById("jobDirection").value;

        let allAnswers = questionRecords.map(r => r.answer || "").join(" ");
        let answeredCount = questionRecords.filter(r => r.answer && r.answer.trim().length > 0).length;

        let contentScore = calcContentScore(allAnswers);
        let logicScore = calcLogicScore(allAnswers);
        let emotionScore = calcEmotionScore();
        let completionScore = Math.min(10, answeredCount * 2);
        let matchScore = calcMatchScore(allAnswers, jobDirection);

        let total = Math.round(contentScore + logicScore + emotionScore + completionScore + matchScore);

        currentScores = {
            content: contentScore,
            logic: logicScore,
            emotion: emotionScore,
            completion: completionScore,
            match: matchScore,
            total: total
        };

        updateScoreUI();
    }

    function calcContentScore(text) {
        if (!text || text.length === 0) return 0;

        let score = 8;

        if (text.length > 30) score += 6;
        if (text.length > 80) score += 6;
        if (text.length > 150) score += 6;

        let keywords = ["项目", "负责", "实现", "设计", "优化", "问题", "解决", "结果", "提升", "数据库", "接口", "用户"];
        score += countKeywordHits(text, keywords) * 2;

        return Math.min(40, score);
    }

    function calcLogicScore(text) {
        if (!text || text.length === 0) return 0;

        let score = 5;
        let logicWords = ["首先", "其次", "最后", "第一", "第二", "第三", "因为", "所以", "然后", "同时", "最终", "总结"];
        score += countKeywordHits(text, logicWords) * 2.5;

        if (text.indexOf("背景") >= 0 || text.indexOf("原因") >= 0) score += 3;
        if (text.indexOf("过程") >= 0 || text.indexOf("方法") >= 0) score += 3;
        if (text.indexOf("结果") >= 0 || text.indexOf("效果") >= 0) score += 3;

        return Math.min(20, score);
    }

    function calcEmotionScore() {
        if (detectCount === 0) return 8;

        let stable = 0;
        stable += emotionCounter["平静"] || 0;
        stable += emotionCounter["专注"] || 0;
        stable += emotionCounter["微笑"] || 0;

        let unstable = 0;
        unstable += emotionCounter["紧张"] || 0;
        unstable += emotionCounter["疑惑"] || 0;
        unstable += emotionCounter["低落"] || 0;

        let score = 12 + (stable / detectCount) * 8 - (unstable / detectCount) * 5;
        return Math.max(5, Math.min(20, score));
    }

    function calcMatchScore(text, jobDirection) {
        if (!text || text.length === 0) return 0;

        let keywords = jobKeywords[jobDirection] || [];
        let hits = countKeywordHits(text, keywords);
        return Math.min(10, hits * 2);
    }

    function countKeywordHits(text, keywords) {
        let count = 0;
        for (let i = 0; i < keywords.length; i++) {
            if (text.indexOf(keywords[i]) >= 0) {
                count++;
            }
        }
        return count;
    }

    function updateScoreUI() {
        document.getElementById("totalScore").innerText = currentScores.total;
        document.getElementById("questionCountText").innerText = questionRecords.length;

        setScoreBar("contentScore", currentScores.content, 40);
        setScoreBar("logicScore", currentScores.logic, 20);
        setScoreBar("emotionScore", currentScores.emotion, 20);
        setScoreBar("completionScore", currentScores.completion, 10);
        setScoreBar("matchScore", currentScores.match, 10);
    }

    function setScoreBar(prefix, value, max) {
        let fixed = Math.round(value);
        document.getElementById(prefix + "Text").innerText = fixed + "/" + max;
        document.getElementById(prefix + "Bar").style.width = Math.min(100, value / max * 100) + "%";
    }

    function buildFinalReport() {
        let main = getMainEmotion();
        let report =
            "<strong>本次模拟面试评估报告</strong><br/>" +
            "综合评分：" + currentScores.total + " 分<br/>" +
            "回答内容：" + Math.round(currentScores.content) + "/40，逻辑表达：" + Math.round(currentScores.logic) + "/20，情绪稳定：" + Math.round(currentScores.emotion) + "/20。<br/>" +
            "主要情绪状态：" + main + "。<br/>" +
            "系统建议：回答时继续使用“结论先行 + 项目细节 + 结果数据”的结构；如果出现紧张或疑惑，先短暂停顿，再分点回答。";

        let box = document.getElementById("finalReport");
        box.innerHTML = report;
        box.style.display = "block";
    }

    function getMainEmotion() {
        let maxEmotion = "--";
        let maxCount = 0;

        for (let key in emotionCounter) {
            if (emotionCounter[key] > maxCount) {
                maxCount = emotionCounter[key];
                maxEmotion = key;
            }
        }

        return maxEmotion;
    }

    async function saveInterview() {
        submitCurrentAnswer();
        calculateScores();

        let jobDirection = document.getElementById("jobDirection").value;

        let questionText = "";
        let answerText = "";

        for (let i = 0; i < questionRecords.length; i++) {
            questionText += "Q" + (i + 1) + "：" + questionRecords[i].question + "\n";
            answerText += "Q" + (i + 1) + "：" + questionRecords[i].question + "\n";
            answerText += "A" + (i + 1) + "：" + (questionRecords[i].answer || "未填写") + "\n\n";
        }

        answerText += "\n【自动评分】\n";
        answerText += "综合评分：" + currentScores.total + "\n";
        answerText += "回答内容：" + Math.round(currentScores.content) + "/40\n";
        answerText += "逻辑表达：" + Math.round(currentScores.logic) + "/20\n";
        answerText += "情绪稳定：" + Math.round(currentScores.emotion) + "/20\n";
        answerText += "完成度：" + Math.round(currentScores.completion) + "/10\n";
        answerText += "岗位匹配：" + Math.round(currentScores.match) + "/10\n";

        let formData = new URLSearchParams();
        formData.append("jobDirection", jobDirection);
        formData.append("questionText", questionText);
        formData.append("answerText", answerText);
        formData.append("mainEmotion", getMainEmotion());
        formData.append("confidenceScore", detectCount > 0 ? (confidenceSum / detectCount) : 0);

        let resp = await fetch("${pageContext.request.contextPath}/student/mock-interview/save", {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"},
            body: formData.toString()
        });

        let text = await resp.text();

        document.getElementById("saveResult").innerHTML =
            "<div class='alert alert-info'>" + escapeHtml(text) + "</div>";
    }

    function escapeHtml(str) {
        if (str == null) return "";

        return String(str)
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>