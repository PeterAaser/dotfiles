#! /usr/bin/fish
########## Variables

set dir ~/dotfiles
set olddir ~/dotfiles
set files ".bashrc" ".vimrc" ".vim" ".emacs" ".emacs.d" ".tmux.conf" ".i3"

##########


# create dotfiles_old
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "..done"


cd $dir

echo "Moving existing dotfiles from ~/ to $olddir"
for file in $files
    echo "Moving $file"
    mv ~/$file ~/dotfiles_old/
    echo "symlinking $file to ~/\n"
    ln -s $dir/$file ~/$file
end
