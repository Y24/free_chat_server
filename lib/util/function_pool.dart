import 'package:free_chat/enums.dart';

abstract class FunctionPool {
  static final Map<String, MessageSendStatus> _strToMSS = {
    'processing': MessageSendStatus.processing,
    'failture': MessageSendStatus.failture,
    'success': MessageSendStatus.success,
  };
  static MessageSendStatus getMessageSendStatusByStr(String s) => _strToMSS[s];
  static String getStrByMessageSendStatus(MessageSendStatus status) =>
      _strToMSS.map((s, status) => MapEntry(status, s))[status];
  static final _supportedProtocolCodes = [
    ChatProtocolCode,
    AccountProtocolCode,
    bool,
  ];
  static final Map<ChatProtocolCode, String> _cPCToStr = {
    ChatProtocolCode.newSend: 'newSend',
    ChatProtocolCode.reSend: 'reSend',
    ChatProtocolCode.accept: 'accept',
    ChatProtocolCode.reject: 'reject',
  };
  static String getStrByProtocolCode(dynamic code) {
    assert(_supportedProtocolCodes.any((type) => code.runtimeType == type),
        'Well,here is a bug to be fixed.');
    if (code is bool) return code ? 'true' : 'false';
    if (code is ChatProtocolCode) return getStrByChatProtocolCode(code);
    if (code is AccountProtocolCode) return getStrByAccountProtocolCode(code);
    assert(false, 'You hould not be here in the normal case.');
    return '';
  }

  static final Map<bool, String> _boolToStr = {
    true: 'true',
    false: 'false',
  };
  static getProtocolCodeByStr(String s) {
    if (_boolToStr.containsValue(s)) return s == 'true';
    if (_cPCToStr.containsValue(s)) return getChatProtocolCodeByStr(s);
    if (_apcToStr.containsValue(s)) return getAccountProtocolCodeByStr(s);
    assert(false, 'You hould not be here in the normal case.');
    return '';
  }

  static ChatProtocolCode getChatProtocolCodeByStr(String s) =>
      _cPCToStr.map((code, s) => MapEntry(s, code))[s];
  static String getStrByChatProtocolCode(ChatProtocolCode code) =>
      _cPCToStr[code];
  static final Map<AccountProtocolCode, String> _apcToStr = {
    AccountProtocolCode.login: 'login',
    AccountProtocolCode.logout: 'logout',
    AccountProtocolCode.register: 'register',
    AccountProtocolCode.cleanUp: 'cleanUp',
  };
  static AccountProtocolCode getAccountProtocolCodeByStr(String s) =>
      _apcToStr.map((code, s) => MapEntry(s, code))[s];
  static String getStrByAccountProtocolCode(AccountProtocolCode code) =>
      _apcToStr[code];

  static final _roleToStr = {
    Role.admin: 'admin',
    Role.service: 'service',
    Role.user: 'user',
  };
  static String getStrByRole(Role role) => _roleToStr[role];
  static Role getRoleByStr(String s) =>
      _roleToStr.map((role, s) => MapEntry(s, role))[s];
}
