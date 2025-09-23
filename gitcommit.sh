#!/usr/bin/env bash
echo -e "Write me  andmake :

1-commit title ( short brief )
2- commit desc ( good for a git commit )
3- CHANGELOG.md ( descriptive )
\n\n\n\n\n" > /tmp/tmpcommitmsg.txt
git diff --cached >> /tmp/tmpcommitmsg.txt

wl-copy < /tmp/tmpcommitmsg.txt

rm /tmp/tmpcommitmsg.txt
