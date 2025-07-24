import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:notepad/common/config/application.dart';
import 'package:notepad/common/module/SingleCloseView.dart';
import 'package:notepad/common/utils/ThemeUtil.dart';
import 'package:notepad/controller/AuthController.dart';
import 'package:provider/provider.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  // 处理登录逻辑
  Future<void> _handleLogin(BuildContext context) async {
    // 防止重复点击
    if (_isLoading) return;

    final auth = context.read<AuthController>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // 校验输入
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = '用户名和密码不能为空');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 模拟网络延迟，让加载效果更明显
      await Future.delayed(const Duration(seconds: 1));
      // 调用登录方法
      auth.login(username, password);
    } catch (e) {
      setState(() => _errorMessage = '登录失败：${e.toString()}');
    } finally {
      // 确保在组件挂载的情况下才更新状态
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleCloseView(
      // 使用Scaffold作为页面根基，方便设置背景色和整体布局
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient:
                ThemeUtil.isDarkMode(context)
                    ? null
                    : LinearGradient(
                      begin: Alignment.topCenter, // 或者 Alignment.topLeft
                      end: Alignment.bottomCenter, // 或者 Alignment.bottomRight
                      colors: [
                        Color(0xFFE6E6E9), // 开始颜色
                        Color(0xFFEAE6DB), // 结束颜色
                      ],
                    ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                // 使用动画切换器，让错误提示的出现和消失更平滑
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildLoginForm(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建登录表单的主体部分
  Widget _buildLoginForm(BuildContext context) {
    return Column(
      key: const ValueKey('loginForm'), // 给一个key，用于动画切换
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. 顶部Logo和欢迎语
        _buildHeader(),
        const SizedBox(height: 40),

        // 2. 用户名输入框
        _buildUsernameField(),
        const SizedBox(height: 20),

        // 3. 密码输入框
        _buildPasswordField(),
        const SizedBox(height: 12),

        // 4. 忘记密码链接
        _buildForgotPasswordButton(),
        const SizedBox(height: 24),

        // 5. 错误信息提示
        if (_errorMessage != null) _buildErrorMessage(),

        // 6. 登录按钮
        _buildLoginButton(context),
      ],
    );
  }

  // 顶部Logo和欢迎语
  Widget _buildHeader() {
    return Column(
      children: [
        // 使用更贴合主题的图标
        Application.getAppLogo(width: 56,height: 56),
        const SizedBox(height: 16),
        Text(
          "欢迎回来",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        const SizedBox(height: 8),
        Text(
          "记录每一刻灵感",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  // 用户名输入框
  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      decoration: _inputDecoration(
        labelText: '用户名',
        prefixIcon: HugeIcons.strokeRoundedUser02,
        colorScheme: ColorScheme.of(context).copyWith(primary: Colors.indigo),
      ),
    );
  }

  // 密码输入框
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: _inputDecoration(
        labelText: '密码',
        prefixIcon: HugeIcons.strokeRoundedLock,
        colorScheme: ColorScheme.of(context).copyWith(primary: Colors.indigo),
      ),
    );
  }

  // 忘记密码按钮
  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: 实现忘记密码逻辑
        },
        child: Text(
          '忘记密码?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // 错误信息提示
  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 登录按钮
  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.indigo,
        ),
        onPressed: () => _handleLogin(context),
        child:
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                : Text(
                  "立即登录",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  // 统一定义输入框样式，方便复用和修改
  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: colorScheme.surfaceContainer,
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: HugeIcon(
          icon: prefixIcon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
      ),
    );
  }
}
