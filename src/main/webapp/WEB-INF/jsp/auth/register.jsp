<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    request.setAttribute("pageTitle", "用户注册 - 毕业管理系统");
%>
<jsp:include page="/WEB-INF/jsp/common/header.jsp"/>

<style>
    body {
        background: url('<%=request.getContextPath()%>/static/imag/campus-bg.jpg') center center / cover no-repeat fixed;
    }

    .register-page-overlay {
        background: rgba(15, 23, 42, 0.70);
        min-height: calc(100vh - 56px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 40px 0;
    }

    .register-card {
        border-radius: 18px;
        overflow: hidden;
        box-shadow: 0 18px 40px rgba(15, 23, 42, 0.45);
        border: 1px solid rgba(147, 197, 253, 0.85);
        background: linear-gradient(165deg, rgba(248, 250, 255, 0.98), rgba(237, 244, 255, 0.98));
    }

    .register-card-header {
        background: linear-gradient(135deg, #059669, #10b981);
        color: #fff;
        padding: 14px 22px;
    }

    .register-card-header h5 {
        font-size: 19px;
        font-weight: 600;
        margin: 0;
    }

    .register-card-body {
        padding: 20px 22px 16px 22px;
    }

    .register-card-body .form-label {
        font-size: 13px;
        color: #0f172a;
        font-weight: 500;
    }

    .register-card-body .form-control,
    .register-card-body .form-select {
        border-radius: 8px;
        border: 1px solid #cbd5f5;
        font-size: 14px;
    }

    .register-card-body .form-control:focus,
    .register-card-body .form-select:focus {
        border-color: #2563eb;
        box-shadow: 0 0 0 0.15rem rgba(37, 99, 235, 0.25);
    }

    .register-section {
        border-radius: 10px !important;
        border-color: rgba(148, 163, 184, 0.4) !important;
        background: rgba(255, 255, 255, 0.9);
    }

    .register-section h6 {
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 8px;
    }

    .register-section small {
        font-size: 12px;
        color: #6b7280;
    }

    .role-label {
        font-size: 13px;
    }

    .register-card-footer {
        background: rgba(248, 250, 252, 0.98);
        padding: 10px 18px;
        font-size: 13px;
        border-top: 1px solid rgba(148, 163, 184, 0.4);
    }

    .register-card-footer a {
        color: #2563eb;
        text-decoration: none;
    }

    .register-card-footer a:hover {
        text-decoration: underline;
    }

    .register-help-text {
        font-size: 11px;
        color: #6b7280;
        margin-top: 6px;
        text-align: center;
    }

    @media (max-width: 768px) {
        .register-page-overlay {
            padding: 24px 12px;
        }
        .register-card-body {
            padding: 16px 16px 14px 16px;
        }
    }
</style>

<div class="register-page-overlay">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-7">
                <div class="card register-card">
                    <div class="register-card-header">
                        <h5 class="mb-0">用户注册</h5>
                    </div>
                    <div class="register-card-body">
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger py-2" role="alert">
                                    ${error}
                            </div>
                        </c:if>
                        <c:if test="${not empty success}">
                            <div class="alert alert-success py-2" role="alert">
                                    ${success}
                            </div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/register">
                            <!-- 基本信息 -->
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">用户名（学号/工号）</label>
                                    <input type="text" name="username" class="form-control"
                                           required value="${param.username}">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">真实姓名</label>
                                    <input type="text" name="realName" class="form-control"
                                           required value="${param.realName}">
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">密码</label>
                                    <input type="password" name="password" class="form-control" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="form-label">确认密码</label>
                                    <input type="password" name="confirmPassword" class="form-control" required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">性别</label>
                                    <select name="gender" class="form-select">
                                        <option value="男"  <c:if test="${param.gender == '男'}">selected</c:if>>男</option>
                                        <option value="女"  <c:if test="${param.gender == '女'}">selected</c:if>>女</option>
                                        <option value="其他" <c:if test="${param.gender == '其他'}">selected</c:if>>其他</option>
                                    </select>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">手机</label>
                                    <input type="text" name="phone" class="form-control"
                                           value="${param.phone}">
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label">邮箱</label>
                                    <input type="email" name="email" class="form-control"
                                           value="${param.email}">
                                </div>
                            </div>

                            <!-- 选择角色 -->
                            <div class="mb-3">
                                <label class="form-label">选择角色（可多选，管理员不能自助注册）</label>

                                <c:set var="selectedRoles" value="${paramValues.roles}" />
                                <c:set var="selectedRolesAsString"
                                       value="${fn:join(selectedRoles, ',')}" />

                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox"
                                           name="roles" value="STUDENT"
                                           id="roleStudent"
                                           <c:if test="${selectedRoles != null and fn:contains(selectedRolesAsString, 'STUDENT')}">checked</c:if>>
                                    <label class="form-check-label role-label" for="roleStudent">学生</label>
                                </div>

                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox"
                                           name="roles" value="SUPERVISOR"
                                           id="roleSupervisor"
                                           <c:if test="${selectedRoles != null and fn:contains(selectedRolesAsString, 'SUPERVISOR')}">checked</c:if>>
                                    <label class="form-check-label role-label" for="roleSupervisor">指导老师</label>
                                </div>

                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox"
                                           name="roles" value="TEACHER"
                                           id="roleTeacher"
                                           <c:if test="${selectedRoles != null and fn:contains(selectedRolesAsString, 'TEACHER')}">checked</c:if>>
                                    <label class="form-check-label role-label" for="roleTeacher">普通教师</label>
                                </div>

                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox"
                                           name="roles" value="CLASS_TEACHER"
                                           id="roleClassTeacher"
                                           <c:if test="${selectedRoles != null and fn:contains(selectedRolesAsString, 'CLASS_TEACHER')}">checked</c:if>>
                                    <label class="form-check-label role-label" for="roleClassTeacher">班主任</label>
                                </div>

                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox"
                                           name="roles" value="COUNSELOR"
                                           id="roleCounselor"
                                           <c:if test="${selectedRoles != null and fn:contains(selectedRolesAsString, 'COUNSELOR')}">checked</c:if>>
                                    <label class="form-check-label role-label" for="roleCounselor">辅导员</label>
                                </div>
                            </div>

                            <!-- 学生信息：学院-专业-班级 级联选择 -->
                            <div class="border register-section p-3 mb-3">
                                <h6>学生信息</h6>
                                <small>如勾选“学生”角色，请通过学院 → 专业 → 班级进行选择：</small>

                                <!-- 隐藏域：最终用于后端逻辑的班级ID -->
                                <input type="hidden" name="studentClassId" id="studentClassId"
                                       value="${param.studentClassId}"/>

                                <div class="row mt-2">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">学院</label>
                                        <select id="deptSelect" class="form-select">
                                            <option value="">请选择学院</option>
                                            <c:forEach var="d" items="${departments}">
                                                <option value="${d.deptId}">${d.deptName}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">专业</label>
                                        <select id="majorSelect" class="form-select" disabled>
                                            <option value="">请先选择学院</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label">班级</label>
                                        <select id="classSelect" class="form-select" disabled>
                                            <option value="">请先选择专业</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="row mt-1">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label">入学年份（例如 2022）</label>
                                        <input type="number" name="studentEnrollYear" class="form-control"
                                               value="${param.studentEnrollYear}">
                                    </div>
                                </div>
                            </div>

                            <!-- 班主任额外信息 -->
                            <div class="border register-section p-3 mb-3">
                                <h6>班主任信息</h6>
                                <small>如勾选“班主任”角色，请填写以下内容：</small>
                                <div class="mt-2 mb-3">
                                    <label class="form-label">担任班主任的班级ID（class_id）</label>
                                    <input type="number" name="classTeacherClassId" class="form-control"
                                           value="${param.classTeacherClassId}">
                                </div>
                            </div>

                            <!-- 辅导员额外信息 -->
                            <div class="border register-section p-3 mb-3">
                                <h6>辅导员信息</h6>
                                <small>如勾选“辅导员”角色，请填写以下内容：</small>
                                <div class="mt-2 mb-3">
                                    <label class="form-label">负责专业ID（major_id）</label>
                                    <input type="number" name="counselorMajorId" class="form-control"
                                           value="${param.counselorMajorId}">
                                </div>
                            </div>

                            <button type="submit" class="btn btn-success w-100">提交注册</button>
                            <div class="register-help-text">
                                提示：请确保所选班级 / 专业信息准确无误，班主任角色对班级具有唯一性。
                            </div>
                        </form>
                    </div>
                    <div class="register-card-footer text-center">
                        已有账号？
                        <a href="${pageContext.request.contextPath}/login">返回登录</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    (function() {
        const ctx = '<%=request.getContextPath()%>';
        const deptSelect = document.getElementById('deptSelect');
        const majorSelect = document.getElementById('majorSelect');
        const classSelect = document.getElementById('classSelect');
        const studentClassIdInput = document.getElementById('studentClassId');

        console.log('ctx =', ctx);
        console.log('deptSelect =', deptSelect);
        console.log('majorSelect =', majorSelect);
        console.log('classSelect =', classSelect);

        if (!deptSelect || !majorSelect || !classSelect) {
            console.error('下拉框元素未找到，请检查 id 是否为 deptSelect / majorSelect / classSelect');
            return;
        }

        // 学院 -> 专业
        deptSelect.addEventListener('change', function () {
            const deptId = this.value;
            console.log('学院变更, deptId =', deptId);

            majorSelect.innerHTML = '<option value="">请选择专业</option>';
            classSelect.innerHTML = '<option value="">请先选择专业</option>';
            majorSelect.disabled = true;
            classSelect.disabled = true;
            studentClassIdInput.value = '';

            if (!deptId) {
                return;
            }

            const url = ctx + '/api/majors?deptId=' + encodeURIComponent(deptId);
            console.log('请求专业列表:', url);

            fetch(url)
                .then(resp => {
                    console.log('majors 响应状态:', resp.status);
                    return resp.json();
                })
                .then(data => {
                    console.log('majors 原始数据:', data);
                    const majors = Array.isArray(data) ? data
                        : (Array.isArray(data.majors) ? data.majors : []);

                    if (!majors.length) {
                        majorSelect.innerHTML = '<option value="">该学院暂无专业</option>';
                        return;
                    }

                    let html = '<option value="">请选择专业</option>';
                    majors.forEach(m => {
                        console.log('添加专业选项:', m.majorId, m.majorName);
                        html += '<option value="' + m.majorId + '">' + m.majorName + '</option>';
                    });
                    majorSelect.innerHTML = html;
                    majorSelect.disabled = false;
                })
                .catch(err => {
                    console.error('加载专业失败', err);
                    majorSelect.innerHTML = '<option value="">加载专业失败</option>';
                });
        });

        // 专业 -> 班级
        majorSelect.addEventListener('change', function () {
            const majorId = this.value;
            console.log('专业变更, majorId =', majorId);

            classSelect.innerHTML = '<option value="">请选择班级</option>';
            classSelect.disabled = true;
            studentClassIdInput.value = '';

            if (!majorId) {
                return;
            }

            const url = ctx + '/api/classes?majorId=' + encodeURIComponent(majorId);
            console.log('请求班级列表:', url);

            fetch(url)
                .then(resp => {
                    console.log('classes 响应状态:', resp.status);
                    return resp.json();
                })
                .then(data => {
                    console.log('classes 原始数据:', data);
                    const classes = Array.isArray(data) ? data
                        : (Array.isArray(data.classes) ? data.classes : []);

                    if (!classes.length) {
                        classSelect.innerHTML = '<option value="">该专业暂无班级</option>';
                        return;
                    }

                    let html = '<option value="">请选择班级</option>';
                    classes.forEach(c => {
                        console.log('添加班级选项:', c.classId, c.className);
                        html += '<option value="' + c.classId + '">' + c.className + '</option>';
                    });
                    classSelect.innerHTML = html;
                    classSelect.disabled = false;
                })
                .catch(err => {
                    console.error('加载班级失败', err);
                    classSelect.innerHTML = '<option value="">加载班级失败</option>';
                });
        });

        // 选择班级 -> 写入隐藏字段
        classSelect.addEventListener('change', function () {
            const classId = this.value;
            console.log('班级变更, classId =', classId);
            studentClassIdInput.value = classId || '';
        });
    })();
</script>

<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>