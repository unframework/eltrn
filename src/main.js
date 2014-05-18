
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
    var soundSource, convolver, filter;

    soundSource = context.createBufferSource();
    // soundSource.playbackRate.value = 0.5;
    filter = context.createBiquadFilter();
    convolver = context.createConvolver();

    soundSource.loop = true;
    soundSource.loopEnd = 0.5;

    filter.type = 0; // low-pass
    filter.Q.value = 12.5;

    filter.frequency.setValueAtTime(440,  context.currentTime);
    filter.frequency.linearRampToValueAtTime(1760,  context.currentTime + 8);
    filter.Q.setValueAtTime(15, context.currentTime);
    // filter.Q.linearRampToValueAtTime(5, 8);

    soundSource.connect(filter);
    filter.connect(context.destination);
    // filter.connect(convolver);
    // convolver.connect(context.destination);

    loadAudio(context, './echo-chamber.wav').then(function (buffer) {
        // convolver.buffer = buffer;
    });

    loadAudio(context, './kick.mp3').then(function (buffer) {
        soundSource.buffer = buffer;
    });

    function playSound() {
        // play the source now
        soundSource.start(0);
    }

    function stopSound() {
        // stop the source now
        soundSource.stop(0);
    }

    // Events for the play/stop bottons
    document.querySelector('.play').addEventListener('click', playSound);
    document.querySelector('.stop').addEventListener('click', stopSound);
});
