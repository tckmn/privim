# privim

`privim` is a very lightly modified fork of Neovim geared towards editing
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

    echo 'foo@bar.baz' > ~/.privim

`privim` will read this file to determine which gpg key to use.

You can then simply run `privim filename`, which will create `filename` if it
doesn't exist already.

Note: `privim` is still in a very early stage of development, so a lot of
options that should really be configurable aren't yet.
