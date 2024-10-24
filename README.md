# <img src="dotfiles-logo.png" alt="Dotfiles" width="200" />

> Dotfiles are managed using [git bare](https://www.atlassian.com/git/tutorials/dotfiles).


## Installation

```bash
git clone --bare git@github.com:monkeymonk/dotfiles.git $HOME/.dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
mkdir -p .dotfiles-backup
dotfiles config status.showUntrackedFiles no
dotfiles checkout
```

### Backup pre-existing dotfiles

If you have pre-existing dotfiles, back them up before checking out the new ones:

```bash
dotfiles checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dot files.";
  mkdir -p .dotfiles-backup  # Create the backup directory if it doesn't exist
  dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;
```


## Usage

Use the following commands to manage your dotfiles:

```bash
dotfiles status
dotfiles add .somefile
dotfiles add .someotherfile
dotfiles reset HEAD -- .someotherfile
dotfiles commit -m "Add somefile"
dotfiles push --set-upstream origin main
dotfiles push
```


---


# Secretfiles

> Secret files are managed using [git-secret](https://sobolevn.me/git-secret/) and [git bare](https://www.atlassian.com/git/tutorials/dotfiles).


## Installation

```bash
git clone --bare git@github.com:monkeymonk/secretfiles.git $HOME/.secretfiles
alias secretfiles="/usr/bin/git --git-dir=$HOME/.secretfiles/ --work-tree=$HOME"
secretfiles config status.showUntrackedFiles no
secretfiles secret init
secretfiles checkout
```

### Add GPG key

```bash
secretfiles secret whoknows # show current keys
gpg --gen-key
secretfiles secret tell <your email> # verify
secretfiles secret reveal # decrypt files (prompt for passkey)
```

### Import existing GPG key

If you have an existing GPG key, import it:

```bash
gpg --import your-private.key
secretfiles secret tell <your email>
```

Now you can decrypt your files with:

```bash
gpg --output .config/shell/secrets.sh --decrypt --try-all-secrets .config/shell/secrets.sh.secret
```


## Usage

Use the following commands to manage your secret files:

```bash
secretfiles status
secretfiles secret add .somefile # encrypt file
secretfiles add .someotherfile # non-encrypted file
secretfiles reset HEAD -- .someotherfile
secretfiles secret hide # encrypt files
secretfiles add .somefile.secret # this is the file we want to save
secretfiles commit -m "Add somefile"
secretfiles push --set-upstream origin main
secretfiles push
```


---


# TODO

- Update README.md with real examples and commands
- Cleanup and refactor .config/shell
- Move custom bins to .config/shell/bin


---


dotfiles' logo by [Joel Glovier](https://github.com/jglovier/dotfiles-logo)
