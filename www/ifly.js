var exec = require('cordova/exec');

exports.startListen = function (success, error, isShowDialog, isShowPunc, language) {
    exec(success, error, 'ifly', 'startListen', [isShowDialog,isShowPunc,language]);
};
exports.stopListen = function (success, error, isShowDialog, isShowPunc, language) {
    exec(success, error, 'ifly', 'stopListen', [isShowDialog,isShowPunc,language]);
};
