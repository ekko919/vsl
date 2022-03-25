# Creating User Passwords

[Reference the Ansible FAQ](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html#how-do-i-generate-encrypted-passwords-for-the-user-module)

When using Ansible to create a user, you can pass a hash instead of a plain text password. When you do this, the plain text password that produced the hash value will be set as the user's password on the target system.

In order to generate the hash value that you will need to set in the playbook, you can use the python package [passlib](https://foss.heptapod.net/python-libs/passlib/-/wikis/home):

Install with pip:

`pip install passlib`

Run this to create the hash value:

`python -c "from passlib.hash import sha512_crypt; import getpass; print(sha512_crypt.using(rounds=5000).hash(getpass.getpass()))"`

You will be prompted to enter the desired password, and then you will get the hash value as output. Put the hash value into the Ansible playbook `password` field for the user.
