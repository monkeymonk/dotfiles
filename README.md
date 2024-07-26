# Dotfiles

> Dotfiles are managed using [git bare](https://www.atlassian.com/git/tutorials/dotfiles).


## Installation

```bash
git clone --bare git@github.com:monkeymonk/dotfiles.git $HOME/.dotfiles
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
mkdir -p .dotfiles-backup
dotfiles checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
  else
    echo "Backing up pre-existing dot files.";
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
fi;
dotfiles checkout
dotfiles config status.showUntrackedFiles no
```


## Usage

```bash
dotfiles status
dotfiles add .somefile
dotfiles add .someotherfile
dotfiles reset HEAD -- .someotherfile
dotfiles commit -m "Add somefile"
dotfiles push
```


---


# Secretfiles

> Secret files are managed using [git-secret](https://sobolevn.me/git-secret/) and [git bare](https://www.atlassian.com/git/tutorials/dotfiles).


## Installation

```bash
git clone --bare git@github.com:monkeymonk/secretfiles.git $HOME/.secretfiles
alias secretfiles="/usr/bin/git --git-dir=$HOME/.secretfiles/ --work-tree=$HOME"
secretfiles secret init
secretfiles checkout
secretfiles config status.showUntrackedFiles no
```

### Add GPG key

```bash
secretfiles secret whoknows # show current keys
gpg --gen-key
secretfiles secret tell <your email> # verify
secretfiles secret reveal # decrypt files (prompt for passkey)
```

## Usage

```bash
secretfiles status
secretfiles secret add .somefile # encrypt file
secretfiles add .someotherfile # non-encrypted file
secretfiles reset HEAD -- .someotherfile
secretfiles secret hide # encrypt files
secretfiles add .somefile.secret # this is the file we want to save
secretfiles commit -m "Add somefile"
secretfiles push
```
