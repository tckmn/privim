# privim

**`privim`** is a very lightly modified fork of Neovim geared towards editing
private files, such as a personal journal. It has the following features:

* decrypts GPG-encrypted files into /dev/shm before editing and re-encrypts
  afterwards

* calls `mlockall` to prevent writing any data to disk in the form of swap

* disables viminfo and swap files

* automatically saves and exits upon losing focus or 10 seconds of idle time

* forces `gpg-agent`, if running, to immediately "forget" the passphrase after
  the file is encrypted and saved

To use `privim`,

    git clone https://github.com/KeyboardFire/privim.git
    cd neovim
    make
    cd ~/bin  # or wherever
    ln -s /path/to/privim

The symlink should point to the `privim` binary in the root of this project.

Also make sure that you

    echo 'key=foo@bar.baz' > ~/.privim

`privim` will read this file to determine which gpg key to use. You can then
simply run `privim filename`, which will create `filename` if it doesn't exist
already.

Other configuration options include:

* **`rotate`**: if this is set to anything other than the empty string,
  `privim` will "rotate" versions of your file. If the file being edited (say,
  `foo`) exists, it will move the old `foo` to `foo.0`, the old `foo.0` to
  `foo.1`, and so on, and your new version will be saved as `foo`.

* **`nvimflags`**: this is an array of flags to pass to the `nvim` command. Use
  `declare -a nvimflags=('-a' '-b' '-c')` in `~/.privim` to set this.

Note: `privim` is still in a very early stage of development, so a lot of
options that should really be configurable aren't yet.
