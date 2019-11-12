enum Role {
  admin,
  service,
  user,
}
enum LoginStatus {
  authenticationsuccess,
  authenticationFailture,
  serverError,
  timeoutError,
  unknownError,
}
enum LogoutOrCleanUpStatus {
  success,
  authenticationFailture,
  serverError,
}
enum RegisterStatus {
  success,
  invalidUsername,
  permissionDenied,
  serverError,
  timeoutError,
  unknownError,
}
enum MessageSendStatus {
  processing,
  success,
  failture,
}

enum ChatProtocolCode {
  //handshake,
  newSend,
  reSend,
  accept,
  reject,
}
enum SendStatus {
  success,
  reject,
  serverError,
}
enum AccountProtocolCode {
  login,
  logout,
  register,
  cleanUp,
}
