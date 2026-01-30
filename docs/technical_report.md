# 移动端架构与安全技术分析报告

## 1. 概述
本报告基于主流移动应用（微信、支付宝、抖音等）的技术架构，结合 RealDog 项目需求，详细分析公共参数设计、身份认证流程、Token 全生命周期管理、网络请求封装及安全加固方案。

## 2. 公共参数设计规范

### 2.1 设计原则
公共参数用于标识设备、应用版本及请求上下文，确保服务端能准确识别客户端环境并进行安全校验。

### 2.2 核心参数列表
| 参数名 | 描述 | 示例值 | 作用 |
| :--- | :--- | :--- | :--- |
| `X-App-Device-Id` | 设备唯一标识 | `550e8400-e29b-41d4-a716-446655440000` | 风控、设备指纹 |
| `X-App-Version` | 应用版本号 | `1.0.0` | 版本兼容控制 |
| `X-App-Build` | 构建版本号 | `100` | 热更新/补丁区分 |
| `X-App-Platform` | 操作系统 | `ios` / `android` | 平台差异化处理 |
| `X-App-Channel` | 分发渠道 | `appstore` / `googleplay` | 渠道统计 |
| `X-App-Timestamp`| 请求时间戳 | `1706601600000` | 防重放攻击 (5分钟有效期) |
| `X-App-Nonce` | 随机串 | `a1b2c3d4` | 防重放攻击 (一次性) |
| `X-App-Sign` | 签名摘要 | `md5(params + salt)` | 防篡改 |

### 2.3 签名算法 (Sign Generation)
为防止请求参数被篡改，采用以下签名策略：
1. **参数收集**：收集 Query 参数、Body 参数 (JSON平铺)、以及上述 Header 中的 `Timestamp` 和 `Nonce`。
2. **字典排序**：按 ASCII 码对参数名进行升序排序。
3. **拼接字符串**：格式为 `key1=value1&key2=value2...`。
4. **加盐 (Salt)**：在字符串末尾拼接服务端下发的 Secret Key (如 `&secret=xyz`)。
5. **摘要计算**：使用 MD5 或 HMAC-SHA256 计算摘要值。

## 3. 登录注册模块完整流程

### 3.1 注册流程
1. **输入手机号** -> **校验格式**。
2. **获取验证码 (OTP)**：调用后端 `/auth/otp` 接口，触发短信/邮件发送。
3. **输入验证码** -> **校验验证码**：后端验证通过后返回临时凭证 (Pre-Auth Token) 或直接注册。
4. **设置密码** (可选)：若为纯验证码登录则跳过。
5. **完成注册**：自动登录，下发 Token。

### 3.2 登录流程
支持多种登录方式，优先级如下：
1. **本机号码一键登录** (运营商能力，体验最佳)。
2. **账号密码登录** (传统方式，需配合图形验证码防暴破)。
3. **短信验证码登录** (忘记密码时的备选)。
4. **生物识别 (FaceID/TouchID)**：仅在已有 Token 且未过期时使用，用于快速解锁。

### 3.3 找回/重置密码
1. **身份验证**：输入手机号 + OTP。
2. **重置凭证**：验证通过后，后端返回一个短效的 `reset_token`。
3. **设置新密码**：客户端提交 `new_password` + `reset_token`。

## 4. Token 全生命周期管理

### 4.1 双 Token 机制
- **Access Token (AT)**:
  - 有效期：短 (如 15 分钟)。
  - 作用：访问业务接口。
  - 格式：JWT (包含 userId, role, exp)。
- **Refresh Token (RT)**:
  - 有效期：长 (如 7-30 天)。
  - 作用：换取新的 AT。
  - 存储：数据库中存储 Hash 值 (防泄露)，支持黑名单机制。

### 4.2 存储方案
- **iOS**: Keychain (安全沙盒存储)。
- **Android**: EncryptedSharedPreferences / Keystore。
- **Flutter**: `flutter_secure_storage` 插件。

### 4.3 自动刷新与并发处理
当 AT 过期时，API 请求会返回 `401 Unauthorized`。客户端 `AuthInterceptor` 需处理：
1. **拦截 401**：暂停当前请求。
2. **锁定队列**：防止并发请求触发多次刷新。
3. **刷新 Token**：使用 RT 调用 `/auth/refresh`。
   - **成功**：更新本地 AT/RT，重试原请求，解锁队列。
   - **失败** (RT 也过期)：清空本地 Token，跳转登录页。

### 4.4 黑名单与强制下线
- **场景**：用户修改密码、发现账号异常、管理员封号。
- **实现**：将 AT/RT 加入 Redis 黑名单，网关层校验时直接拦截。

## 5. 网络请求统一封装

### 5.1 架构设计
基于 `Dio` (Flutter) 或 `Axios` (Web) 进行封装：
- **Base Client**: 配置超时、BaseURL。
- **Interceptors**:
  - `SignInterceptor`: 注入公共参数，生成签名。
  - `AuthInterceptor`: 注入 Bearer Token，处理 401 刷新。
  - `LogInterceptor`: 打印请求/响应日志 (仅 Debug 模式)。
  - `ErrorInterceptor`: 统一异常处理 (网络错误、服务器错误、业务错误)。

### 5.2 安全加固
- **SSL Pinning**: 客户端内置服务端证书公钥，防止中间人攻击 (MITM)。
- **数据加密**: 敏感字段 (如密码) 在传输前使用 RSA 公钥加密。

## 6. 建议技术栈 (RealDog)
- **前端/移动端**: Flutter + Riverpod + Dio + FlutterSecureStorage.
- **后端**: NestJS + Prisma + SQLite (Dev) / PostgreSQL (Prod) + Passport (JWT).
- **安全**: BCrypt (密码哈希), Helmet (HTTP头安全), RateLimit (限流).

