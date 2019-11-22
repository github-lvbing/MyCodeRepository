

DIR=/home/lvbing/tool

cd $DIR

git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git

cd linux-stable

git tag -l | less

git checkout -b stable v4.19.4


