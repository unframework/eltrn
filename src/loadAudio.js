define(['jquery'], function ($) {
    return function loadAudio(context, url) {
        var deferred = new $.Deferred();

        var request = new XMLHttpRequest();
        request.open("GET", url, true);
        request.responseType = "arraybuffer";

        request.onload = function () {
            deferred.resolve(context.createBuffer(request.response, false));
        }

        request.send();

        return deferred.promise();
    }
});