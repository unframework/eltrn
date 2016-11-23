# E L T R N

WebAudio sampler/sequencer interface.

Demo: http://unframework.github.io/eltrn/ (also see early test video at https://www.youtube.com/watch?v=uZM0nfuLfxM)

## GH Publishing

- set up `.travis.yml` file
- `ssh-keygen -t rsa -b 4096 -f gh-publish.key -C <GH_EMAIL>`
- `travis encrypt-file gh-publish.key`
- `rm gh-publish.key`
- `git add gh-publish.key.enc`
- `cat gh-publish.key.pub` and paste into GitHub Deploy Keys (ensure push is enabled)
