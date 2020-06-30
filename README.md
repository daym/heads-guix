# heads-guix

This is a Guix channel for Heads.

In order to use it in Guix, create a file ~/.config/guix/channels.scm with the following contents:

```scheme
(list (channel
        (name 'guix)
        (url "https://git.savannah.gnu.org/git/guix.git")
        (branch "master"))
      (channel
        (name 'heads)
        (url "https://github.com/daym/heads-guix.git")
        (branch "wip")))
```
