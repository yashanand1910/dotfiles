# dotfiles

### Docker (Recommended)
To build image for your own user, clone this repo and run
```bash
docker build --build-arg USER=$(whoami) --build-arg UID=$(id -u) -t dev .
```
Then, to run
```bash
docker run -it --name dev dev
```
To set up ssh from host, simply mount
```bash
docker run -it --name dev -v ~/.ssh:/home/$(whoami)/.ssh dev
```
To install gpg keys from host, first export your keys
```bash
gpg --export <KEY_ID> > ~/.gnupg/private.key
gpg --export-secret-keys <KEY_ID> > ~/.gnupg/public.key
```
Then, mount the keys and container should automatically import them
```bash
docker run -it --name dev -v ~/.gnupg/private.key:/home/$(whoami)/host-private.key -v ~/.gnupg/public.key:/home/$(whoami)/host-public.key dev
```

### Local

#### Create symlinks

After cloning this repository, create the symlinks

```bash
mkdir -p ~/.config
ln -s ~/Code/dotfiles/.gitconfig ~
ln -s ~/Code/dotfiles/.gitignore ~
ln -s ~/Code/dotfiles/.tmux.conf ~
ln -s ~/Code/dotfiles/.zshrc ~
ln -s ~/Code/dotfiles/.vimrc ~
ln -s ~/Code/dotfiles/.vim/* ~/.vim
ln -s ~/Code/dotfiles/.config/* ~/.config
ln -s ~/Code/dotfiles/.oh-my-zsh/* ~/.oh-my-zsh/custom
mkdir -p ~/.claude && ln -s ~/Code/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
...
```

#### Install oh-my-zsh

```bash
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Install vim-plug (if using vim)

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```   
```bash
:PlugInst
```
