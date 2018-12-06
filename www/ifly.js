var exec = require('cordova/exec');

exports.startListen = function (arg0, success, error) {
    exec(success, error, 'ifly', 'startListen', [arg0]);
};
