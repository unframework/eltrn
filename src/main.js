
require([
    'cs!projector',
    'loadAudio'
], function (
    projector,
    loadAudio
) {
    'use strict';

    function createAudioContext() {
        if (typeof AudioContext !== "undefined") {
            return new AudioContext();
        } else if (typeof webkitAudioContext !== "undefined") {
            return new webkitAudioContext();
        } else {
            throw new Error('AudioContext not supported. :(');
        }
    }

    var context = createAudioContext();
    var soundSource, convolver;

    soundSource = context.createBufferSource();
    soundSource.playbackRate.value = 0.5;
    convolver = context.createConvolver();

    soundSource.connect(convolver);
    convolver.connect(context.destination);

    loadAudio(context, './echo-chamber.wav').then(function (buffer) {
        convolver.buffer = buffer;
    });

    loadAudio(context, 'http://upload.wikimedia.org/wikipedia/en/0/04/Rayman_2_music_sample.ogg').then(function (buffer) {
        soundSource.buffer = buffer;
    });

    function playSound() {
        // play the source now
        soundSource.start(context.currentTime);
    }

    function stopSound() {
        // stop the source now
        soundSource.stop(context.currentTime);
    }

    // Events for the play/stop bottons
    document.querySelector('.play').addEventListener('click', playSound);
    document.querySelector('.stop').addEventListener('click', stopSound);
});
